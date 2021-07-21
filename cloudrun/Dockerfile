FROM ubuntu:20.04

ENV PYTHONUNBUFFERED True

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


WORKDIR /app
ADD . /app

RUN apt-get update && apt-get install -y \
    build-essential \
    g++-8 \
    cmake  \
    git \
    libgtk2.0-dev \
    pkg-config \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    python-dev \
    python-numpy \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libdc1394-22-dev \
    wget \
    unzip \
    # building OpenCV
    && wget https://github.com/opencv/opencv/archive/4.1.0.zip \
    && unzip 4.1.0.zip && cd opencv-4.1.0 && mkdir build && cd build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D BUILD_TIFF=ON -D WITH_TBB=ON .. \
    && make -j2 && make install && cd ../.. \
    # install dlib
    && wget http://dlib.net/files/dlib-19.13.tar.bz2 \
    && tar xf dlib-19.13.tar.bz2 && cd dlib-19.13 && mkdir build \
    && cd build && cmake .. && cmake --build . --config Release \
    && make install && ldconfig && cd ../.. \
    && apt-get install -y libboost-all-dev \
    # install OpenBLAS
    && git clone https://github.com/xianyi/OpenBLAS.git \
    && cd OpenBLAS && make -j4 && make install && cd .. \
    # install OpenFace
    && git clone https://github.com/TadasBaltrusaitis/OpenFace.git \
    && cd OpenFace && mkdir build && cd build \
    && cmake -D CMAKE_CXX_COMPILER=g++-8 -D CMAKE_C_COMPILER=gcc-8 -D CMAKE_BUILD_TYPE=RELEASE .. \
    && make && cd ../.. \
    && mv cen_patches_*_of.dat OpenFace/build/bin/model/patch_experts/

RUN apt-get install -y python3-pip \
    && python3.8 -m pip install --no-cache-dir -r requirements.txt

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app