# #!/bin/bash

# http://docs.bigchaindb.com/projects/server/en/latest/simple-network-setup.html

# creates tenderming files and priv_validator
tendermint init

# configure bigchaindb with all default params
bigchaindb  -y configure localmongodb

# copy stuff to shared docker volume
cp /root/.tendermint/config/priv_validator.json /data/priv_validator_$HOSTNAME.json
# node name
echo $(tendermint show_node_id) >> /data/nodeid_$HOSTNAME.txt
# genesis file is to be same, no need to differ it with hostnames
cp /root/.tendermint/config/genesis.json /data/genesis.json
# config to specify peers
cp /root/.tendermint/config/config.toml /data/config_$HOSTNAME.toml

# We need to wait a while to
echo "Waiting for copies to settle..."
sleep 10
# Lauch python script that is meant to work as "Coordinator" from instruction
python3 wrangle.py
# Wait till all scripts finish
sleep 10
# Copy modified configs back
cp /data/config_$HOSTNAME.toml /root/.tendermint/config/config.toml
cp /data/genesis.json /root/.tendermint/config/genesis.json
# Wait untill all containers finish
echo "Waiting for back-copies to settle..."
sleep 10

# make dir for mongodb 
mkdir data/db_$HOSTNAME

# start the zoo!
echo "Starting all the zoo..."
# start mongodb
mongod --fork --bind_ip 127.0.0.1 --logpath /data/mongodb_$HOSTNAME.log --dbpath /data/db_$HOSTNAME &
# start tendermint node
nohup tendermint node --proxy_app=kvstore & # 2>&1 > /data/tendermint_$HOSTNAME.log  &
# start bigchaingdb
nohup bigchaindb start & # 2>&1 > /data/bigchaindb_$HOSTNAME.log &
echo "Which seems to be pretty intense"
# wait untill all processes finish
# aka wait forever
wait    