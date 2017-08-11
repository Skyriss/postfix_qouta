# postfix_qouta
get_quotas.pl - Perl script for getting and analyzing postfix quota data. Usage stats is being taken from database.
get_quotas_du.pl - Perl script for getting and analyzing postfix quota data. Usage stats is being taken from file system (_get_quotas.sh).

_get_quotas.sh - Bash script for getting size of a user's mailbox folder.
check_quota.sh - Bash script for sending results of get_quotas.pl or get_quotas_du.pl by Telegram bot.

BEFORE USAGE:
If you have 'used_quota' table in your postfix database -> 
	In get_quotas.pl replace values of $db, $user, $pass, $host with the correct ones. 
	In check_quota.sh replace values of TOKEN and CHAT_ID with the correct ones.

If you don't have 'used_quota' table in your postfix database -> 
	In get_quotas_du.pl replace values of $db, $user, $pass, $host with the correct ones. 
	In _get_quotas.sh check vmail folder.
	In check_quota.sh replace values of TOKEN and CHAT_ID with the correct ones.
	In check_quota.sh replace name of script with get_quotas_du.sh.


USAGE:

With sending result to Telegram:
	bash check_quota.sh

With sending result to Console:
If you have 'used_quota' table in your postfix database -> 
	perl get_quotas.pl
	
If you don't have 'used_quota' table in your postfix database -> 
	perl get_quotas_du.pl
