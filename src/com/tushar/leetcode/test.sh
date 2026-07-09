#!/bin/bash
#
# Watches for cronJob.sh starting, then logs full CPU/Mem/Disk/ctxswitch
# stats for it and its children (main.py, send2cm.py) until it exits.

TARGET_PATTERN="cronJob.sh"
LOGDIR="/home/youruser/logs"
POLL_INTERVAL=0.3
SAMPLE_INTERVAL=1

mkdir -p "$LOGDIR"

echo "[$(date)] Watching for '$TARGET_PATTERN'..."

while true; do
    JOB_PID=$(pgrep -f "$TARGET_PATTERN" | grep -v "^$$" | head -n1)

    if [ -n "$JOB_PID" ]; then
        TS=$(date +'%Y%m%d_%H%M%S')
        LOGFILE="$LOGDIR/pidstat_${TS}.log"
        echo "[$(date)] Detected job (root PID $JOB_PID). Logging -> $LOGFILE"

        {
            echo "=== Monitoring started $(date), root PID=$JOB_PID ==="
            echo "--- SELF (cronJob.sh) + ALL child processes, sampled every ${SAMPLE_INTERVAL}s ---"

            # -T ALL = parent's own stats AND children's stats, in one stream
            pidstat -p "$JOB_PID" -T ALL -u -r -d -w -l "$SAMPLE_INTERVAL" \
                > /tmp/pidstat_$$.out 2>&1 &
            PIDSTAT_PID=$!

            wait "$JOB_PID" 2>/dev/null
            # process may not be our child, so poll instead of wait if that fails
            while kill -0 "$JOB_PID" 2>/dev/null; do
                sleep 0.2
            done

            kill "$PIDSTAT_PID" 2>/dev/null
            cat /tmp/pidstat_$$.out
            rm -f /tmp/pidstat_$$.out

            echo "=== Monitoring finished $(date) ==="
        } >> "$LOGFILE"

        echo "[$(date)] Job finished. Resuming watch..."
        sleep 2
    fi

    sleep "$POLL_INTERVAL"
done
