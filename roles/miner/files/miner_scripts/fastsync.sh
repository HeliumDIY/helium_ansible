#!/usr/bin/env bash
./height-helper.sh
snap_height=$(wget -q https://helium-snapshots.nebra.com/latest.json -O - | grep -Po '\"height\": [0-9]*' | sed 's/\"height\": //')
wget https://helium-snapshots.nebra.com/snap-$snap_height -O /home/pi/miner_data/snap/snap-latest
docker exec miner miner repair sync_pause
docker exec miner miner repair sync_cancel
docker exec miner miner snapshot load /var/data/snap/snap-latest
sleep 5
docker exec miner miner repair sync_resume
