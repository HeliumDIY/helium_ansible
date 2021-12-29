#!/usr/bin/env bash
./height-helper.sh
snap_height=$(curl -s https://helium-snapshots.nebra.com/latest.json | jq .height)
docker exec miner wget https://helium-snapshots.nebra.com/snap-${snap_height} -O /var/data/snap/snap-${snap_height}.scratch
docker exec miner mv /var/data/snap/snap-${snap_height}.scratch /var/data/snap/snap-${snap_height}
docker exec miner miner repair sync_pause
docker exec miner miner repair sync_cancel
docker exec miner miner snapshot load /var/data/snap/snap-${snap_height}
sleep 5
docker exec miner miner repair sync_resume
