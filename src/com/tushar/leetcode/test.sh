#!/bin/bash

LOG_DIR="/data/project/logs/performance"
mkdir -p "$LOG_DIR"

TS=$(date +"%Y%m%d_%H%M%S")
RUN_LOG="$LOG_DIR/run_${TS}.log"
PIDSTAT_LOG="$LOG_DIR/pidstat_${TS}.log"
TIME_LOG="$LOG_DIR/time_${TS}.log"
SAR_LOG="$LOG_DIR/server_${TS}.log"

echo "Job started at: $(date)" >> "$RUN_LOG"

# Monitor full server CPU/memory while job is running
sar -u -r 1 >> "$SAR_LOG" 2>&1 &
SAR_PID=$!

run_and_monitor() {
    JOB_NAME="$1"
    shift

    echo "Starting $JOB_NAME at: $(date)" >> "$RUN_LOG"

    # Start actual command in background
    /usr/bin/time -v "$@" >> "$RUN_LOG" 2>> "$TIME_LOG" &
    JOB_PID=$!

    echo "$JOB_NAME PID: $JOB_PID" >> "$RUN_LOG"

    # Monitor CPU, memory, disk I/O, context switch every 1 second
    pidstat -p "$JOB_PID" -u -r -d -w -l 1 >> "$PIDSTAT_LOG" 2>&1 &
    MON_PID=$!

    wait "$JOB_PID"
    EXIT_CODE=$?

    kill "$MON_PID" 2>/dev/null
    wait "$MON_PID" 2>/dev/null

    echo "$JOB_NAME finished at: $(date) with exit code: $EXIT_CODE" >> "$RUN_LOG"

    return "$EXIT_CODE"
}

run_and_monitor "main.py" python3 /path/to/main.py
MAIN_EXIT=$?

run_and_monitor "send2cm.py" python3 /path/to/send2cm.py
SEND_EXIT=$?

kill "$SAR_PID" 2>/dev/null
wait "$SAR_PID" 2>/dev/null

echo "Job completed at: $(date)" >> "$RUN_LOG"

if [ "$MAIN_EXIT" -ne 0 ] || [ "$SEND_EXIT" -ne 0 ]; then
    exit 1
fi

exit 0
