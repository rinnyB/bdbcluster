FROM ubuntu:18.04

# update and install all dependencies
RUN apt-get update
RUN apt-get -y full-upgrade 
RUN apt-get install -y python3-pip
RUN apt-get install -y libssl-dev
RUN apt-get install -y mongodb
RUN apt-get install -y unzip
RUN apt-get install -y wget
# if we want to curl within containers
RUN apt-get install -y curl

# get tendermint
RUN wget https://github.com/tendermint/tendermint/releases/download/v0.22.3/tendermint_0.22.3_linux_amd64.zip && \
unzip tendermint_0.22.3_linux_amd64.zip && \
rm tendermint_0.22.3_linux_amd64.zip && \
mv tendermint /usr/local/bin

# install bigchaindb
RUN pip3 install bigchaindb==2.0.0b3
# lib to parse configs.toml
RUN pip3 install toml

EXPOSE 22/tcp
EXPOSE 9984/tcp
EXPOSE 9985/tcp
EXPOSE 26656/tcp
EXPOSE 26658/tcp

# make folder for volume
RUN mkdir -p data
# copy scripts
COPY start.sh start.sh
RUN chmod +x start.sh
COPY wrangle.py wrangle.py
ENTRYPOINT ./start.sh
