#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;
use DBI;

my $db = "db";
my $user = "username";
my $pass = "user_pass";
my $host = "host";
# Connecting to DB
my $dbh = DBI->connect("DBI:mysql:$db:$host", $user, $pass);
# Getting list of mailboxes with it's quotas
my $quota_query = "SELECT `username`,`quota`,`domain` FROM `mailbox`";
my $sqlQuotaQuery = $dbh->prepare($quota_query)
    or die "Can't prepare $quota_query: $dbh->errstr\n";
my $rv = $sqlQuotaQuery->execute
    or die "can't execute the query: $sqlQuotaQuery->errstr";

while (my @row = $sqlQuotaQuery->fetchrow_array()) {
    my $username = $row[0];
    my $quota = $row[1];
    my $domain = $row[2];
    # Getting used quota for each mailbox
    my $used_quota_query = "select `bytes` from `used_quota` where (`username` = '$username' and `domain` = '$domain')";
    my $sqlUsedQuotaQuery = $dbh->prepare($used_quota_query)
        or die "Can't prepare $used_quota_query: $dbh->errstr\n";
    my $rv2 = $sqlUsedQuotaQuery->execute
        or die "can't execute the query: $sqlUsedQuotaQuery->errstr";
    my @used_quota_row = $sqlUsedQuotaQuery->fetchrow_array();
    my $rc = $sqlUsedQuotaQuery->finish;
    my $used_quota = 0;
    if (defined($used_quota_row[0])) {
        $used_quota = $used_quota_row[0];
    }
    # Calculating remaining quota space
    my $diff = ($quota * 1000000) - $used_quota;
    # Calculating percentage of free quota
    my $diff_p = sprintf("%.2f", ($used_quota * 100) / ($quota * 1000000));
    # Alert if quota is used over 90%
    if ($diff_p >= 90) {
        my $diff = sprintf("%.2f", $diff / 1000000);
        my $used_quota = sprintf("%.2f", $used_quota / 1000000);
        print "$username : $diff_p%! [$used_quota / $quota MB]\n";
    }
}
#Closing queries and disconnecting
my $rc = $sqlQuotaQuery->finish;
$rc = $dbh->disconnect;
# Checking remaining free disk space on server. I use /dev/sda1 as storage, so I grep by sda1
my $out = `df -h | grep sda1`;
my @parts = split(' ', $out);
my @parts2 = split('%', $parts[4]);
my $free_space = 100 - $parts2[0];
print "-------------------\n";
print "Free disk space: $free_space% ($parts[3] / $parts[1]) \n";
exit(0);
