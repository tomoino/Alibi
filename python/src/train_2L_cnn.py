#coding: utf-8
# 2層CNNによる実装
import numpy as np
from numpy import *
import tensorflow as tf
import tensorflow.keras as keras
from tensorflow.keras.optimizers import *
from tensorflow.keras.layers import *
from tensorflow.keras.callbacks import *
from tensorflow.keras.models import *
import my_ml_utils as ml

# データの不均衡性への対策
from imblearn.keras import balanced_batch_generator
from sklearn.utils import resample

gpu_id = 0
physical_devices = tf.config.list_physical_devices('GPU')
tf.config.list_physical_devices('GPU')
tf.config.set_visible_devices(physical_devices[gpu_id], 'GPU')
tf.config.experimental.set_memory_growth(physical_devices[gpu_id], True)

# parameter
MAX_LENGTH = 3000
EPOCH = 400
BATCH_SIZE = 32
LR = 0.001
CATEGORIES = ["プロ研", "回路理論", "多変量解析", "ビジネス", "電生実験", "OS", "論文読み", "開発環境構築"]
# CATEGORIES = ["プロ研", "回路理論", "多変量解析", "ビジネス", "電生実験", "OS", "論文読み", "開発環境構築", "語学"]

category_dict = {}
# category_dict = {"プロ研": 0, "回路理論": 1, "多変量解析": 2, "ビジネス":3, "電生実験": 4, "OS": 5, "論文読み": 6, "開発環境構築": 7, "語学": 8}
for category in CATEGORIES:
    category_dict[category] = CATEGORIES.index(category)

def train(_train_data, test_data, embedding_matrix, batch_size=BATCH_SIZE, epoch_count=100, max_length=MAX_LENGTH, model_name="model", learning_rate=LR):
    random.shuffle(_train_data)
    model_filepath = f"../model/model_{model_name}.h5"
    result_dir = f"../result/{model_name}"
    ml.save_hyparameters(result_dir, model_name, epoch_count, batch_size, learning_rate)

    train_data = []
    validation_data = []

    validation_data_rate = 0.25  # validationの割合

    categorized_data = {category_dict[category]: [] for category in CATEGORIES}  # カテゴリごとに分けられたデータ
    for target_value, input_value in _train_data:
        categorized_data[target_value].append((target_value, input_value))

    # train, validation, test データのカテゴリ組成を等しくする
    for category_id in categorized_data:
        data_len = len(categorized_data[category_id])
        validation_boundary = int(data_len * validation_data_rate)

        validation_data += categorized_data[category_id][0:validation_boundary]
        train_data += categorized_data[category_id][validation_boundary:]
    
    test_inputs = []
    test_targets = []
    train_inputs = []
    train_targets = []
    validation_inputs = []
    validation_targets = []

    for target_value, input_value in test_data:
        test_inputs.append(input_value)
        test_targets.append([1 if i == target_value else 0 for i in range(len(category_dict))]) # 正解ラベルだけ1にした配列

    for target_value, input_value in validation_data:
        validation_inputs.append(input_value)
        validation_targets.append([1 if i == target_value else 0 for i in range(len(category_dict))]) # 正解ラベルだけ1にした配列

    for target_value, input_value in train_data:
        train_inputs.append(input_value)
        train_targets.append([1 if i == target_value else 0 for i in range(len(category_dict))]) # 正解ラベルだけ1にした配列

    # カテゴリごとに含まれる数を表示
    count_by_categories = {key: np.concatenate([np.argmax(test_targets, 1), np.argmax(validation_targets, 1), np.argmax(train_targets, 1)] ).tolist().count(category_dict[key]) for key in CATEGORIES}
    test_count_by_categories = {key: np.argmax(test_targets, 1).tolist().count(category_dict[key]) for key in CATEGORIES}
    validation_count_by_categories = {key: np.argmax(validation_targets, 1).tolist().count(category_dict[key]) for key in CATEGORIES}
    train_count_by_categories = {key: np.argmax(train_targets, 1).tolist().count(category_dict[key]) for key in CATEGORIES}
    print("ALL: ", count_by_categories)
    print("TRAIN: ", train_count_by_categories)
    print("VALIDATION: ", validation_count_by_categories)
    print("TEST: ", test_count_by_categories)

    test_inputs = np.array(test_inputs)
    test_targets = np.array(test_targets)
    train_inputs = np.array(train_inputs)
    train_targets = np.array(train_targets)
    validation_inputs = np.array(validation_inputs)
    validation_targets = np.array(validation_targets)

    # Bootstrap Sampling
    train_inputs, train_targets = resample(train_inputs, train_targets, n_samples = len(train_inputs))
    
    # 単語数、embeddingの次元
    num_words, word_vec_size = embedding_matrix.shape
    # モデルの構築
    model = Sequential([
        Embedding(num_words, word_vec_size,
                weights=[embedding_matrix], 
                input_length=max_length,
                trainable=False, 
                mask_zero=True),
        Conv1D(16, 5, activation='relu'),
        AveragePooling1D(7),
        Dropout(0.5),
        Conv1D(16, 5, activation='relu'),
        GlobalAveragePooling1D(),
        Dense(128, activation='relu'),
        Dropout(0.3),
        Dense(len(CATEGORIES), activation='softmax')
    ])

    model.summary()

    #Embedding層は学習しないようする
    model.layers[0].trainable = False

    model.compile(loss='categorical_crossentropy',
              optimizer=keras.optimizers.Adam(learning_rate),
              metrics=['accuracy'])
              
    # model.compile(loss='categorical_crossentropy',
    #           optimizer=keras.optimizers.rmsprop(learning_rate),
    #           metrics=['accuracy'])

    # checkpointの設定
    checkpoint = ModelCheckpoint(
        filepath=model_filepath,
        monitor='val_loss',
        save_best_only=True,
        period=1,
    )

    # 学習率を少しずつ下げるようにする
    # start = learning_rate
    # stop = learning_rate * 0.1
    # learning_rates = np.linspace(start, stop, epoch_count)

    # データの不均衡性への対策
    training_generator, steps_per_epoch = balanced_batch_generator(
        train_inputs, train_targets, batch_size=batch_size, random_state=42)
    # validation_generator, validation_steps = balanced_batch_generator(
    #     validation_inputs, validation_targets, batch_size=batch_size, random_state=42)

    # 学習
    history = model.fit_generator(generator=training_generator,
            steps_per_epoch=steps_per_epoch,
            epochs=epoch_count,
            verbose=1,
            validation_data=(validation_inputs, validation_targets),
            # validation_data=validation_generator,
            # validation_steps=validation_steps,
            # callbacks=[checkpoint, LearningRateScheduler(lambda epoch: learning_rates[epoch])],
            callbacks=[checkpoint],
            shuffle=True)

    # 最良の結果を残したモデルを読み込む
    model = load_model(model_filepath)

    ml.model_evaluate(model, test_inputs, test_targets, result_dir)
    ml.classification_evaluate(model, test_inputs, test_targets, result_dir)
    ml.visualize_model(model, result_dir)
    ml.save_history(history, result_dir)

def main(model_name):
    embedding_matrix, train_data, test_data = ml.load_dataset()
    train(train_data, test_data, embedding_matrix, epoch_count=EPOCH, model_name=model_name)

if __name__ == "__main__":
    main("TMP")