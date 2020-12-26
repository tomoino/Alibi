FROM nvcr.io/nvidia/tensorflow:20.03-tf2-py3

ENV DEBIAN_FRONTEND=noninteractive

RUN pip install pandas
RUN pip install matplotlib
RUN pip install tensorflowjs

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