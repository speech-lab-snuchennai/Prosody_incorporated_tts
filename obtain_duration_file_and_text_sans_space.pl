use POSIX qw/ceil floor round/;

sub print_progress {
    my ($current, $total) = @_;
    my $progress = int(($current / $total) * 100);
    my $bar_length = 20;
    my $num_chars = int(($progress / 100) * $bar_length);
    my $bar = '[' . '=' x $num_chars . ' ' x ($bar_length - $num_chars) . ']';
    printf("\r%s %3d%%", $bar, $progress);
}

# Lab folder
$labFolder_old = "try_out";
$labFolder = $labFolder_old . "_phoneMapped";

# Path to wav files
$wavPath = "try_wav/";

# Clean up previous output files and directories
system("rm -f duration_file_HS_without_space text_HS_without_space");
system("rm -rf $labFolder");

# Create new lab folder and copy files
system("mkdir $labFolder");
system("cp $labFolder_old/* $labFolder/");

# Create a list of lab files
system("ls $labFolder/ > lablist");

# Open output files for writing
open(W2, ">text_HS_without_space") or die "Cannot open text_HS_without_space: $!";
open(W1, ">duration_file_HS_without_space") or die "Cannot open duration_file_HS_without_space: $!";
open(F1, "<lablist") or die "Cannot open lablist: $!";

# Frame attributes
$fs = 48000;  # Sampling rate
$n_shift = 1024;  # Frame shift

my $total_files = `cat lablist | wc -l`;
chomp($total_files);
my $current_file = 0;

while ($file = <F1>) {
    chomp($file);
    $fileID = substr($file, 0, -4); # Removes extension .lab

    # Run script to convert text to phone-mapped format
    system("bash get_phone_mapped_text_updated.sh $labFolder/$file");

    # Get the corresponding wav file
    $wavFile = $wavPath . $fileID . ".wav";
    $soxSamp = `soxi $wavFile | grep "Duration" | cut -d " " -f11`;
    chomp($soxSamp);

    # Print filename followed by a space
    print W1 "$fileID ";
    print W2 "$fileID ";  # Add space after filename

    $prev_frames = 0;
    my $phoneme_str = "";

    open(F2, "<$labFolder/$file") or die "Cannot open $labFolder/$file: $!";
    while ($line = <F2>) {
        chomp($line);
        my @values = split(' ', $line);

        if ($values[0] eq '#') {
            next; # Skip comment lines
        }

        $end_time = $values[0];

        # Handle zero-duration phonemes by setting duration to 0
        if ($end_time == 0) {
            print W1 "0 ";  # Zero duration
            print W2 "$values[2]";  # Include the phoneme with no space
            next;
        }

        # Handling non-zero duration phonemes
        if (eof(F2)) {
            $cum_frames = floor($soxSamp / $n_shift) + 1;
        } else {
            $cum_frames = round($end_time * $fs / $n_shift);
        }
        $num_frames = $cum_frames - $prev_frames;

        # Store duration information
        print W1 "$num_frames ";

        # Append phoneme without spaces
        print W2 "$values[2]";  # Directly append phoneme without space

        $prev_frames = $cum_frames;
    }
    close F2;

    # Print '0' for end of speech
    print W1 "0\n";
    print W2 "\n";

    $current_file++;
    print_progress($current_file, $total_files);
}

# Close all opened file handles
close F1;
close W1;
close W2;

# Remove the temporary lablist file
system("rm -f lablist");

