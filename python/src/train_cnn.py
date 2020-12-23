#coding: utf-8
import numpy as np
import keras
from keras.optimizers import *
from keras.layers import *
from keras.callbacks import *
from keras.models import *
from numpy import *
import codecs
import pandas as pd
import matplotlib.pyplot as plt
import csv

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

def load_data(filepath, word_index, max_length=3000):
    data = []
    category_dict = {"プロ研": 0, "回路理論": 1, "多変量解析": 2, "ビジネス":3, "電生実験": 4, "OS": 5, "論文読み": 6, "開発環境構築": 7, "語学": 8}

    # df = pd.read_csv('../data/documents.csv')

    # for row in df:
    #     print(row)
    #     category = [1 if i == category_dict[row[1]] else 0 for i in range(10)] # 正解ラベルだけ1にした配列
    #     words = [word_index[word] for word in row[0].split(' ') if word in word_index] # 単語埋め込み：word_indexに変換

    #     # 長さをそろえる
    #     if len(words) > max_length:
    #         words = words[0:max_length]
    #     elif len(words) < max_length:
    #         words = words + [0] * (max_length - len(words))
               
    #     data.append((category,words))

    with open(filepath,'r',encoding="utf-8") as f:
        for l in f:
            row = l.replace("\n", "").split(",")
            
            category = [1 if i == category_dict[row[-1]] else 0 for i in range(10)] # 正解ラベルだけ1にした配列
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

def train(inputs, targets, embedding_matrix, batch_size=1024, epoch_count=100, max_length=3000, model_filepath="../model/cnn_model.h5", learning_rate=0.001):
    # train:validation:test = 6:2:2
    test_len = int(len(inputs) * 0.2)
    test_inputs = inputs[0:test_len]
    test_targets = targets[0:test_len]
    train_inputs = inputs[test_len:]
    train_targets = targets[test_len:]
    
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
        Dense(targets.shape[1], activation='softmax')
    ])

    model.summary()

    #Embedding層は学習しないようする
    model.layers[0].trainable = False

    model.compile(loss='categorical_crossentropy',
              optimizer=keras.optimizers.Adam(1e-4),
              metrics=['accuracy'])
    # model.compile(optimizer='rmsprop', loss='categorical_crossentropy', metrics=['accuracy'])


    # 学習
    history = model.fit(train_inputs, train_targets,
              epochs=epoch_count,
              batch_size=batch_size,
              verbose=1,
              validation_split=0.25,
              shuffle=True)

    score = model.evaluate(test_inputs, test_targets, verbose=0)
    print('Test on '+str(len(test_inputs))+' examples')
    print('Test loss:', score[0])
    print('Test accuracy:', score[1])

    # モデルの保存
    model.save(model_filepath)
    return history

if __name__ == "__main__":
    embedding_matrix, word_index = load_word_vec("../data/w2v.txt")

    docs = load_data("../data/documents.csv", word_index)

    input_values = []
    target_values = []
    for target_value, input_value in docs:
        input_values.append(input_value)
        target_values.append(target_value)
    input_values = np.array(input_values)
    target_values = np.array(target_values)

    history = train(input_values, target_values, embedding_matrix, epoch_count=200)
    history_df = pd.DataFrame(history.history)

    history_df.loc[:,['val_loss','loss']].plot()
    plt.savefig("../result/cnn_loss.png")
    history_df.loc[:,['val_accuracy','accuracy']].plot()
    plt.savefig("../result/cnn_accuracy.png")