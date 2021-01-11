# データベースのevenrカラムをアップデートする
#coding: utf-8
import requests
import datetime
from bs4 import BeautifulSoup
import MeCab
import numpy as np

import tensorflow as tf
from tensorflow.keras.models import load_model
import my_ml_utils as ml

gpu_id = 0
physical_devices = tf.config.list_physical_devices('GPU')
tf.config.list_physical_devices('GPU')
tf.config.set_visible_devices(physical_devices[gpu_id], 'GPU')
tf.config.experimental.set_memory_growth(physical_devices[gpu_id], True)

# パラメタ
FROM = "2020-12-11_14:00:00"
TO = "2021-01-08_00:00:00"
HISTORY_CSV = "../data/raw_history.csv"

# FROM = "2020-12-11_14:20:00"
# TO = "2020-12-12_00:00:00"
# HISTORY_CSV = "../data/raw_history_test.csv"

MAX_LENGTH = 3000
CATEGORIES = ["プロ研", "回路理論", "多変量解析", "ビジネス", "電生実験", "OS", "論文読み", "開発環境構築"]

def load_history(filepath):
    url_list = []  # URL, category

    with open(filepath,'r', encoding="utf8", errors='ignore') as f:
        for l in f:
            row = l.replace("\n", "").split(",")
            try:
                tdatetime = datetime.datetime.strptime(row[2], '%Y/%m/%d %H:%M')
                url_list.append([row[0], tdatetime])  # url, time
            except:
                continue

    return url_list

def get_text(url):
    # スクレイピング
    try:
        html = requests.get(url).text
    except:
        return ""
    soup = BeautifulSoup(html, "html.parser")

    for script in soup(["script", "style"]):
        script.decompose()

    text = soup.get_text()
    lines = [line.strip() for line in text.splitlines()]
    text = "\n".join(line for line in lines if line)
    tagger = MeCab.Tagger("-Owakati")        
    text = tagger.parse(text)
    text = text.replace("\n", "")

    return text

def tokenize(text, word_index):
    # word listを作成
    word_list = [word_index[word] for word in text.split(' ') if word in word_index] # word_indexに変換
    if len(word_list) < MAX_LENGTH:
        word_list = word_list + [0]*(MAX_LENGTH - len(word_list)) # 長さをそろえる
    elif len(word_list) > MAX_LENGTH:
        word_list = word_list[0:MAX_LENGTH]

    return word_list

# 履歴データのすべてについてスクレイピングして、inputsに変換
def make_inputs_from_history(history):
    inputs = []
    word_index = ml.load_word_index()
    history_len = len(history)

    for idx,value in enumerate(history):
        url = value[0]
        text = get_text(url)
        word_list = tokenize(text, word_index)
        inputs.append(word_list)
        print(str(int(idx/history_len*1000)/10.0) + " % "+ str(idx+1))

    inputs = np.array(inputs)

    return inputs

def main(model_names):
    # データベースの取得
    payload = {"from": FROM, "to": TO}
    events = requests.get("https://alibi-api.herokuapp.com/events", payload).json()

    # history取得
    history = load_history(HISTORY_CSV)  # [[ url, time], ...]
    print("----- MAKE INPUTS --------------------------------------")
    inputs = make_inputs_from_history(history) # [ input, ...]
    print("----- PREDICT --------------------------------------")
    preds = ml.ensemble_predict(model_names, inputs) # [[ 0-model_num, ...], ...]

    # debug用
    events_len = len(events)

    print("----- UPDATE --------------------------------------")
    # events の record ごとに処理
    for index, record in enumerate(events):
        pred_vec = np.zeros(len(CATEGORIES))

        # record の時間範囲を計算する
        tdatetime = datetime.datetime.strptime(record['Time'], '%Y-%m-%dT%H:%M:%S.%fZ')
        from_time = datetime.datetime(tdatetime.year, tdatetime.month, tdatetime.day, tdatetime.hour, tdatetime.minute, 0)
        to_time = from_time + datetime.timedelta(minutes=10)

        # history全体から指定範囲内のデータを検索
        for row_idx, row in enumerate(history):
            # 指定範囲内のデータのみ更新に利用
            if row[1] >= from_time and row[1] < to_time:
                pred_vec += preds[row_idx]

        if np.all(pred_vec == 0):
            events[index]['Event'] = ""
        else:
            # list に変換して、各値をカンマ区切りで結合
            events[index]['Event'] = ','.join(map(str, pred_vec.tolist()))

        # アップデート
        update_response = requests.post(
            'https://alibi-api.herokuapp.com/update/'+str(record["Id"]),
            events[index]).json()
        # print(update_response)
        print(str(int(index/events_len*1000)/10.0) + " % " + str(record["Id"])+": "+str(record["Time"])+" "+record["Event"])

if __name__ == "__main__":
    model_names = ['2L_CNN_wo_imblearn_6','2L_CNN_wo_imblearn_6','2L_CNN_wo_imblearn_6','2L_CNN_wo_imblearn_6','2L_CNN_wo_imblearn_6','2L_CNN_ENSEMBLE_1','2L_CNN_ENSEMBLE_2','2L_CNN_ENSEMBLE_3', '2L_CNN_ENSEMBLE_5', '2L_CNN_ENSEMBLE_6']
    main(model_names)