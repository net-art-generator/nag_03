#!/usr/bin/perl

&put_form();
###################################
# sub fuers formularausgeben      #
###################################
sub put_form {
	print "Content-type: text/html\n\n";
	print "<HTML><HEAD><TITLE>Generator Archive</TITLE></HEAD>\n";
	print "<BODY BGCOLOR=\"#000000\" LINK=\"#ffff66\" ALINK=\"#ffffcc\" VLINK=\"#ffffcc\" TEXT=\"#ffff66\">\n";
	print "<TABLE BORDER=0 align=center>";
	print "<TR><TD>";
	print "<BR><BR><H2><i>work in progress: archive ";
	print "</i></H2><BR>\n";
	print "</TD></TR>";
	print "<TR><TD>";
	print "</TD></TR>";

	#filenamen und links darauf ausgeben
	$ft = `grep \'\^Title: \' /HAL/NETART/htdocs.art/generator/archive/*\.html`;
	@fts = split (/\n/,$ft);
#	print $#fts . "gaga";
	for ( $z = $#fts ;$z>1;$z--) {
		@fthelper = split (/Title:\ /,$fts[$z]);
		$fthelper[0] =~ s/\://g;
		$fthelper[0] =~ s/^.*(generator.*)$/$1/;
		print "<TR><TD>";
		print "<A HREF=\"http://art.mobile.de/".$fthelper[0]."\">";
		print $fthelper[1]."</A>\n";
		print "</TD></TR>";
	}
	print "<TR><TD><BR><BR><A HREF=\"/cgi-bin/generator.pl\">back to generator</A></TD></TR>";
	print "</TABLE>\n";

	print "</BODY></HTML>\n";	
	exit(0);
}

