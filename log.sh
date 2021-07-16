#!/bin/bash
superhubAddress=$1
gelfAddress=$2
gelfPort=$3
hubTimezone=${4:-"Europe/London"}

jsonBaseKey="1.3.6.1.2.1.69.1.5.8.1."
jsonKeySuffixDate="2"
jsonKeySuffixLevel="5"
jsonKeySuffixMessage="7"

status=$(curl -sb -H "Accept: application/json" "http://$superhubAddress/getRouterStatus?_n=02521&_=1627433543015")
dateKeys=($(jq -r --arg KEY "$jsonBaseKey$jsonKeySuffixDate" 'to_entries | map(select(.key | match($KEY))) | map(.key) | .[] | @sh' <<< "$status")) 

if [ -f "last-log" ]; then
    lastLog=$(cat last-log)
else
    lastLog=0
fi

for i in "${dateKeys[@]}"
do

    eval DATEKEY=$i # removes single quotes from $i
    date=$(jq -r --arg DATEKEY $DATEKEY '.[$DATEKEY]' <<< "$status")
    # convert date to epoch using timezone of the superhub, and yyyy/mm/dd format
    date=$(TZ=$hubTimezone date --date "$(echo "$date" | awk -F[/\ ] '{print $3"/"$2"/"$1" "$4}')" +"%s")

    if (($date > $lastLog)); then

        level=$(jq -r --arg DATEKEY ${DATEKEY/"$jsonBaseKey$jsonKeySuffixDate"/"$jsonBaseKey$jsonKeySuffixLevel"} '.[$DATEKEY]' <<< "$status")
        message=$(jq -r --arg DATEKEY ${DATEKEY/"$jsonBaseKey$jsonKeySuffixDate"/"$jsonBaseKey$jsonKeySuffixMessage"} '.[$DATEKEY]' <<< "$status")

        echo "FOUND: $(date -d @$date) $level $message"

        read -r -d '' gelf <<EOF
        {
            "version": "1.0",
            "host": "$superhubAddress",
            "short_message": "${message}",
            "timestamp": ${date},
            "level": ${level},
            "facility": "kernel"
        }
EOF

        # send to log server
        echo "${gelf}"| gzip -c -f - | nc -w 1 -u $gelfAddress $gelfPort
        echo $date > last-log
        lastLog=$date
    fi

done

