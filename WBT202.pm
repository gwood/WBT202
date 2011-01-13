package WBT202;

use strict;
use warnings;

use Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
cleanup_empty_directories
convert_to_gpx
convert_to_kml
copy_tes
find_gps
make_destination_directory
unlink_input
);

sub cleanup_empty_directories {
    my (@dirs) = @_;

    foreach my $dir (@dirs) {
	if (_empty_directory($dir)) {
	    print STDOUT "Directory \'$dir\' is empty\n";
	    print STDOUT "rmdir \'$dir\'\n";
	    rmdir $dir || warn "Could not remove \'$dir\'\n";
	} 
    }
}

sub _cmd {
    my ($cmd) = @_;

    print STDOUT "$cmd\n";
    print STDOUT `$cmd`;
    if ($?) {
	die "Could not execute $cmd: $!";
    }
}

sub convert_to_gpx {
    my ($in, $out) = @_;

    _unlink_empty($out);
    # Create if does not exist
    if (!-e $out) {
	#    gpsbabel -i wintec_tes -f '/Volumes/NO\ NAME/WBT202/20110112/17_31_57.TES' -o gpx -F 'out.gpx'
	_cmd("gpsbabel -i wintec_tes -f \'$in\' -o gpx -F \'$out\'");
    }
    _die_if_not_positive_length($out);
}

sub convert_to_kml {
    my ($in, $out) = @_;

    _unlink_empty($out);
    if (!-e $out) {
	_cmd("gpsbabel -i wintec_tes -f \'$in\' -o kml -F \'$out\'");
    }
    _die_if_not_positive_length($out);
}

sub copy_tes {
    my ($in, $out) = @_;

    _unlink_empty($out);
    # Create if does not exist
    if (!-e $out) {
	_cmd("cp \'$in\' \'$out\'");
    }
    _die_if_not_positive_length($out);
}

sub _die_if_not_positive_length {
    my ($file) = @_;

    if (!-e $file
	||
	-z _) {
	die "Did not properly create positive length $file\n";
    }
}

sub _empty_directory {
    my ($dir) = @_;

    opendir(DIR,$dir) || die "Could not open \'$dir\': $!";
    my $count;
    while(readdir(DIR)) {
	$count++;
    }
    closedir(DIR) || die "Could not close \'$dir\': $!";
    return ($count == 2) ? 1 : 0;
}

sub find_gps {
    my ($device) = @_;

    # The device has this signature in its directory...
    if (-d $device) {
	print STDOUT "Found the GPS device in $device\n";
    }
    else {
	die "Must plug in $device USB cable and then turn off power switch (0/1) to enable USB mode so that satellites LED is OFF\n";
    }
}

sub make_destination_directory {
    my ($dir) = @_;

    if (! -d $dir) {
	print STDOUT "mkdir '$dir'\n";
	mkdir $dir || die "Could not make_destination_directory '$dir'\n";
    }
    else {
	print STDOUT "\'$dir\' already exists\n";
	print STDOUT `/bin/ls -ladtr \'$dir\'` . "\n";
    }
    if (! -d $dir) {
	die "Could not create directory \'$dir\'\n";
    }
}

sub _unlink_empty {
    my ($file) = @_;

    if (-z $file) {
	print STDOUT "unlink $file";
	unlink $file || die "Could not unlink $file: $!";
    }	    
}

sub unlink_input {
    my ($file) = @_;

    print STDOUT "unlink $file\n";
    unlink $file;
    if (-f $file) {
	warn "Could not unlink $file\n";
    } 
    else {
	#print STDOUT `/bin/ls -l \'$file\'`;
    }   
}

1;
