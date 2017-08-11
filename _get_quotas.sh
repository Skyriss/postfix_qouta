#!/bin/sh
# Replace /var/vmail/vmail1 with your folder with mailboxes!
if ! [ -d /var/vmail/vmail1/$1 ]; 
	du -s /var/vmail/vmail1/$1
fi
