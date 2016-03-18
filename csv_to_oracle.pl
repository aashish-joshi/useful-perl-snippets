use strict;
use warnings;
use Text::CSV;
use DBI;
use MIME::Lite;

#open the csv file
open my $fh,"<",'sample.csv';

my $csv = Text::CSV->new({binary => 1, auto_diag => 1, allow_whitespace => 1});

# skip the first line that contains the column names
# if your CSV does not contain any headers then
# comment the line below
my $junk = <$fh>;

# connect to the database.
# depending on the type of DB
# you're using the connect string
# will vary. Read CPAN for more info.

# get the SID from your DBA and 
# enter that instead of XE.
# for express edition the SID is XE
my $db_string = 'DBI:Oracle:XE';

# connect to the database or report error
# $db_username & $db_password need to be set
# to real values. if you don't know this
# ask your DBA or read the documentation!!
my $db_username = 'scott';
my $db_password = 'tiger';

my $dbh = DBI->connect($db_string, $db_username, $db_password) or report_error("Couldn't connect to database! in $0 at line ".__LINE__,DBI->errstr);

# prepare the insert statement.
# in the line below each '?' represents
# a value that will be passed
# by the script.
my $sth = $dbh->prepare('INSERT INTO TABLE_NAME (column1,column2,column3) VALUES (?,?,?)') or report_error("Couldn't prepare insert statement! in $0 at line ".__LINE__,DBI->errstr);

# now, we read the csv line-by-line
# and insert selected columns into the database
# you'll need to identify what columns
# you have to insert.for the sample csv
# i'll upload the first, second and fourth colums only
# note that Perl starts the column numbering
# from 0.

my $line;

while ($line = $csv->getline($fh)){

	$sth->execute($line->[0],$line->[1],$line->[3]) or report_error("Problem with script $0 at line ".__LINE__,"Values:\n".$line->[0],$line->[1],$line->[3]."\nDB Error:\n\n".DBI->errstr);

}

# close the csv file opened at the start
close $fh;

##################################################################################
#
#	THE ERROR REPORTING SUB-ROUTINE IS DEFINED BELOW. IT TAKES 2 VARIABLES:
#	1. THE FIRST ONE IS THE SUBJECT OF THE EMAIL
#	2. THE SECOND ONE IS THE BODY.
#
#	IT ACCEPTS HTML AS WELL, ALTHOUGH IT SHOULD BE USED SPARINGLY TO ENSURE
#	YOUR MAIL ISN'T INCORRECTLY MARKED AS SPAM.
#
##################################################################################

sub report_error {
	
	my $err_msg = MIME::Lite->new(
					From    => 'from@domain.com',
					To      =>'to1@domain.com,to2@domain.com',
					Subject =>$_[0],
					Type    =>'multipart/related'
					);
	$err_msg->attach(
					Type => 'text/html',
					Data => $_[1]
					);

	# enter your email username & password here
	# AuthUser is the username that you use to sign in to email clients
	# domain should be the SMTP domain
	MIME::Lite->send(
					'smtp',
					"domain.com",
					Timeout=>60,
					AuthUser=>'email_username',
					AuthPass=>'password'
					);
	$err_msg->send();
	exit;
}

