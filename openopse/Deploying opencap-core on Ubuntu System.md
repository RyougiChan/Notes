# Deploying opencap-core on Ubuntu System

[stanfordnmbl/opencap-core](https://github.com/stanfordnmbl/opencap-core) 项目的仓库文档介绍了在 Windows 10进行本地部署的详细步骤，虽然作者提及了可在Ubuntu上运行，但没有提供相关的文档。

本文档主要记录 [stanfordnmbl/opencap-core](https://github.com/stanfordnmbl/opencap-core) 项目在 Ubuntu 进行本地部署的步骤，需要修改的项目文件以及可能遇到的问题。

## 准备工作

### 软件

- OS: Ubuntu 22.04
- CUDA 11.2 [[download]](https://developer.nvidia.com/cuda-downloads)
- cudnn 8.1.0 [[download]](https://developer.nvidia.com/rdp/cudnn-archive)

### 工作目录

```sh
# 临时文件目录
mkdir -pv /pvol/tmp
# 项目文件目录
mkdir -pv /pvol/project
```

### 辅助工具

```sh
# git
sudo apt-get install git
# ffmpeg
sudo apt-get install ffmpeg
# opencv
sudo apt-get install libopencv-dev
# cmake gui
sudo apt-get install cmake-qt-gui
```

## 底层支持

### 安装NVIDIA驱动/CUDA/cudnn

```sh
# 自动安装驱动
sudo ubuntu-drivers autoinstall
# 检查驱动
nvidia-smi

# 安装cuda
cd /pvol/tmp
sudo apt-get install gcc-9 g++-9
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100

wget https://developer.download.nvidia.com/compute/cuda/11.2.0/local_installers/cuda_11.2.0_460.27.04_linux.run
sudo sh cuda_11.2.0_460.27.04_linux.run

sudo ln -s /usr/bin/gcc-9 /usr/local/cuda/bin/gcc
sudo ln -s /usr/bin/g++-9 /usr/local/cuda/bin/g++
# 查看安装情况
nvcc -V

# 安装cudnn(下面的下载链接需要重新去 https://developer.nvidia.com/rdp/cudnn-archive 获取)
wget "https://developer.download.nvidia.com/compute/machine-learning/cudnn/secure/8.1.0.77/11.2_20210127/cudnn-11.2-linux-x64-v8.1.0.77.tgz?XXXXX" -O cudnn8.1.tgz

sudo cp -r include/cudnn*.h /usr/local/cuda/include/
sudo cp -r lib64/libcudnn* /usr/local/cuda/lib64/
sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*
sudo cat /usr/local/cuda/include/cudnn_version.h | grep CUDNN_MAJOR -A 2

echo 'export PATH=$PATH:/usr/local/cuda/bin' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64' >> ~/.bashrc

# cdunn创建软连接到anaconda环境
ls /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn*.so
ls /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn*

sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_adv_infer.so /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_adv_infer.so
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_adv_infer.so.8 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_adv_infer.so.8
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_adv_infer.so.8.1.0 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_adv_infer.so.8.1.0
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_adv_train.so /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_adv_train.so
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_adv_train.so.8 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_adv_train.so.8
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_adv_train.so.8.1.0 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_adv_train.so.8.1.0
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_cnn_infer.so /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_cnn_infer.so
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_cnn_infer.so.8 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_cnn_infer.so.8
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_cnn_infer.so.8.1.0 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_cnn_infer.so.8.1.0
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_cnn_train.so /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_cnn_train.so
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_cnn_train.so.8 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_cnn_train.so.8
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_cnn_train.so.8.1.0 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_cnn_train.so.8.1.0
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_ops_infer.so /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_ops_infer.so
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_ops_infer.so.8 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_ops_infer.so.8
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_ops_infer.so.8.1.0 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_ops_infer.so.8.1.0
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_ops_train.so /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_ops_train.so
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_ops_train.so.8 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_ops_train.so.8
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_ops_train.so.8.1.0 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_ops_train.so.8.1.0
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn.so /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn.so
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn.so.8 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn.so.8
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn.so.8.1.0 /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn.so.8.1.0
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_static.a /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_static.a
sudo ln -sf /usr/local/cuda-11.2/targets/x86_64-linux/lib/libcudnn_static_v8.a /pvol/software/anaconda3/envs/opencap/bin/../lib/libcudnn_static_v8.a
```

### 安装OpenSim

安装 [opensim-cmd支持](https://github.com/opensim-org/opensim-core/wiki/Build-Instructions#linux)

```sh
cd /pvol/tmp
wget https://raw.githubusercontent.com/opensim-org/opensim-core/main/scripts/build/opensim-core-linux-build-script.sh
bash ./opensim-core-linux-build-script.sh -j`nproc`
echo 'export PATH=~/opensim-core/bin:$PATH' >> ~/.bashrc
```

### 编译Openpose

参考文档[Compiling and Running OpenPose from Source](https://github.com/CMU-Perceptual-Computing-Lab/openpose/blob/master/doc/installation/0_index.md#compiling-and-running-openpose-from-source)

```sh
cd /pvol/project
git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose
cd openpose
git submodule update --init --recursive --remote

```

!!! warning 下载 Caffe 模型  
    编译openpose之前最好先把模型全部下载下来，因为原项目下载地址[posefs1.perception.cs.cmu.edu](http://posefs1.perception.cs.cmu.edu)已经失效，会编译失败
    下载地址：[https://drive.google.com/file/d/1QCSxJZpnWvM00hx49CJ2zky7PWGzpcEh](https://drive.google.com/file/d/1QCSxJZpnWvM00hx49CJ2zky7PWGzpcEh)
    文件安置的位置： 
    ./openpose/models/pose/body_25/pose_iter_584000.caffemodel  
    ./openpose/models/pose/coco/pose_iter_440000.caffemodel  
    ./openpose/models/pose/mpi/pose_iter_160000.caffemodel  
    ./openpose/models/face/pose_iter_116000.caffemodel  
    ./openpose/models/hand/pose_iter_102000.caffemodel

```sh
mkdir build/
cd build/
cmake-gui ..
##按照文档步骤操作cmake gui界面配置cmake，完成之后关掉gui界面继续下面操作
make -j`nproc`
```

上一步编译完成后验证安装，若安装成功，弹出的界面可以看到识别到人的关键点，若不显示关键点，可能是 Caffe 模型有问题，检查 `./openpose/models` 可排除问题

```sh
cd ../
./build/examples/openpose/openpose.bin --video examples/media/video.avi --net_resolution "128x-1"
```

## 安装步骤

### 安装 [Anaconda](https://docs.anaconda.com/free/anaconda/install/linux/)

```sh
sudo apt-get update
sudo apt-get install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6

cd /pvol/tmp
wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh
# 中途设置安装目录/pvol/software/anaconda3
bash ./Anaconda3-2023.09-0-Linux-x86_64.sh

echo 'export PATH=$PATH:/pvol/software/anaconda3/bin' >> ~/.bashrc
```

### 下载[stanfordnmbl/opencap-core](https://github.com/stanfordnmbl/opencap-core)项目到本地

```sh
cd /pvol/project
git clone https://github.com/stanfordnmbl/opencap-core.git
```

### 创建激活conda环境和安装依赖

```sh
conda create -n opencap python=3.9 pip spyder
source activate opencap
# 安装opensim conda依赖包
conda install -c opensim-org opensim=4.4=py39np120
# 安装cuda、cudnn依赖包
conda install -c conda-forge cudatoolkit=11.2 cudnn=8.1.0
```

### 安装项目依赖

```sh
python -m pip install -r requirements.txt
```

## 运行opencap-core

### 修改[stanfordnmbl/opencap-core](https://github.com/stanfordnmbl/opencap-core)项目文件（必要）
