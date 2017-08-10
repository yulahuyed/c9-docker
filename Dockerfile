FROM ubuntu:16.04

WORKDIR /shintech

RUN useradd --user-group --create-home --shell /bin/bash mike && \
 chown -R mike:mike /shintech && \
  apt-get update && apt-get install dialog curl apt-transport-https software-properties-common sudo python2.7 build-essential git wget xz-utils -y && \
  usermod -aG sudo mike && \
 printf "mike ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers && \ 
  wget https://nodejs.org/dist/v6.10.2/node-v6.10.2-linux-x64.tar.xz && \
  tar -xvf node-v6.10.2-linux-x64.tar.xz   && \
  cp -R node-v6.10.2-linux-x64/* /usr/local/ 

USER mike

RUN git clone https://github.com/c9/core.git && \
  npm --prefix /shintech/core install /shintech/core && \
  mkdir -p /home/mike/Development && \
  wget -O - https://raw.githubusercontent.com/c9/install/master/install.sh | bash  && \
  touch /home/mike/.hushlogin

CMD node /shintech/core/server.js -p 8001 -a : --listen 0.0.0.0 -w /home/mike/Development