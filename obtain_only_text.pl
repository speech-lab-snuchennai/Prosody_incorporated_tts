#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw/ceil floor round/;
use File::Basename;

# Frame parameters
my $fs = 48000;
my $n_shift = 1024;

# Input lab folder (original)
my $labFolder_old = "try_out";
-d $labFolder_old or die "Original lab folder not found: $labFolder_old\n";

# Output mapped lab folder
my $labFolder = $labFolder_old . "_phoneMapped";
system("rm -rf $labFolder");
system("mkdir $labFolder");
system("cp $labFolder_old/*.lab $labFolder/");

# Open final output files
open(my $W1, '>', "duration_file_HS_without_space") or die $!;
open(my $W2, '>', "text_HS_without_space") or die $!;

# List lab files in new folder
opendir(my $DIR, $labFolder) or die $!;
my @labFiles = grep { /\.lab$/ && -f "$labFolder/$_" } readdir($DIR);
closedir($DIR);

my $total = scalar @labFiles;
my $current = 0;

foreach my $file (@labFiles) {
    my $labPath = "$labFolder/$file";

    # Run phone mapping script (modifies lab file in place)
    system("bash get_phone_mapped_text_updated.sh $labPath");

    (my $fileID = $file) =~ s/\.lab$//;

    # Write file ID to output files
    print $W1 "$fileID ";
    print $W2 "$fileID ";

    open(my $F, '<', $labPath) or die "Cannot open $labPath: $!";
    my @lines = <$F>;
    chomp @lines;
    close($F);

    my $prev_frames = 0;
    my $num_lines = scalar @lines;

    for (my $i = 0; $i < $num_lines; $i++) {
        my $line = $lines[$i];
        next if $line =~ /^#/;
        my @values = split(' ', $line);
        my $end_time = $values[0];

        if ($end_time == 0) {
            print $W1 "0 ";
            print $W2 "$values[2]";
            next;
        }

        my $cum_frames;
        if ($i == $num_lines - 1) {
            $cum_frames = $prev_frames;
        } else {
            $cum_frames = round($end_time * $fs / $n_shift);
        }

        my $num_frames = $cum_frames - $prev_frames;
        $num_frames = 0 if $num_frames < 0;

        print $W1 "$num_frames ";
        print $W2 "$values[2]";

        $prev_frames = $cum_frames;
    }

    print $W1 "0\n";
    print $W2 "\n";

    $current++;
    printf("\rProcessed %d of %d files...", $current, $total);
}

close($W1);
close($W2);
print "\nAll files processed. Mapped folder: $labFolder\n"; 
