FROM ubuntu:16.04

WORKDIR /shintech

COPY bashrc.txt .

RUN useradd --user-group --create-home --shell /bin/bash mike && \
  chown -R mike:mike /shintech && \
  
  apt-get update && apt-get install build-essential software-properties-common apt-transport-https curl -y && \
  apt-get update && apt-get install wget xz-utils git -y && \
  
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  
  apt-get update && apt-get install sudo python2.7 git wget xz-utils sl git autofs sshfs vim postgresql git-core zlib1g-dev libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libpq-dev pv toilet rig libaa-bin unzip python-pip nmap whois make ftp ftpd netdiscover libmysqlclient-dev redis-server htop moreutils ruby2.3 ruby2.3-dev dstat slurm iftop iptraf calcurse vifm ranger cloc yarn httpie python3-pip -y && \
  
  usermod -aG sudo mike && \
  printf "mike ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers && \
  
  wget https://nodejs.org/dist/v6.10.2/node-v6.10.2-linux-x64.tar.xz && \
  tar -xvf node-v6.10.2-linux-x64.tar.xz   && \
  cp -R node-v6.10.2-linux-x64/* /usr/local/
  
USER mike

COPY aliases.txt $HOME/.bash_aliases

RUN mkdir -p $HOME/opt/bin && \
  mkdir -p $HOME/Development && \
  ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -q -N "" -C ${EMAIL} && \

  git clone https://github.com/c9/core.git && \
  npm --prefix /shintech/core install /shintech/core && \
  wget -O - https://raw.githubusercontent.com/c9/install/master/install.sh | bash  && \
  
  git clone https://github.com/mprather1/random-ps1 && \
  cp random-ps1/bashrc.txt . && \
  npm --prefix ./random-ps1/ install random-ps1/ && \
  HOME=$HOME node random-ps1 /shintech && \
  
  touch $HOME/.hushlogin

COPY styles.css $HOME/.c9/styles.css
COPY project.settings $HOME/.c9/project.settings
COPY user.settings $HOME/.c9/user.settings

CMD node /shintech/core/server.js -p 8080 -a ${USERNAME}:${PASSWORD} --listen 0.0.0.0 -w $HOME/Development