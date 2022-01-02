#!/usr/bin/env bash
MINER_HEIGHT=$(curl -d '{"jsonrpc":"2.0","id":"id","method":"block_height","params":[]}' -s -o - http://localhost:4467/ | jq .result.height)
SNAP_HEIGHT=$(curl -s https://helium-snapshots.nebra.com/latest.json | jq .height)
if [ "${MINER_HEIGHT}" -lt "${SNAP_HEIGHT}" ] ; then
        echo "Downloading snapshot ${SNAP_HEIGHT}"
        docker exec miner wget https://helium-snapshots.nebra.com/snap-${SNAP_HEIGHT} -O /var/data/snap/snap-${SNAP_HEIGHT}
        docker exec miner miner repair sync_pause
        docker exec miner miner repair sync_cancel
        docker exec miner miner snapshot load /var/data/snap/snap-${SNAP_HEIGHT}
        sleep 5
        docker exec miner miner repair sync_resume
else
        echo "Current miner height of ${MINER_HEIGHT} greater than the latest snapshot at ${SNAP_HEIGHT}"
        exit 1
fi

