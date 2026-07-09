#!/bin/bash

TARGET="cronJob.sh"
LOG_DIR="/tmp/test_cn_sur/log"
mkdir -p "$LOG_DIR"

echo "Watching for $TARGET..."

while true
do
    JOB_PID=$(pgrep -n -f "$TARGET")

    if [ -n "$JOB_PID" ]; then
        TS=$(date +"%Y%m%d_%H%M%S")
        PIDSTAT_LOG="$LOG_DIR/pidstat_${TS}_${JOB_PID}.log"

        echo "[$(date)] Detected job PID: $JOB_PID"
        echo "Logging to: $PIDSTAT_LOG"

        pidstat -p "$JOB_PID" -T ALL -u -r -d -w -l 1 >> "$PIDSTAT_LOG" 2>&1 &
        PIDSTAT_PID=$!

        while kill -0 "$JOB_PID" 2>/dev/null
        do
            sleep 0.2
        done

        kill "$PIDSTAT_PID" 2>/dev/null
        wait "$PIDSTAT_PID" 2>/dev/null

        echo "[$(date)] Job finished. Waiting for next run..."

        # avoid detecting same old PID repeatedly
        sleep 5
    fi

    sleep 0.2
done
