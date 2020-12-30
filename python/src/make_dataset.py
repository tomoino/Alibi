# URL listを読み込んで、スクレイピングして
import sys
import requests
from bs4 import BeautifulSoup
import re
import csv

import MeCab

def load_url_list(filepath):
    url_list = []  # URL, category

    with open(filepath,'r', encoding="utf8", errors='ignore') as f:
        for l in f:
            row = l.replace("\n", "").split(",")
            url_list.append([row[0], row[3]])

    return url_list

url_list = load_url_list("../data/history_UTF.csv")

data = [] # 出力するデータを格納 [[text,category],...]
lenlist = []

i = 0
for row in url_list:
    try:
        urlName = row[0]
        html = requests.get(urlName).text
        soup = BeautifulSoup(html, "html.parser")

        for script in soup(["script", "style"]):
            script.decompose()

        text = soup.get_text()
        lines = [line.strip() for line in text.splitlines()]
        text = "\n".join(line for line in lines if line)
        tagger = MeCab.Tagger("-Owakati")        
        text = tagger.parse(text)
        
        text = text.replace("\n", "")
        data.append([text, row[1]])
        lenlist.append(len(text.split(' ')))
        i += 1
        if i % 10 == 0:
            print("step: "+ str(i))
    except:
        continue

print(max(lenlist))
print(sum(lenlist)/len(lenlist))
with open('../data/documents.csv', 'w', newline="") as f:
    writer = csv.writer(f)
    for row in data:
        try:
            writer.writerow(row)
        except:
            continue