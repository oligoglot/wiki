#!/usr/bin/perl
use strict;
no warnings;
use WWW::Mechanize;
use WWW::Mechanize::FormFiller;
use URI::URL;

my $start;
print "Enter start word/phrase: ";
$start = <STDIN>;
chomp($start);

my $b;
$b = WWW::Mechanize->new( autocheck => 1 );
$b->stack_depth(10);
$b->agent(
'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.11) Gecko/20071204 Ubuntu/7.10 (gutsy) Firefox/2.0.0.11'
);
$b->get('http://ta.wiktionary.org/wiki/Special:Userlogin');
sleep(1);
$b->form_number(1) if $b->forms and scalar @{ $b->forms };
{ local $^W; $b->current_form->value( 'wpName',     'SundarBot' ); };
{ local $^W; $b->current_form->value( 'wpPassword', '' ); };
{ local $^W; $b->current_form->value( 'wpRemember', '1' ); };

$b->submit();
open( OUT, ">>alreadyfound.out" )
  or die
"Can't write to alreadyfound.out. Please check if you have permissions on this directory. $!\n";
open( ERR, ">>DEBUG.txt" )
  or die
"Can't write to DEBUG.txt. Please check if you have permissions on this directory. $!\n";
open( IN, "source.txt" )
  or die
"Couldn't open source file. Check if your current directory has a file called source.txt. $!\n";
my $youcanstart = 0;

while (<IN>) {
    chomp;
    $youcanstart = 1 if $_ =~ /^$start:/;
    next unless $youcanstart;
    /^([^:]+):/;
    my $phrase = $1;
    my $title  = $phrase;
    $title =~ s/ /+/g;
    print ERR "* http://ta.wiktionary.org/wiki/$title\n";
    my $url =
        'http://ta.wiktionary.org/w/index.php?action=edit&title=' 
      . $title
      . '&create=create';
    sleep( int( rand(1) ) );
    $b->get($url) or print OUT $_, "\n" and next;
    print OUT $_, "\n" and next unless $b->success;
    my $content;
    { local $^W; $content = $b->current_form->value('wpTextbox1'); };
    print OUT $_, "\n" and sleep(1) and next
      if $content
      && ( length($content) > 1 )
      && ( $content !~ /www.tamilvu.org/ );
    $content .= "{{subst:தஇப-மேல்}}\n"
      unless $content && ( length($content) > 1 );
    $content = "{{subst:தஇப-மேல்}}\n"
      if ( $content =~ /உசாத்துணை/ )
      && ( $content =~ /www.tamilvu.org/ )
      ;    # temporarily overwriting for the sample articles
    sleep(1);
    my $summary    = "";
    my $prefix     = "";
    my $meanings   = "";
    my $sum_prefix = "";
    my $footer;

    foreach my $group ( split(/<>/) ) {
        $group =~ s/,/;/g;
        $group =~ /.*:(.+)--(.+)/;
        if ( $1 eq 'பொது' ) {
            $prefix     = "* $2\n";
            $sum_prefix = "$2 ";
        }
        else {
            $meanings .= "* ''$1.'' $2\n";
            $summary  .= "$1: $2 ";
            $footer   .= "[[பகுப்பு:$1]]\n";
        }
    }
    $content .= $prefix   if $prefix;
    $content .= $meanings if $meanings;
    $summary = $sum_prefix . $summary;
    my $h_url =
'http://www.tamilvu.org:8080/slet/servlet/o33.o33searh?CboSelect=1&TxtSearch='
      . $title
      . '&OptSearch=&id=All';
    $content .= "\n==உசாத்துணை== \n"
      . "* தமிழ் இணையப் பல்கலைக்கழக அகரமுதலியில்  [$h_url $phrase]\n$footer\n[[en:{{subst:PAGENAME}}]]\n";
    $b->form_number(1) if $b->forms and scalar @{ $b->forms };
    { local $^W; $b->current_form->value( 'wpTextbox1', $content ); };
    { local $^W; $b->current_form->value( 'wpSummary',  $summary ); };
    $b->click("wpSave");
    print OUT $_, "\n" and next unless $b->success;
    print ERR $url, "\n", $content, "\n";
    sleep(1);
    sleep( int( rand(2.8) ) + 1 );
}
close(IN);
close ERR;
close OUT;
