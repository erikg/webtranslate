<?php


require 'webtranslate.inc';	/* the config file for the php3 version. */

/* the Content-type is automagically generated, no need for us to do it */
include 'webtranslate.header';	/* throw the header out first thing. */

/* fake abstraction of the database. PHP3 really should have a generic database
 * interface like perl or java. This kinda kludge blows. */

$host = "www.dynsol.net";
$port = "3306";
$user = "translator";
$passwd = "gibberwalkie";
$db = "gettext";

/* */
function db_connect($host, $port, $db, $user, $passwd)
{
	$link = mysql_connect("$host:$port","$user", "$passwd")
		or die ("Couldn't connect to MySQL database.\n");
	mysql_select_db($db, $link)
		or die ("Couldn't connect to $db");
	return $link;
}

/* */
function db_query($query)
{
	return mysql_query($query);
}

/* */
function db_fetch_array($result)
{
	return mysql_fetch_array($result);
}

/* */
function db_free_result($result)
{
	return mysql_free_result($result);
}

/* */
function db_close($link)
{
	return mysql_close($link);
}


/* This is where the magic happens. The action is parsed and the correct
 * section of code is hopefully called. */

db_connect($host,$port,$db,$user,$passwd);

print "action: $action";
print "\n<BR>\n";

if ($action=='showprogs')
{
	$result = db_query("select program,version from session group by program order by program asc");
	while($row = db_fetch_array($result))
	{
		echo "<TR><TD><A HREF=\"webtranslate.php3?action=showreflang&prog=$row[0]&version=$row[1]\">$row[0]</A></TD><TD>$row[1]</TD></TR>\n";
	}
	db_free_result($result);
}

else if ($action=='showreflang')
{
	$result = db_query("select id,language from session where program='$prog' and version='$version' group by language order by language asc");
	print "$prog $version<BR><BR>\n\n";
	while($data = db_fetch_array($result))
	{
		echo "<A HREF=\"webtranslate.php3?action=xlat&reflan=$data[0]&program=$prog&version=$vers\">$data[1]</A><BR>";
	}
	db_free_result($result);
}

else if ($action=='xlat')
{
	$result = db_query("select reference,flag,msgid,msgstr from messages where id=$reflan");
	$data = db_fetch_array($result);
	print "\n\n<FORM METHOD=POST ACTION=\"webtranslate.pl\">\n";
	print "<INPUT TYPE=HIDDEN NAME=action VALUE=submit>\n";
	print "<TABLE BORDER=0 CELLSPACING=2 CELLPADDING=2>\n";
	print "<TR><TD>Name</TD><TD><INPUT NAME=name></TD></TR>\n";
	print "<TR><TD>Email</TD><TD><INPUT NAME=email></TD></TR>\n";
	print "<TR><TD>Language</TD><TD><INPUT NAME=language></TD><TD>in locale format, like 'en_US'</TD></TR>\n";
	print "</TABLE><BR>Program: $program $version\n";
	print "<BR><BR><HR>\n\n\n";
	print "<INPUT TYPE=HIDDEN NAME=programram VALUE=$program>\n";
	print "<INPUT TYPE=HIDDEN NAME=version VALUE=$version>\n";
	while($data = db_fetch_array($result))
	{
		$data[2] = ereg_replace("\\n","",$data[2]);
		$data[3] = ereg_replace("\\n","",$data[3]);

		print "<INPUT TYPE=HIDDEN NAME=ref$i VALUE=$data[0]>\n";
		print "<INPUT TYPE=HIDDEN NAME=flag$i VALUE=$data[1]>\n";
		print "<INPUT TYPE=HIDDEN NAME=msgid$i VALUE=\"";
		if($data[3] == "")	/* if msgstr is blank, show msgid */
		{
			print "$data[2]\">\n<PRE>$data[2]</PRE>\n";
		}
		else	/* otherwise display the msgstr, but keep the id sane */
		{
			print "$data[2]\">\n<PRE>$data[3]</PRE>\n";
		}
		print "<TEXTAREA ROWS=2 COLS=60 NAME=\"msgstr$i\"></TEXTAREA><BR><HR><BR>\n\n";
		$i++;
	}
	print "<INPUT TYPE=HIDDEN NAME=entries VALUE=$i>\n";
	print "<TEXTAREA ROWS=4 COLS=60 NAME=\"comments\"></TEXTAREA><BR><BR>\n";
	print "<INPUT TYPE=SUBMIT>\n</FORM>\n";
	db_free_result($result);
}

else if ($action=='submit')
{
	
}

else	/* no action specified */
{
	$result = db_query("select program,version from session group by program order by program asc");
	while($row = db_fetch_array($result))
	{
		echo "<TR><TD><A HREF=\"webtranslate.php3?action=showreflang\&prog=$row[0]\&version=$row[1]\">$row[0]</A></TD><TD>$row[1]</TD></TR>\n";
	}
	db_free_result($result);
}

include 'webtranslate.footer';	/* display the footer before exiting */

?>
