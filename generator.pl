#!/usr/bin/env perl

use warnings;
use strict;

use Getopt::Long;

sub process_file {
    my $layout_html = shift;
    my $content_dir = shift;
    my $output_dir = shift;
    my $content_file = shift;
    my $navigation = shift;

    my $layout;
    my $content;
    my $outfile;

    open($layout, $layout_html) or die("Could not open $layout_html for reading: $!");
    open($content, $content_dir . $content_file) or die("Could not open $content_file for reading: $!");
    open($outfile, '>', $output_dir . $content_file) or die("Could not open $outfile for writing: $!");

    while (<$layout>) {
	my $content_tag;
	my $navigation_tag;

	$navigation_tag = $1 if /\[%\s?(NAVIGATION)?\s%\]/;
	$content_tag = $1 if /\[%\s?(CONTENT)?\s%\]/;

	if ($navigation_tag) {
	    print $outfile $navigation;
	} elsif ($content_tag) {
	    while (<$content>) {
		print $outfile $_;
	    }
	} else {
	    print $outfile $_;
	}
    }
}

sub process_content {

    my (%options) = @_;

    my $content_dir = $options{content_dir};
    my $output_dir = $options{output_dir};
    my $layout_html = $options{layout_html};
    my $sitemap_file = $options{sitemap};
    my $navigation;
    my $content_file;
    my $sitemap;
    my @content_files;

    opendir(my $content, "$content_dir") or die("Can't open content directory $content_dir: $!");
    @content_files = readdir($content);
    closedir($content);


    open($sitemap, $sitemap_file) or die("Can't open sitemap file $sitemap_file: $!");
    $navigation = "<ul>\n";
    while (<$sitemap>) {
	my $file;
	my $text;

	($file, $text) = split(/=/, $_);

	chomp($file);
	chomp($text);

	$navigation .= "\t<li><a href=\"$file\">$text</a></li>\n";
    }
    $navigation .= "</ul>\n";
    close($sitemap);

    foreach $content_file (@content_files) {
	next if $content_file eq ".." || $content_file eq ".";

	print "Processing $content_file\n";
	process_file($layout_html, $content_dir, $output_dir, $content_file, $navigation);
    }
}

sub usage {
    print "$0 <layout> <content> <output> <sitemap>\n";
    print "\t--layout-html <layout>\n";
    print "\t--content-dir <content>\n";
    print "\t--output-dir <output>\n";
    print "\t--sitemap <sitemap>\n";

    exit(1);
}

my $layout_html = '';
my $content_dir = '';
my $output_dir = '';
my $sitemap = '';
my %options;

GetOptions('layout-html=s' => \$layout_html,
	   'content-dir=s' => \$content_dir,
	   'output-dir=s' => \$output_dir,
	   'sitemap=s' => \$sitemap);

usage() if $layout_html eq '';
usage() if $content_dir eq '';
usage() if $output_dir eq '';
usage() if $sitemap eq '';

$options{'layout_html'} = $layout_html;
$options{'output_dir'} = $output_dir;
$options{'content_dir'} = $content_dir;
$options{'sitemap'} = $sitemap;

process_content(%options);
