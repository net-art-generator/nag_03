#!/usr/bin/perl
######################################
#netart 1999 abc team  
#24.4.02 adapted to google $
######################################
#settings
$bilderanzahl = 23;

#includes
use LWP::UserAgent;
use HTML::LinkExtor;
use URI::URL;

#cgi - formular daten holen
&parse_form_data (*userdata);           #FORM aus html req.holen

#formular ausgeben wenn keine daten aus cgi-formular kommen
&put_form() if (!$userdata{'wort'} || length($userdata{'wort'}) < 3);

#aufruf link setzen
$wort=$userdata{'wort'};
$name='anonymous';
$name=$userdata{'name'} if ($userdata{'name'});
$search='http://www.google.de/search?q='.$wort;

# tags aus seite holen
# 1st stage
($ref_OTHER, $ref_IMG, $ref_LINKS, $ref_AREA, $ref_BODY, $ref_INPUT, $ref_FORM, $ref_FRAME, $ref_EMBED, $ref_LINK) = &get_it($search);

#2nd stage
print STDERR "Scan: ".@$ref_LINKS."\n";
@$ref_LINKS = grep (!/google/,@$ref_LINKS);
foreach (@$ref_LINKS) {
  print STDERR $_." / ";
}
print STDERR "\n";
foreach $link (@$ref_LINKS) {
		#undef ($got_OTHER, $got_IMG, $got_LINKS, $got_AREA, $got_BODY, $got_INPUT, $got_FORM, $got_FRAME, $got_EMBED, $got_LINK);
                print STDERR $link.":\n";
		($got_OTHER, $got_IMG, $got_LINKS, $got_AREA, $got_BODY, $got_INPUT, $got_FORM, $got_FRAME, $got_EMBED, $got_LINK) = &get_it($link);
			foreach $img (@$got_IMG) {
				if (
				($img !~ /banner/i) && 
				($img !~ /google/i) && 
				($img !~ /cgi/i) &&
				($img !~ /yahoo/i) &&
				($img =~ /\//) &&
				($img =~ /http\:\/\//) &&
				($img !~ /\/ad/) &&
				($img !~ /\/werbung/) &&
				($img =~ /gif/i || $img =~ /\.jp/i)
						) 
				{
					push (@IMG,$img);
                                        print STDERR "FINALIMG: ".$#IMG."\n";
				}
			}

			undef @$got_IMG;
}

#jeder bitte nur ein kreuz
grep ($IIMMGG{$_}++,@IMG);
@IMG = keys(%IIMMGG);

#bisserl random
srand(time|$$);
push(@TMP_IMG , splice(@IMG,rand(@IMG),1)) while @IMG;
@IMG=@TMP_IMG;

print STDERR "\n\n2nd stage imgs:\n";
$sess = &make_session();
$backgr = shift @IMG;
if ($#IMG < 7) {
	print "Location: http://art.mobile.de/generator/sorry.html\n\n";
	exit(0);
}
open (SESSION,">/HAL/NETART/htdocs.art/generator/$sess.html");

print SESSION "<HTML><HEAD>\n<TITLE> Generator \n\nTitle: $wort by $name\n\n</TITLE>\n";
print SESSION "<BODY BGCOLOR=\"#ffffff\" BACKGROUND= \"$backgr\"> ";

print SESSION length($seite);
foreach (@IMG) {
	$y++;
	print SESSION qq|
	<IMG SRC="$_" BORDER="0">
	|;
	#print SESSION $#TEXT;
	#print SESSION " ".length($seite);
	last if ($y >$bilderanzahl);
}
print SESSION "</BODY></HTML>\n";
close(SESSION);
print "Location: http://art.mobile.de/generator/$sess.html\n\n";

print STDERR "\n\nIMG:\n";
print STDERR join("\n", @$ref_IMG), "\n"; 
print STDERR "\n\nLINKS:\n";
print STDERR join("\n", @$ref_LINKS), "\n"; 
print STDERR "\n\nAREA:\n";
print STDERR join("\n", @$ref_AREA), "\n"; 
print STDERR "\n\nBODY:\n";
print STDERR join("\n", @$ref_BODY), "\n"; 
print STDERR "\n\nINPUT:\n";
print STDERR join("\n", @$ref_INPUT), "\n"; 
print STDERR "\n\nFORM:\n";
print STDERR join("\n", @$ref_FORM), "\n"; 
print STDERR "\n\nFRAME:\n";
print STDERR join("\n", @$ref_FRAME), "\n"; 
print STDERR "\n\nEMBED:\n";
print STDERR join("\n", @$ref_EMBED), "\n"; 
print STDERR "\n\nLINK:\n";
print STDERR join("\n", @$ref_LINK), "\n"; 
print STDERR "\n\nOTHER:\n";
print STDERR join("\n", @$ref_OTHER), "\n"; 
print STDERR "</PRE>\n";


#####################################################
# sub zum holen der seite und extrahieren der links #
#####################################################
sub get_it {
	#undef (@imgs,@links,@area,@body,@input,@form,@frame,@embed,@link,@other,@res);
	#undef (\@imgs,\@links,\@area,\@body,\@input,\@form,\@frame,\@embed,\@link,\@other,\@res);
	#undef ($url,$ua,$s,$p);
	$url = $_[0];
	print STDERR "IN get_it with url:$url<BR>";
	print STDERR "IMG: ".$#imgs."<BR>";
	$ua = new LWP::UserAgent;
	$ua->agent('Mozilla/3.0 (compatible; netart generator/1.0; ' . $ua->agent . ')'); 
	$ua->timeout(5);
	$ua->from('generator@obn.de');


	# parsen .... aber wir haben evtl. die baseurl noch nicht
	# (die ist evtl. anders als die gespiderte)
	$p = HTML::LinkExtor->new(\&callback);

	# seite holen und das parsen, was wir kriegen
	$res = $ua->request(HTTP::Request->new(GET => $url),
       	             sub {$p->parse($_[0])});

	#$seite .= $res->content;
	#print length($seite).' ';
	#while ($seite =~ s/(\w+)//g) {
	#	push (@TEXT,$1);
	#}

	# absolute links aus den relativen machen
	my $base = $res->base;
	my(@imgs) = map { $_ = url($_, $base)->abs; } @imgs;
	my(@links) = map { $_ = url($_, $base)->abs; } @links;
	my(@area) = map { $_ = url($_, $base)->abs; } @area;
	my(@body) = map { $_ = url($_, $base)->abs; } @body;
	my(@input) = map { $_ = url($_, $base)->abs; } @input;
	my(@form) = map { $_ = url($_, $base)->abs; } @form;
	my(@frame) = map { $_ = url($_, $base)->abs; } @frame;
	my(@embed) = map { $_ = url($_, $base)->abs; } @embed;
	my(@link) = map { $_ = url($_, $base)->abs; } @link;
	my(@other) = map { $_ = url($_, $base)->abs; } @other;


	print STDERR "get_it_2: imgs:".$#imgs."<BR>\n";
	return (\@other, \@imgs,\@links,\@area,\@body,\@input,\@form,\@frame,\@embed,\@link);
}

##########################################################
#sub zum holen der formular cgi daten                    #
##########################################################
sub parse_form_data
{
    local (*FORM_DATA) = @_;

    local ( $request_method, $query_string, @key_value_pairs,
            $key_value, $key, $value);


    $request_method = $ENV{'REQUEST_METHOD'};

    if ($request_method eq "GET") {
            $query_string = $ENV{'QUERY_STRING'};
    } elsif ($request_method eq "POST") {
            read (STDIN, $query_string, $ENV{'CONTENT_LENGTH'});
    }   else {
            print ( "Content-type: text/html\n\n",
                                "Server uses unsupportet method");
}
     @key_value_pairs = split (/&/, $query_string);

    foreach $key_value (@key_value_pairs) {
        ($key, $value) = split (/=/, $key_value);
        $value =~ tr/+/ /;
        $value =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex ($1))/eg;

        if (defined($FORM_DATA{$key})) {
            $FORM_DATA{$key} = join ("\0", $FORM_DATA{$key}, $value);
        } else {
                $FORM_DATA{$key} = $value;
        }
    }
}

###################################
# sub fuers formularausgeben      #
###################################
sub put_form {
	print "Content-type: text/html\n\n";
	print "<HTML><HEAD><TITLE>Generator $link</TITLE></HEAD>\n";
	print "<BODY BGCOLOR=\"#000000\" LINK=\"#ffff66\" ALINK=\"#ffffcc\" VLINK=\"#ffffcc\" TEXT=\"#ffff66\">\n";
	print "<TABLE BORDER=0 align=center>";
	print "<TR><TD>";
	print "<BR><BR><H2><i>work in progress ";
	print "</i></H2><BR>\n";
	print "<FORM METHOD=\"POST\">\n";
	print "</TD></TR>";
	print "<TR><TD>";
	print "Title: <INPUT TYPE=\"TEXT\" NAME=\"wort\" VALUE=\"$wort\"><BR><BR>\n";
	print "Name: <INPUT TYPE=\"TEXT\" NAME=\"name\" VALUE=\"$name\">&nbsp;&nbsp;&nbsp;<INPUT TYPE=submit name=Go value=create><BR><BR>\n";
	print "</TD></TR>";
	print "</FORM>\n";


	#filenamen und links darauf ausgeben
	$ft = `grep \'^Title:\' /HAL/NETART/htdocs.art/generator/*\.html`;
	@fts = split (/\n/,$ft);
#	print $#fts . "gaga";
	undef ($i);
	for ( $z = $#fts ;$z>1;$z--) {
		$i++;
		@fthelper = split (/Title:\ /,$fts[$z]);
		$fthelper[0] =~ s/\://g;
		if ($i<=10) {
			$fthelper[0] =~ s/^.*(generator.*)$/$1/;
			print "<TR><TD>";
			print "<A HREF=\"http://art.mobile.de/".$fthelper[0]."\">";
			print $fthelper[1]."</A>\n";
			print "</TD></TR>";
		} else {
			system ("mv $fthelper[0] /HAL/NETART/htdocs.art/generator/archive");
		}
	}

	print "<TR><TD><BR><BR><A HREF=\"/cgi-bin/generator_archive.pl\">goto archive</A></TD></TR>";	
	print "</TABLE>\n";

	print "</BODY></HTML>\n";	
	exit(0);
}

	# callback routine zum image tag sammeln
	sub callback {
  		my($tag, %attr) = @_;
 		if ($tag eq 'img') {
   			push(@imgs, values %attr);
   		} elsif ($tag eq 'a') {
   			push(@links, values %attr);
   		} elsif ($tag eq 'area') {
   			push(@area, values %attr);
		} elsif ($tag eq 'body') {
   			push(@body, values %attr);
		} elsif ($tag eq 'input') {
   			push(@input, values %attr);
		} elsif ($tag eq 'form') {
   			push(@form, values %attr);
		} elsif ($tag eq 'frame') {
   			push(@frame, values %attr);
		} elsif ($tag eq 'embed') {
   			push(@embed, values %attr);
		} elsif ($tag eq 'link') {
   			push(@link, values %attr);
  		} else {
   			push(@other, values %attr);
   		}
	}

#
#session id generieren
#
sub make_session {
	my ($id);
	local ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$mon=$mon+1;
	$year += 1900;
	if ($mon < 10) {$mon ='0'.$mon;}
	if ($mday < 10) {$mday ='0'.$mday;}
	if ($hour < 10) {$hour ='0'.$hour;}
	if ($min < 10) {$min ='0'.$min;}
	if ($sec < 10) {$sec ='0'.$sec;}
	$id = $year.$mon.$mday.$hour.$min.$sec.$$;
	return($id);
}

