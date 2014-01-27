#!/bin/bash
SERENVERSION="seren-0.0.17"
FILENAME=$SERENVERSION".tar.gz"
CONFERENCEIP=192.168.1.20

echo "installing dependencies..."
apt-get install build-essential libasound2-dev libogg-dev libncurses5-dev libncursesw5-dev

echo "installing libopus (fixed point)..."
mkdir src
cd src
wget http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz
tar xvf opus-1.1.tar.gz
cd opus-1.1/
./configure --enable-fixed-point
make
make install
ldconfig
cd ../..

echo "downloading seren..."
URL="http://holdenc.altervista.org/seren/downloads/"$FILENAME
echo "Download URL: "$URL
wget $URL

echo "unpacking seren..."
tar -zxvf $FILENAME
echo "configuring and installing seren"
cd $SERENVERSION
./configure
make
make install
cd ..

echo "creating scripts..."
echo "#!/bin/bash" > callIP
echo "echo \"connecting to voice conference on \"\$1" >> callIP
echo "/home/pi/suit/"$SERENVERSION"/seren -C0 -s -N -c \$1 -n pi -d plug:front:Set > callIP.out" >> callIP
echo "#!/bin/bash" > initCall
echo "/home/pi/suit/startVoice" >> initCall
echo "#!/bin/bash" > joinCall
echo "/home/pi/suit/callIP $CONFERENCEIP" >> joinCall
echo "#!/bin/bash" > startVoice
echo "echo \"running voice conference initialization script\"" >> startVoice
echo "/home/pi/suit/joinCall" >> startVoice

echo "setting permissions..."
chmod 755 initCall
chmod 755 startVoice
chmod 755 joinCall
chmod 755 callIP

echo "setting up init.d..."
cp initCall /etc/init.d

echo "Configuration complete. To set up running at boot, add the following line to rc.local:"
echo "nohup /etc/init.d/initCall &"

