import csv


def load_history(filepath):
    history = []  # URL, title, Visit Time
    URL_list = []

    with open(filepath,'r', encoding="utf8", errors='ignore') as f:
        for l in f:
            row = l.replace("\n", "").split(",")

            if row[0] not in URL_list:
                history.append([row[0], row[1], row[2]])
                URL_list.append(row[0])

    return history

history = load_history("../data/raw_history.csv")
with open('../data/history.csv', 'w', newline="", encoding="sjis") as f:
    writer = csv.writer(f)
    for row in history:
        try:
            writer.writerow(row)
        except:
            continue