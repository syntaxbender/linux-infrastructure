#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root! exiting..."
  exit 1
fi

DISABLE_COUNT=0
IS_RESET=false
CPU_COUNT=$(lscpu | grep "^CPU(s):" | awk '{print $2}')

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--disable)
      if [[ -n "$2" ]]; then
        DISABLE_COUNT="$2"
        shift
      else
        echo "Error: --domains requires a value."
        exit 1
      fi
      ;;
    -r|--reset)
      IS_RESET=true
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

if [[ "$DISABLE_COUNT" -eq 0 ]]; then
  if [[ "$IS_RESET" = false ]]; then
    echo "Error: --disable must be greater than 0."
    echo "Usage: [...] --disable 3"
    exit 1
  else
    for ((i=1; i<$CPU_COUNT; i++)); do
      echo "Enabled: $i"
      echo 1 > /sys/devices/system/cpu/cpu$i/online
    done
  fi
else
  let OFFLINE_CPU_START_OFFSET=$CPU_COUNT-$DISABLE_COUNT;
  let OFFLINE_CPU_END_OFFSET=$CPU_COUNT-1;
  for ((i=OFFLINE_CPU_START_OFFSET; i<=OFFLINE_CPU_END_OFFSET; i++)); do
    echo "Disabled: $i"
    echo 0 > /sys/devices/system/cpu/cpu$i/online
  done
fi

if [[ "$DISABLE_COUNT" -ge "$CPU_COUNT" ]]; then
    echo "Error: --disable must be less than $(nproc)."
    echo "Usage: [...] --disable 3"
    exit 1
fi
