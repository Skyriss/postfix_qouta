#!/bin/sh
# Replace 3333333:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA with your Telegram bot token
TOKEN='3333333:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
# Replace 111111111 with your client_id
CHAT_ID="111111111"
SUBJECT="Mailbox quotas check"
RESULT=$(perl get_quotas.pl)

curl -s --header 'Content-Type: application/json' --request 'POST' --data "{\"chat_id\":\"${CHAT_ID}\",\"text\":\"${SUBJECT}\n${RESULT}\"}" "https://api.telegram.org/bot${TOKEN}/sendMessage" | grep -q '"ok":false,'
if [ $? -eq 0 ] ; then exit 1 ; fi

