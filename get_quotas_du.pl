#!/usr/bin/perl -w
use strict;
use warnings;
use File::Find;
use Data::Dumper;
use DBI;

my $db = "db";
my $user = "username";
my $pass = "user_pass";
my $host = "host";
# Connecting to DB
my $dbh = DBI->connect("DBI:mysql:$db:$host", $user, $pass);
# Getting list of mailboxes with it's quotas
my $query = "SELECT`username`,`maildir`,`quota`,`domain` FROM `mailbox`";
my $sqlQuery = $dbh->prepare($query)
    or die "Can't prepare $query: $dbh->errstr\n";

my $rv = $sqlQuery->execute
    or die "can't execute the query: $sqlQuery->errstr";

while (my @row = $sqlQuery->fetchrow_array()) {
    my $username = $row[0];
    my $maildir = $row[1];
    my $quota = $row[2];
    my $domain = $row[3];
    # Getting used quota for each mailbox
    my $out = `du -s /var/vmail/vmail1/$maildir 2>&1`;
    if ($out) {
        my @parts = split(' ', $out);
        if ($parts[0] eq "du:") {
            #print "$maildir does not exist!\n"; #Spams for new accounts. Use only 4 debug
        } else {
            my $used_quota = 0;
            if (defined($parts[0])) {
                $used_quota = $parts[0];
            }
            # Calculating remaining quota space
            my $diff = ($quota * 1000) - $used_quota;
            # Calculating percentage of free quota
            my $diff_p = sprintf("%.2f", ($used_quota * 100) / ($quota * 1000));
            # Alert if quota is used over 90%
            if ($diff_p >= 90) {
                my $diff = sprintf("%.2f", $diff / 1000000);
                my $used_quota = sprintf("%.2f", $used_quota / 1000000);
                print "$username : $diff_p%! [$used_quota / $quota MB]\n";
            }
        }
    }
}
#Closing queries and disconnecting
my $rc = $sqlQuery->finish;
$rc = $dbh->disconnect;
# Checking remaining free disk space on server. I use /dev/sda1 as storage, so I grep by sda1
my $out = `df -h | grep sda1`;
my @parts = split(' ', $out);
my @parts2 = split('%', $parts[4]);
my $free_space = 100 - $parts2[0];
print "-------------------\n";
print "Free disk space: $free_space% ($parts[3] / $parts[1]) \n";

exit(0);
