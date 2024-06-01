#!/bin/bash

echo "等待emby.js创建完成..."
while ! test -f /etc/nginx/http.d/emby.js; do
    sleep 2
done

sed -i '/async function fetchXYApi/{:a;N;$!ba;d}' /etc/nginx/http.d/emby.js

cat >> /etc/nginx/http.d/emby.js <<-\EOF
async function fetchXYApi(xyurl) {
    xyurl = xyurl.replace(/ /g, '%20');
    try {
        const res = await ngx.fetch(xyurl, { headers: { 'Content-Type': 'application/json;charset=utf-8', "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.6045.160 Safari/537.36" }, max_response_body_size: 365535} );
        if (res.status == 302) {
            if (res.statusText == "Found") {
                return res.headers.Location;
            }
            return (`error: xy_api return 304 destination is null`);
        }
        else {
            return res.text();
        }
    }
    catch (error) {
        return (`error: xy_api fetch aliyun direct link failed,  ${error}`);
    }
}

export default { redirect2Pan };
EOF



echo "等待jellyfin.js创建完成..." 
while ! test -f /etc/nginx/http.d/jellyfin.js; do
    sleep 2
done

sed -i '/async function fetchXYApi/{:a;N;$!ba;d}' /etc/nginx/http.d/jellyfin.js
cat >> /etc/nginx/http.d/jellyfin.js <<-\EOF
async function fetchXYApi(xyurl) {
    xyurl = xyurl.replace(/ /g, '%20');
    try {
        const res = await ngx.fetch(xyurl, { headers: { 'Content-Type': 'application/json;charset=utf-8' }, max_response_body_size: 365535} );
        if (res.status == 302) {
            if (res.statusText == "Found") {
                return res.headers.Location;
            }
            return (`error: xy_api return 304 destination is null`);
        }
        else {
            return res.text();
        }
    }
    catch (error) {
        return (`error: xy_api fetch aliyun direct link failed,  ${error}`);
    }
}

export default { redirect2Pan };
EOF