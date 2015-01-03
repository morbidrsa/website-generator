#!/usr/bin/env perl

use warnings;
use strict;

use Getopt::Long;

sub process_file {
    my $layout_html = shift;
    my $content_dir = shift;
    my $output_dir = shift;
    my $content_file = shift;

    my $layout;
    my $content;
    my $outfile;

    open($layout, $layout_html) or die("Could not open $layout_html for reading: $!");
    open($content, $content_dir . $content_file) or die("Could not open $content_file for reading: $!");
    open($outfile, '>', $output_dir . $content_file) or die("Could not open $outfile for writing: $!");

    while (<$layout>) {
	my $content_tag;

	$content_tag = $1 if /\[%\s?(CONTENT)?\s%\]/;
	if ($content_tag) {
	    while (<$content>) {
		print $outfile $_;
	    }
	} else {
	    print $outfile $_;
	}
    }
}

sub process_content {
    my $content_dir = shift;
    my $output_dir = shift;
    my $layout_html = shift;

    my $content_file;
    my @content_files;

    opendir(my $content, "$content_dir") or die("Can't open content directory $content_dir: $!");
    @content_files = readdir($content);
    closedir($content);


    foreach $content_file (@content_files) {
	next if $content_file eq ".." || $content_file eq ".";

	print "\$content_file = $content_file\n";
	process_file($layout_html, $content_dir, $output_dir, $content_file);
	print "\n\n";
    }
}

sub usage {
    print "$0 <layout> <content> <output>\n";
    print "\t--layout-html <layout>\n";
    print "\t--content-dir <content>\n";
    print "\t--output-dir <output>\n";

    exit(1);
}

my $layout_html = '';
my $content_dir = '';
my $output_dir = '';

GetOptions('layout-html=s' => \$layout_html,
	   'content-dir=s' => \$content_dir,
	   'output-dir=s' => \$output_dir);

usage() if $layout_html eq '';
usage() if $content_dir eq '';
usage() if $output_dir eq '';


process_content($content_dir, $output_dir, $layout_html);
