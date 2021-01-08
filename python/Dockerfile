FROM nvcr.io/nvidia/tensorflow:20.03-tf2-py3

ENV DEBIAN_FRONTEND=noninteractive

# MeCab
# RUN apt-get update
# RUN apt-get upgrade -y
# RUN apt-get install -y libmecab2 libmecab-dev mecab mecab-utils nkf
RUN apt-get update && apt-get install -y \
  sudo \
  wget \
  vim \
  mecab \
  libmecab-dev \
  mecab-ipadic-utf8 \
  git \
  make \
  curl \
  xz-utils \
  file \
  graphviz

RUN apt install fonts-noto-cjk

RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git ; exit 0
RUN cd mecab-ipadic-neologd && \
  ./bin/install-mecab-ipadic-neologd -n -y && \
  echo "dicdir=/usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd">/etc/mecabrc
ENV MECABRC /etc/mecabrc

RUN pip install pandas
RUN pip install matplotlib
RUN pip install tensorflowjs
RUN pip install bs4
RUN pip install mecab-python3
RUN pip install sklearn
RUN pip install graphviz
RUN pip install pydotplus
RUN pip install imblearn

# duser setting
ARG USER_ID
ARG GROUP_ID
RUN addgroup --gid $GROUP_ID duser && \
    adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID duser && \
    adduser duser sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER duser
# 各種命令を実行するカレントディレクトリを指定
WORKDIR /workspace/