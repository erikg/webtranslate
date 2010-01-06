#!/usr/bin/perl

# import.pl for the webtranslate package
# Copyright (C) 2000-2010 Erik Greenwald <erik@smluc.org>
# released under the GPL v2 (or better). 
# This software comes with absofrikkinlutely no warrenty of any kind.
#
# this file creates an initial entry in the database for a package. When
# you run it, it requests your name, email, program name, and version
# theoretically you only run this once per package...

use DBI;

require 'webtranslate.conf';

my $sth;
my @data;

my $refs = "";
my $flags = "";
my $msgid = "";
my $msgstr = "";
my $id = 0;

my $action=0;

my $dbh = DBI->connect("DBI:$DBMSTYPE:$DBMSDB;host=$DBMSHOST;port=$DBMSPORT", $DBMSUSER, $DBMSPASSWD)
	or die "no db\n";

sub addtodb
{
	$sth = $dbh->prepare("insert into messages values ($id,'$refs','$flags','$msgid','$msgstr')")
        	or die "couln't add vote\n";
	$sth->execute();
	$sth->finish();
	return;
}

if($#ARGV!=0)
{
	print "\n\tUsage: import.pl <file.pot>\n";
	exit 1;
}

open(POT,$ARGV[0])
	or die "Can't open $ARGV[0]\n";

print "Your name: ";
$name = <STDIN>;
print "Your email: ";
$email = <STDIN>;
print "Program name: ";
$progname = <STDIN>;
print "Version: ";
$version = <STDIN>;

chomp $name;
chomp $email;
chomp $progname;
chomp $version;

$sth = $dbh->prepare("insert into session values (0,'$name','$email',NOW(),NOW(),'$progname','$version','C','C',NULL,NULL,'$email')")
        or die "couln't add vote\n";
$sth->execute();
$sth->finish();

$sth = $dbh->prepare("select LAST_INSERT_ID()")
	or die "Couldn't grok last()\n";
$sth->execute();
@data = $sth->fetchrow_array();
$id = $data[0];
$sth->finish();

# read each line of the pot file
while(<POT>)
{
	chomp $_;
	if( /^\#[^:,]/ || /^\#$/ )
	{
		# ignore
	} 
	elsif( /^[ \t]*$/ )
	{
		if($flags ne "fuzzy")
		{
				# push message into db...
			addtodb($refs,$flags,$msgid,$msgstr);
		}
		$refs="";
		$flags="";
		$msgid="";
		$msgstr="";
	}
	elsif( /^\#:/ )
	{
		$_ =~ s/^\#: //;
		$refs = $_;
	}
	elsif( /^\#,/ )
	{
		$_ =~ s/^\#, //;
		$flags = $_;
	}
	elsif ( /^msgid/ )
	{
		$_ =~ s/^msgid "//;
		$_ =~ s/"$//;
		$_ =~ s/\\/\\\\/g;
		$msgid = $_;
		$action = 1;
	}
	elsif (/^msgstr/)
	{
		$_ =~ s/^msgstr "//;
		$_ =~ s/"$//;
		$_ =~ s/\\/\\\\/g;
		$msgstr = $_;
		$action = 2;
	}
	elsif (/^".*"/)
	{
		# append
		$_ =~ s/^"//;
		$_ =~ s/"$//;
		$_ =~ s/\\/\\\\/g;
		if($action == 1)
		{
			$msgid=$msgid.$_;
		}
		elsif($action == 2)
		{
			$msgstr=$msgstr.$_;
		}
		else
		{
			print "Whoa, I don't know what to do with this line:\n$_";
		}
	}
	else
	{
		print "Unknown error reading this line:\n$_\n\n";
		exit 1;
	}
}

if($flags ne "fuzzy")
{
		# push message into db...
	addtodb($refs,$flags,$msgid,$msgstr);
}

print ("$progname $version successfully added to the database.\n");

$dbh->disconnect();
exit 0;

