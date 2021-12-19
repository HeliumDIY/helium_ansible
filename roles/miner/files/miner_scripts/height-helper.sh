#!/usr/bin/env bash
MINER_HEIGHT=$(curl -d '{"jsonrpc":"2.0","id":"id","method":"block_height","params":[]}' -s -o - http://localhost:4467/ | jq .result.height)
STAKEJOY_API_URL="https://helium-api.stakejoy.com"
#HELIUM_API_URL="https://api.helium.io"
BLOCKCHAIN_HEIGHT=$(curl -s -A "Wget/1.12 (linux-gnu)" $STAKEJOY_API_URL/v1/blocks/height | jq '.data.height')
NEBRA_SNAPSHOT=$(wget -q https://helium-snapshots.nebra.com/latest.json -O - | grep -Po '\"height\": [0-9]*' | sed 's/\"height\": //')
SYNC_PERCENTAGE=$(echo "scale=2; ($MINER_HEIGHT / $BLOCKCHAIN_HEIGHT)*100" | bc)
BLOCKS_TO_SYNC=$(echo "scale=2; ($BLOCKCHAIN_HEIGHT - $MINER_HEIGHT)" | bc)
echo "Latest Snapshot: $NEBRA_SNAPSHOT"
echo "Blockchain Height: $MINER_HEIGHT/$BLOCKCHAIN_HEIGHT - $SYNC_PERCENTAGE%"
if [ "$BLOCKS_TO_SYNC" -lt 0 ]; then
    echo "Ahead of ETL by $BLOCKS_TO_SYNC blocks"
elif [ "$BLOCKS_TO_SYNC" -gt 0 ]; then
    echo "Behind of ETL by $BLOCKS_TO_SYNC blocks"
else
    echo "Synced"
fi
