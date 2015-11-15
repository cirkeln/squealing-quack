# Setup instructions for building TensorFlow android example on an aws
# Ubuntu instance

# Check disk space
df -h

# To prevent running out of memory I installed to /mnt
sudo mkdir /mnt/tmp
sudo chmod 777 /mnt/tmp
sudo rm -rf /tmp
sudo ln -s /mnt/tmp /tmp

# Install java
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer
javac -version

# Install various packages
sudo apt-get install pkg-config zip g++ zlib1g-dev unzip git python-numpy swig python-dev

# Install Bazel
git clone https://github.com/bazelbuild/bazel.git
cd bazel/
git checkout tags/0.1.0
./compile.sh
sudo cp output/bazel /usr/bin

cd /mnt/tmp

# Install Android ndk
wget http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
chmod +x android-ndk-r10e-linux-x86_64.bin
./android-ndk-r10e-linux-x86_64.bin

# Install Android sdk
wget http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
tar -xvzf android-sdk_r24.4.1-linux.tgz

# Try downloading only what you need as described here
# http://stackoverflow.com/questions/7706389/android-sdk-install-specific-component-from-commandline
# If that is not working get all the 20GB with
./android-sdk-linux/tools/android update skd --no-ui

# Fix the aapt error. http://stackoverflow.com/questions/18041769/error-cannot-run-aapt
sudo apt-get update
sudo apt-get install gcc-multilib lib32z1 lib32stdc++6

# Install TensorFlow
git clone --recurse-submodules https://github.com/tensorflow/tensorflow

# Update the tensorflow/WORKSPACE file
# Uncomment the Android section at the top of the file and add sdk and ndk paths:
# android_sdk_repository(
#     name = "androidsdk",
#     api_level = 23,
#     build_tools_version = "23.0.2",
#     # Replace with path to Android SDK on your system
#     path = "/mnt/tmp/android-sdk-linux",
# )
#
# android_ndk_repository(
#     name="androidndk",
#     path="/mnt/tmp/android-ndk-r10e",
#     api_level=21)

# Build the Android example
cd tensorflow
bazel build //tensorflow/examples/android:tensorflow_demo -c opt --copt=-mfpu=neon

# Copy the apk
cp bazel-bin/tensorflow/examples/android/tensorflow_demo.apk ../

# Fetch the apk to local machine
# scp -i "aws.pem" ubuntu@ec2-dns:/mnt/tmp/tensorflow_demo.apk .
# install the apk
# adb install tensorflow_demo.apk
