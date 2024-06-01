#!/bin/sh

# echo "等待alist启动完成..."
# while ! wget -q -T 1 -O /dev/null "${ALIST_ADDR:=http://alist:5678}" &> /dev/null; do
#     sleep 2
# done

# echo "等待元数据下载完成..."
# while test ! -f /config/emby_meta_finished; do
#     sleep 2
# done

cat > /etc/nsswitch.conf <<-EOF
hosts:  files dns
networks:   files
EOF

echo "开始自动更新alist地址..."
/update_alist_addr.sh &> /dev/null &

/start_emby.sh &> /dev/null &

start_command="/system/EmbyServer -programdata /config -ffdetect /bin/ffdetect -ffmpeg /bin/ffmpeg -ffprobe /bin/ffprobe -restartexitcode 3"

$start_command &

exec shell2http -port 8080 /stop "killall -15 EmbyServer" /start "LD_LIBRARY_PATH=/lib:/system ${start_command} &"

