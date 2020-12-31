# データベースのevenrカラムをアップデートする
#coding: utf-8
import requests
import datetime
from bs4 import BeautifulSoup
import MeCab
import numpy as np

import tensorflow as tf
from tensorflow.keras.models import load_model

gpu_id = 0
physical_devices = tf.config.list_physical_devices('GPU')
tf.config.list_physical_devices('GPU')
tf.config.set_visible_devices(physical_devices[gpu_id], 'GPU')
tf.config.experimental.set_memory_growth(physical_devices[gpu_id], True)

# パラメタ
FROM = "2020-12-11_12:00:00"
TO = "2021-01-01_00:00:00"
# TO = "2020-12-12_00:00:00"
HISTORY_CSV = "../data/raw_history_12.csv"
MAX_LENGTH = 3000
categories = ["プロ研", "回路理論", "多変量解析", "ビジネス", "電生実験", "OS", "論文読み", "開発環境構築", "語学"]

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

def load_word_index(filepath):
    word_index = {}

    with open(filepath,'r',encoding="utf-8") as f:
        for l in f:
            row = l.replace("\n", "").split(",")
            try:
                word_index[row[0]] = int(row[1])
            except:
                pass

    return word_index

def predict(url, word_index, model):
    # スクレイピング
    html = requests.get(url).text
    soup = BeautifulSoup(html, "html.parser")

    for script in soup(["script", "style"]):
        script.decompose()

    text = soup.get_text()
    lines = [line.strip() for line in text.splitlines()]
    text = "\n".join(line for line in lines if line)
    tagger = MeCab.Tagger("-Owakati")        
    text = tagger.parse(text)
    text = text.replace("\n", "")

    # word listを作成
    word_list = [word_index[word] for word in text.split(' ') if word in word_index] # word_indexに変換
    if len(word_list) < MAX_LENGTH:
        word_list = word_list + [0]*(MAX_LENGTH - len(word_list)) # 長さをそろえる
    elif len(word_list) > MAX_LENGTH:
        word_list = word_list[0:MAX_LENGTH]

    # predict
    pred = model.predict(np.array([word_list]))
    max_index = np.argmax(pred[0])

    return categories[max_index]

# model読み込み
model_filepath="../model/cnn_model.h5"
model = load_model(model_filepath)

# データベースの取得
payload = {"from": FROM, "to": TO}
res = requests.get("https://alibi-api.herokuapp.com/events", payload).json()

# history取得
history = load_history(HISTORY_CSV)

# word indexの読み込み
word_index = load_word_index("../data/word_index.csv")

for index, record in enumerate(res):
    res[index]['Event'] = ""
    
    tdatetime = datetime.datetime.strptime(record['Time'], '%Y-%m-%dT%H:%M:%S.%fZ')
    from_time = datetime.datetime(tdatetime.year, tdatetime.month, tdatetime.day, tdatetime.hour, tdatetime.minute, 0)
    to_time = from_time + datetime.timedelta(minutes=10)
    # print("from: "+str(from_time)+", to: "+ str(to_time))

    # 指定範囲内のデータを更新
    for row in history:
        if row[1] >= from_time and row[1] < to_time:
            # print("    time: "+str(row[1]))
            # predict
            pred = predict(row[0], word_index, model)
            if len(res[index]['Event']) > 0:
                res[index]['Event'] = res[index]['Event'] + "," + pred
            else:
                res[index]['Event'] = pred

    # print("    Event: " + res[index]["Event"])

    # アップデート
    update_response = requests.post(
        'https://alibi-api.herokuapp.com/update/'+str(record["Id"]),
        res[index]).json()
    # print(update_response)
    print(str(record["Id"])+": "+str(record["Time"])+" "+record["Event"])
