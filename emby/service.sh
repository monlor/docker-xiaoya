#!/bin/sh

# 1. 启动函数
start() {

  LD_LIBRARY_PATH=/lib:/system /system/EmbyServer -programdata /config -ffdetect /bin/ffdetect -ffmpeg /bin/ffmpeg -ffprobe /bin/ffprobe -restartexitcode 3 &
  echo "1" > /tmp/embyserver_status

}

# 2. 停止函数
stop() {

  killall -15 EmbyServer
  echo "0" > /tmp/embyserver_status

}

# 3. 进程守护函数
daemon() {

  while true; do
    if [ -z "$(pgrep EmbyServer)" ] && [ "$(cat /tmp/embyserver_status)" = "1" ]; then
      start
    fi
    sleep 5
  done

}

case $1 in
  start)
    start
    ;;
  stop)
    stop
    ;;
  daemon)
    daemon
    ;;
  *)
    echo "Usage: $0 {start|stop|daemon}"
    exit 1
    ;;
esac