FROM ubuntu:16.04

WORKDIR /shintech

COPY . .

RUN useradd --user-group --create-home --shell /bin/bash mike && \
 chown -R mike:mike /shintech && \
 apt-get update && apt-get install git wget xz-utils -y && \
  wget https://nodejs.org/dist/v6.10.2/node-v6.10.2-linux-x64.tar.xz && \
  tar -xvf node-v6.10.2-linux-x64.tar.xz   && \
  cp -R node-v6.10.2-linux-x64/* /usr/local/

USER mike

RUN git clone https://github.com/c9/core.git && \
  npm --prefix /shintech/core install /shintech/core 
  
# CMD npm --prefix /shintech/core start

CMD node /shintech/core/server.js -p 8080 -a : --listen 0.0.0.0 