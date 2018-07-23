import os
import json
import platform
import toml

nodename = platform.node()

# just follows the instruction at 
# http://docs.bigchaindb.com/projects/server/en/latest/simple-network-setup.html

# scripts should have all files available in the /data dir


# get priv_validator.json files
files = os.listdir('data')
fls = []
for file in files:
    if 'validator' in file and nodename not in file:
        handle = open("data/" + file)
        machine_name = file.split("_")[2].split('.')[0]
        content = handle.read()
        j = json.loads(content)
        fls.append((j, machine_name))
        handle.close()


# get genesis.json file
genesis = None
with open('data/genesis.json') as foo:
    genesis = foo.read()
    genesis = json.loads(genesis)

# we need to combine all priv_validator pub_keys to genesis validators
validators = []
for file in fls:
    x = {}
    x['pub_key'] = file[0]['pub_key']
    x['power'] = '10'
    x['name'] = file[1]
    validators.append(x)
    
genesis['validators']=validators
# write file back
with open('data/genesis.json', 'w') as foo:
    foo.write(json.dumps(genesis, indent=4))

# get peers from node_ files
peers = []
for file in os.listdir('data'):
    if 'nodeid' in file and nodename not in file:
        handle = open('data/' + file)
        mn = file.split("_")[1].split('.')[0]
        peers.append( (handle.read(), mn))
        handle.close()
        

# make peers strings
persistent_peers = []
for peer in peers:    
    persistent_peer = peer[0].strip() + "@" + peer[1].strip() + """:26656,"""
    persistent_peer = persistent_peer.strip()
    persistent_peers.append(persistent_peer)

# join strings, remove last comma
res = "".join(persistent_peers)[:-1]

# modify toml configs
for file in os.listdir('data'):
    if '.toml' in file and nodename not in file:
        conf = toml.load('data/' + file)
        conf['consensus']['create_empty_blocks']=False
        conf['p2p']['addr_book_strict']=False
        conf['p2p']['seeds'] = res
        conf['p2p']['private_peers'] = res
        handle = open('data/' + file, 'w')
        toml.dump(conf, handle)
        handle.close()