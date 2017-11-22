FROM ubuntu:16.04

RUN useradd --user-group --create-home --shell /bin/bash core

WORKDIR /home/core

COPY bashrc.txt .

RUN \
  printf "Installing software with apt...\n" && \
  
  apt-get update && apt-get install build-essential software-properties-common apt-transport-https curl -y && \
  
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  
  apt-get update && apt-get install sudo python2.7 git wget xz-utils sl git autofs sshfs nano vim python-software-properties pv toilet rig unzip python-pip nmap whois make ftp ftpd netdiscover htop moreutils ruby2.3 ruby2.3-dev dstat slurm iftop iptraf calcurse vifm ranger cloc yarn httpie python3-pip -y

RUN \
  add-apt-repository -y ppa:jonathonf/ffmpeg-3 && \
  apt-get update && apt install -y ffmpeg libav-tools x264 x265 screen unar iputils-ping openssl && \
  wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl && \
  chmod a+rx /usr/local/bin/youtube-dl && \
  pip install git+https://github.com/shadowsocks/shadowsocks.git@master && \
  wget -O /usr/local/bin/ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && \
  unzip /usr/local/bin/ngrok.zip -d /usr/local/bin && \
  /usr/local/bin/ngrok authtoken 6c4SjMbk8Kikuo9r1apHM_4LSU7nsz5SzjW7FqEG8Ro && \
  echo "nohup /usr/local/bin/ssserver -p 3600 -k yhiblog -m aes-256-gcm >/dev/null 2>&1 &" >> /etc/rc.local && \
  echo "nohup /usr/local/bin/ngrok tcp 3600 >/dev/null 2>&1 &" >> /etc/rc.local

RUN \
  wget https://nodejs.org/dist/v6.10.2/node-v6.10.2-linux-x64.tar.xz && \
  tar -xvf node-v6.10.2-linux-x64.tar.xz   && \
  cp -R node-v6.10.2-linux-x64/* /usr/local/ && \
  
  wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 && \
  chmod +x /usr/local/bin/dumb-init
  
RUN \
  usermod -aG sudo core && \
  printf "core ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers
  
USER core

COPY aliases.txt ./.bash_aliases

RUN \
  printf "config\n" && \
  
  mkdir -p $HOME/opt/bin && \
  touch $HOME/.hushlogin && \
  mkdir $HOME/Development && \
  ssh-keygen -b 4096 -t rsa -f $HOME/.ssh/id_rsa -q -N ""

RUN \
  printf "bashrc configration...\n" && \
  
  git clone https://github.com/mprather1/random-ps1 && \
  sudo chown -R core:core /home/core/bashrc.txt && \
  cp random-ps1/bashrc.txt . && \
  npm --prefix ./random-ps1/ install random-ps1/ && \
  HOME=$HOME node random-ps1 $HOME
  
RUN \
  printf "Install custom packages...\n" && \
  
  git -C $HOME clone https://github.com/shintech/git-status && \
  printf "HOME=\$HOME node $HOME/git-status/index.js \$(pwd) \$1" > $HOME/opt/bin/git-status && \
  chmod +x $HOME/opt/bin/git-status && \
  npm --prefix ./git-status/ install git-status/ && \
  
  git -C $HOME clone https://github.com/shintech/npm-updater && \
  printf "HOME=\$HOME node $HOME/npm-updater/index.js \$(pwd) \$1" > $HOME/opt/bin/npm-updater && \
  chmod +x $HOME/opt/bin/npm-updater && \
  npm --prefix ./npm-updater/ install npm-updater/
  
RUN \
  wget -O $HOME/Development/aria2.tar.bz2 https://github.com/xzl2021/aria2-static-builds-with-128-threads/releases/download/v1.32.0/aria2-1.32.0-linux-gnu-64bit-build1.tar.bz2 && \
  tar jxvf $HOME/Development/aria2-1.32.0-linux-gnu-64bit-build1.tar.bz2 && \
  nohup /usr/local/bin/ssserver -p 3600 -k yhiblog -m aes-256-gcm >/dev/null 2>&1 & && \
  nohup /usr/local/bin/ngrok tcp 3600 >/dev/null 2>&1 &
  
RUN \
  printf "Installing Cloud9...\n" && \
  
  git -C $HOME clone https://github.com/c9/core.git  && \
  npm --prefix $HOME/core install $HOME/core && \
  wget -O - https://raw.githubusercontent.com/c9/install/master/install.sh | bash

RUN \
  printf 'Clean Up...\n' && \
  
  sudo rm -vfr $HOME/node-v6.10.2-linux-x64 $HOME/node-v6.10.2-linux-x64.tar.xz $HOME/bashrc.txt

CMD dumb-init node $HOME/core/server.js -p $PORT -a ${USERNAME}:${PASSWORD} --listen 0.0.0.0 -w $HOME/Development
