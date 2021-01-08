#coding: utf-8
# 2層CNNによる実装
import numpy as np
import tensorflow as tf
import tensorflow.keras as keras

from tensorflow.keras.optimizers import *
from tensorflow.keras.layers import *
from tensorflow.keras.callbacks import *
from tensorflow.keras.models import *
from tensorflow.keras.utils import plot_model
from numpy import *
import codecs
import pandas as pd
import matplotlib.pyplot as plt
import csv

from sklearn.metrics import confusion_matrix
import itertools

from matplotlib import rcParams
import matplotlib

# matplotlib 日本語対応
rcParams['font.family'] = ['Noto Sans CJK JP']
matplotlib.font_manager._rebuild()

gpu_id = 0
physical_devices = tf.config.list_physical_devices('GPU')
tf.config.list_physical_devices('GPU')
tf.config.set_visible_devices(physical_devices[gpu_id], 'GPU')
tf.config.experimental.set_memory_growth(physical_devices[gpu_id], True)

# parameter
MODEL_NAME = "2L_CNN"
MAX_LENGTH = 3000
EPOCH = 1
# EPOCH = 200
BATCH_SIZE = 32
CATEGORIES = ["プロ研", "回路理論", "多変量解析", "ビジネス", "電生実験", "OS", "論文読み", "開発環境構築"]
# CATEGORIES = ["プロ研", "回路理論", "多変量解析", "ビジネス", "電生実験", "OS", "論文読み", "開発環境構築", "語学"]

category_dict = {}
# category_dict = {"プロ研": 0, "回路理論": 1, "多変量解析": 2, "ビジネス":3, "電生実験": 4, "OS": 5, "論文読み": 6, "開発環境構築": 7, "語学": 8}
for category in CATEGORIES:
    category_dict[category] = CATEGORIES.index(category)

# word2vecからembedding layer用の重み行列を作成。wordとindexを結びつける辞書word_indexも返す。
# predict用にword_index.csvも生成する
def load_word_vec(filepath):
    word_index = {}
    embedding_matrix = []

    with open(filepath,'r',encoding="utf-8_sig") as f:
        for l in f:
            row = l.replace("\n", "").split(" ")
            if len(row) != 101: # 例外が起きる行は無視する
                continue
            word = row[0]
            vec = [float(val) for val in row[1:]]
            embedding_matrix.append(vec)
            word_index[word] = len(embedding_matrix)

    # padding用(入力の時系列方向の長さを揃えるためにtoken id=0でpaddingする想定)にindexを追加
    word_index['0'] = 0

    with open('../data/word_index.csv', 'w', newline="") as f:
        writer = csv.writer(f)
        for key, val in word_index.items():
            try:
                writer.writerow([key,val])
            except:
                continue

    return np.array(embedding_matrix), word_index

def load_data(filepath, word_index, max_length=MAX_LENGTH):
    data = []

    with open(filepath,'r',encoding="utf-8") as f:
        for l in f:
            row = l.replace("\n", "").split(",")
            
            # CATEGORIESにないカテゴリの行は無視する
            if row[-1] not in CATEGORIES:
                continue

            # category = [1 if i == category_dict[row[-1]] else 0 for i in range(len(category_dict))] # 正解ラベルだけ1にした配列
            category = category_dict[row[-1]] 
            words = [word_index[word] for word in row[0].split(' ') if word in word_index] # 単語埋め込み：word_indexに変換

            # 長さをそろえる
            if len(words) > max_length:
                words = words[0:max_length]
            elif len(words) < max_length:
                words = words + [0] * (max_length - len(words))
                
            data.append((category,words))

    random.shuffle(data)
    print(str(len(data)) + ' data are available')
    
    return data

# confusion matrix の作成
def plot_confusion_matrix(cmx, classes, metrics_dir, normalize=False, title='Confusion matrix', cmap=plt.cm.Blues):
    if normalize:
        cmx = cmx.astype('float') / cmx.sum(axis=1)[:, np.newaxis]
        print('Normalized confusion matrix\n')
    else:
        print('Confusion matrix, without normalization\n')

    plt.figure(figsize=(8.0, 8.0))
    plt.imshow(cmx, interpolation='nearest', cmap=cmap)
    plt.title(title)
    plt.colorbar()
    tick_marks = np.arange(len(classes))
    plt.xticks(tick_marks, classes, rotation=45)
    plt.yticks(tick_marks, classes)
    plt.ylim(len(classes) - 0.5, -0.5)

    fmt = '.2f' if normalize else 'd'
    thresh = cmx.max() / 2.
    for i, j in itertools.product(range(cmx.shape[0]), range(cmx.shape[1])):
        plt.text(j, i, format(cmx[i, j], fmt), horizontalalignment='center', color='white' if cmx[i, j] > thresh else 'black')
    
    plt.tight_layout()
    plt.ylabel('True lable')
    plt.xlabel('Predicted label')

    cmx_path = metrics_dir + '/cmx.png'
    plt.savefig(cmx_path, bbox_inches='tight')

    plt.show()

# モデルの可視化
def visualize_model(model, save_path):
    plot_model(model, to_file=save_path)

def train(data, embedding_matrix, batch_size=BATCH_SIZE, epoch_count=100, max_length=MAX_LENGTH, model_filepath=f"../model/model_{MODEL_NAME}.h5", learning_rate=0.001):
    test_data = []
    train_data = []
    validation_data = []

    test_data_rate = 0.2 # testの割合
    validation_data_rate = 0.2  # validationの割合

    categorized_data = {category_dict[category]: [] for category in CATEGORIES}  # カテゴリごとに分けられたデータ
    for target_value, input_value in data:
        categorized_data[target_value].append((target_value, input_value))

    # train, validation, test データのカテゴリ組成を等しくする
    for category_id in categorized_data:
        data_len = len(categorized_data[category_id])
        test_boundary = int(data_len * test_data_rate)
        validation_boundary = int(data_len * (test_data_rate + validation_data_rate))

        test_data += categorized_data[category_id][0:test_boundary]
        validation_data += categorized_data[category_id][test_boundary:validation_boundary]
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
    
    # 単語数、embeddingの次元
    num_words, word_vec_size = embedding_matrix.shape
    # モデルの構築 RNN
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

    # model.compile(loss='categorical_crossentropy',
    #           optimizer=keras.optimizers.Adam(1e-4),
    #           metrics=['accuracy'])
    model.compile(optimizer='rmsprop', loss='categorical_crossentropy', metrics=['accuracy'])

    # checkpointの設定
    checkpoint = ModelCheckpoint(
        filepath=model_filepath,
        monitor='val_loss',
        save_best_only=True,
        period=1,
    )

    # 学習
    history = model.fit(train_inputs, train_targets,
              epochs=epoch_count,
              batch_size=batch_size,
              verbose=1,
              validation_data=(validation_inputs, validation_targets),
              callbacks=[checkpoint],
              shuffle=True)

    # 最良の結果を残したモデルを読み込む
    model = load_model(model_filepath)

    score = model.evaluate(test_inputs, test_targets, verbose=0)
    print('Test on '+str(len(test_inputs))+' examples')
    print('Test loss:', score[0])
    print('Test accuracy:', score[1])

    predict_classes = model.predict_classes(test_inputs)
    true_classes = np.argmax(test_targets, 1)
    cmx = confusion_matrix(true_classes, predict_classes)
    plot_confusion_matrix(cmx=cmx, classes=CATEGORIES, metrics_dir=f"../result/{MODEL_NAME}", normalize=False, title='Confusion matrix', cmap=plt.cm.Blues)

    # モデルを可視化した画像の保存
    visualize_model(model, f"../result/{MODEL_NAME}/model.png")

    return history

if __name__ == "__main__":
    embedding_matrix, word_index = load_word_vec("../data/w2v.txt")

    docs = load_data("../data/documents.csv", word_index)

    history = train(docs, embedding_matrix, epoch_count=EPOCH)
    history_df = pd.DataFrame(history.history)

    history_df.loc[:,['val_loss','loss']].plot()
    plt.savefig(f"../result/{MODEL_NAME}/loss.png")
    history_df.loc[:,['val_accuracy','accuracy']].plot()
    plt.savefig(f"../result/{MODEL_NAME}/accuracy.png")