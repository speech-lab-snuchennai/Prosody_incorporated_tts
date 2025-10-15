#!/usr/bin/perl
# ----------------------------------------------------------------- #
#Ministry Of Communications & Information Technology, Govt. Of India#
#          and Indian Institute Of Technology - Madras              #
#                    developed by TTS Group                         #
#                  http://lantana.tenet.res.in/                     #
#                    Copyright (c) 2009-2015                        #
# ----------------------------------------------------------------- #
#                                                                   #
#                                                                   #
# All rights reserved.                                              #
#                                                                   #
# Redistribution and use in source and binary forms, with or        #
# without modification, are permitted provided that the following   #
# conditions are met:                                               #
#                                                                   #
# - Redistributions of source code must retain the above copyright  #
#   notice, this list of conditions and the following disclaimer.   #
# - Redistributions in binary form must reproduce the above         #
#   copyright notice, this list of conditions and the following     #
#   disclaimer in the documentation and/or other materials provided #
#   with the distribution.                                          #
# - Neither the name of the HTS working group nor the names of its  #
#   contributors may be used to endorse or promote products derived #
#   from this software without specific prior written permission.   #
#                                                                   #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND            #
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,       #
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF          #
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE          #
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS #
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,          #
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED   #
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,     #
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON #
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,   #
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    #
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE           #
# POSSIBILITY OF SUCH DAMAGE.                                       #
# ----------------------------------------------------------------- #
use Encode;
no warnings;
use utf8;
no utf8;
$eachW = $ARGV[0];  #Word as input argument
$eachW =~ s/\n//;
#hash of unicode values to help define rules for syllabification
my %hash = (
	'ँ' => 2305,
	'ं'=> 2306,
	'अ' => 2308,
	'औ' => 2324,
	'म' => 2350,
	'य' => 2351,
	'व' => 2357,
	'श' => 2358,
	'ह' => 2361,
	'़' => 2364,
	'ऽ' => 2365,
	'ा'=> 2366,
	'ॅ'=> 2373,
	'्' => 2381,
	'क़' => 2392,
	'य़' => 2399,
	'ॠ' => 2400

);


#Array of characters which help define rules for phonifying
my @char_arr = ('अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ऋ', 'ए', 'ऐ', 'ओ', 'औ', 'ऑ', 'ॐ', 'ृ', 'े', 'ु', 'ि', 'ो', 'ः', 'ँ', 'ै', 'ू', 'ी', 'ौ', 'ा', 'ं', 'ॅ', 'ॉ', '्', 'ज', 'फ', '़');

my $oF = "wordpronunciation";   #File containing output
$dict_chk = 0;
open(f, ">>rag_pho");
open(fp_out, ">>$oF");
print fp_out " ";

if($dict_chk == 0){
	@psyl = &main($eachW); #@psyl contains array of the syllabified output

}

my $nS = @psyl; #Number of syllables in the word


if($dict_chk == 0){
	for (my $j = 0; $j < $nS; $j++) {
		# print "before : $psyl[$j]\n";
		$psyl[$j] = encode_utf8($psyl[$j]);
		# print " $psyl[$j] ";
	}
}
		# print "\n";

my $sp = 0;

for (my $j = 0; $j < $nS; $j++) {
	my $syll_ind = 3;
	$out_syl = $psyl[$j];
	print fp_out " ";
	while($syll_ind <= length($out_syl)) {
		$pre = substr($out_syl, $syll_ind-3, 3);#present character
		$nex = substr($out_syl, $syll_ind, 3);#next character
		$nex2 = substr($out_syl, $syll_ind + 3, 3);#next + 1 character
		my( $pre_ind )= grep { $char_arr[$_] =~ /$pre/ } 0..$#char_arr;
		my( $nex_ind )= grep { $char_arr[$_] =~ /$nex/ } 0..$#char_arr;
		my( $nex2_ind )= grep { $char_arr[$_] =~ /$nex2/ } 0..$#char_arr;
		open(FR1,'<unique') or die "cannot open unique"; #File containing the utf8 characters mapped to common phoneset characters
		@map = <FR1>;
		@filtarr = grep /$pre/, @map;
		@map_val = split(/\t/, $filtarr[0]);
		$map_char = substr($map_val[1], 0, length($map_val[1])-1); #map_char - the utf8 character mapped to a character from the common phoneset
		#---Here are the rules to phonify the already syllabified word
		if($pre eq ""){
		}
		elsif($pre_ind == 28 || $pre_ind == 31){ #if current character is nukta or halant
		}
		elsif($pre_ind > 27 || $pre_ind eq ''){ #rules for consonants
			if($nex_ind == 25 || $nex_ind == 19 || $nex_ind == 18){
				print fp_out "\"$map_char\" \"a\" ";
				print f "\"$map_char\" \"a\" ";
			}
			elsif($pre_ind == 29 && $nex_ind == 31){
				if($nex2_ind == 28 || ($nex2_ind > 12 && $nex2_ind < 28)){
					print fp_out "\"z\" ";
					print f "\"z\" ";
				}
				else{
					print fp_out "\"z\"" . " \"a\" ";
					print f "\"z\"" . " \"a\" ";
				}
			}
			elsif($pre_ind == 30 && $nex_ind == 31){
				if($nex2_ind == 28 || ($nex2_ind > 12 && $nex2_ind < 28)){
					print fp_out "\"f\" ";
					print f "\"f\" ";
				}
				else{
					print fp_out "\"f\"" . " \"a\" ";
					print f "\"f\"" . " \"a\" ";
				}
			}
			elsif($nex_ind == 28 || ($nex_ind > 12 && $nex_ind < 28)){
				print fp_out "\"$map_char\" ";
				print f "\"$map_char\" ";
			}
			else{
				if($nex2_ind > 12 && $nex2_ind < 28){
					print fp_out "\"$map_char\" ";
					print f "\"$map_char\" ";
				}
				else{
					if($nex2_ind == 28 && $nex_ind == 31){
						print fp_out "\"$map_char\" ";
						print f "\"$map_char\" ";
					}
					else{
						print fp_out "\"$map_char\" \"a\" ";
						print f "\"$map_char\" \"a\" ";
					}
				}
			}
		}
		elsif($pre_ind <= 27){ #Rules for vowels
			print fp_out "\"$map_char\" ";
			print f "\"$map_char\" ";
		}
		$syll_ind = $syll_ind + 3;
	}
	print fp_out ") $sp)";
}
print fp_out "\n";
close(fp_out);


#Main Function
sub main {
	my @words_with_halant = &dehalant( $_[0]);
	my $nS = @words_with_halant;
	# printf "words with halant: @words_with_halant\n";
	my $word_syllabified;
	$word_syllabified = &syllabify(\@words_with_halant);
	# printf "syllabify: $word_syllabified\n" ;
	return &syllabified_utf8($word_syllabified);
}

#Function to convert hexadecimal values to utf8
sub syllabified_utf8 {
	my $syllbified_line = $_[0];
	my @syllabified_words;
	my @temp_array;
	my $phones;
	my @utf8_array;
	$syllbified_line =~ s/\. +/\.$endln/g;
	@syllabified_words = split(/\s+/,$syllbified_line);
	foreach (@syllabified_words) {
		my @temp_syll_array = ();
		my @phonearray = ();
		@temp_syll_array = ($_ =~ m/.../g);

		foreach (@temp_syll_array) {
			$phones .= chr(hex $_);
		}
		push(@utf8_array,$phones);
		$phones = "";
	}
	# printf "@utf8_array\n";
	return @utf8_array;
}

#Function that returns list of consonants that have to undergo schwa deletion
sub dehalant {
	my @utf_char_array = &splitWord2Letters($_[0]);
	my @utf_num_array = &char2utf8num(\@utf_char_array);
	my @unicode_value = &utf8_2_unicode(\@utf_num_array);
	my @hallist;
	my $k = 0;
	my $j = @unicode_value;
	my $next_delete = 0;
	for ( my $i = 0 ; $i < @unicode_value ; $i++ ) {
		if ( ( $unicode_value[$i] > $hash{ 'औ' } && $unicode_value[$i] <= $hash{ '़' } ) || ( $unicode_value[$i] >= $hash{ 'क़' } && $unicode_value[$i] < $hash{ 'ॠ' } ) ) {
			$k = $k + 1;
			$hallist[$k] = $i;
			if ( ( $unicode_value[ $i + 1 ] > $hash{ 'अ' } && $unicode_value[ $i + 1 ] <= $hash{ 'औ' } )) {
				delete $hallist[$k]; 	#full vowel
			}
			elsif (( $unicode_value[ $i + 1 ] > $hash{ 'ऽ' } && $unicode_value[ $i + 1 ] < $hash{'्' } )) {
				delete $hallist[$k]; 	#kaa kii type
			}
			elsif(( $unicode_value[ $i + 1 ] == $hash{ '्' } ) || (( $unicode_value[ $i - 1 ] == $hash{ '्' }) && (((($i + 1 ) != $j)) || (( $unicode_value[ $i] > $hash{ 'म' } ) && ($unicode_value[ $i] < $hash{ 'श'} ) )))){
				delete $hallist[$k];	#conjsyll2 --#sub dehalant --> #conjsyll2 -->printout sect-1
			}
			elsif ( ( ( $unicode_value[ $i + 2 ] == $hash{ '्' }) ) && ( ( $unicode_value[ $i + 3 ] > $hash{ 'औ' } && $unicode_value[ $i + 3 ] <= $hash{ 'ह' } ) || ( $unicode_value[$i] > $hash{ 'क़' } && $unicode_value[$i] < $hash{ 'ॠ'} ))) {
				delete $hallist[$k];	#conjsyl1 --#sub dehalant --> #conjsyl1	-->printout sect-2
			}
			elsif(( $unicode_value[ $i + 1 ] ==$hash{'़'} ) || ( $unicode_value[$i+1] >= $hash{ 'ँ'} && $unicode_value[$i+1] < $hash{'अ'} )) {
				delete $hallist[$k]; 	#nukta && Chandra -- #sub dehalant --> #nukta && Chandra -->printout sect-3
			}
			elsif ( $i == 0 || (($i==1) && ($unicode_value[$i]==$hash{'़'} ))){
				delete $hallist[$k];	#first syllable
			}
			elsif ( ( $unicode_value[$i] == $hash{ 'य' } || $unicode_value[$i] == $hash{ 'य़' } ) && (( $unicode_value[ $i - 1 ] > $hash{ 'ा' } && $unicode_value[ $i - 1 ] < $hash{ 'ॅ' } ))){
				delete $hallist[$k];	#yarule  --#sub dehalant --> #yarule -->printout sect-4
			}
		}
	}
	my $t = @hallist;
	for ( my $k = @hallist -1; $k >= 0;$k--) {
		my $p1 = $hallist[$k];
		if (($k!=(@hallist-1))&&(($hallist[$k+1]==$p1+1))) {
			delete $hallist[$k];
		}
	}
	my @withhal;
	my $m = 1;
	$withhal[0] = $unicode_value[0];
	for ( my $i = 1 ; $i < @unicode_value ; $i++ ) {
		$withhal[$m] = $unicode_value[$i];
		my $p = 0;
		for ( $o = 0; $o < @hallist ; $o++ ) {
			if ( $hallist[$o] == $i ) {
				$p = 1;
			}
		}
		if ( $p == 1 ) {
			$m = $m + 1;
			$withhal[$m] = $hash{ '्' };
		}
		$m = $m + 1;
	}
	return @withhal;
}


#Language Specific Syllabification Rules
sub syllabify {
	my $syllabified_word;
	for ( my $i = 0 ; $i < @{ $_[0] } ; $i++ ) {
		# printf "syllabify: $syllabified_word, i = $i\n";
		if ((${ $_[0] }[$i] >= $hash{ 'अ' }) && (${ $_[0] }[$i] <= $hash{ 'औ' }) ) { # syllabify1  = ऄ or vowel
			$syllabified_word .= &dec2hex(${ $_[0] }[$i]) . " ";
		}
		elsif (((${ $_[0] }[$i] > $hash{ 'औ' }) && (${ $_[0] }[$i] <= $hash{'़'})) || (${ $_[0] }[$i] >= $hash{ 'क़' } && ${ $_[0] }[$i] < $hash{ 'ॠ'})) { #syllabify2 = consonant or consonantmatra
			if (( ${ $_[0] }[$i+1] == $hash{'़' })&&( ${ $_[0] }[$i+2] == $hash{'्' })) { #syllabify3 = conjsyllmatra
				$syllabified_word =~ s/ $//g;
				$syllabified_word .= &dec2hex(${ $_[0] }[$i]);
 			}

			elsif (( ${ $_[0] }[$i+1] >= $hash{'़'}) && (${ $_[0] }[$i+1] < $hash{ '्' })) { #syllabify4 = avagrahanukta or kaki
				$syllabified_word .= &dec2hex(${ $_[0] }[$i]);
			}
			elsif ( ${ $_[0] }[$i+1] == $hash{ '्' }) { #halant
				$syllabified_word =~ s/ $//g;
				$syllabified_word .= &dec2hex(${ $_[0] }[$i]);
			}
			else {
				$syllabified_word .= &dec2hex(${ $_[0] }[$i]) . " ";
			}
		}
		elsif ((${ $_[0] }[$i] >= $hash{'़'}) && (${ $_[0] }[$i] <= $hash{ '्' })) { #syllabify5 = avagrahanukta  or kaki or halant
			if ( $i == 1 && ${ $_[0] }[$i] == $hash{ '्' } ) { #halant
				$syllabified_word .= &dec2hex(${ $_[0] }[$i]);
			}
			else {
				if(!(((${ $_[0] }[$i-1] > $hash{ 'औ' }) && (${ $_[0] }[$i-1] <= $hash{'़'})) || ((${ $_[0] }[$i-1] >= $hash{ 'क़' }) && (${ $_[0] }[$i-1] < $hash{ 'ॠ'})))) { #syllabify6 = !(consonant or consonantmatra)
					$syllabified_word =~ s/ $//g;
					$syllabified_word .= &dec2hex(${ $_[0] }[$i]);
				}
				else {
					$syllabified_word .= &dec2hex(${ $_[0] }[$i]) . " ";
				}
			}
		}
		elsif ((${ $_[0] }[$i] > $hash{ 'ँ'}) || (${ $_[0] }[$i] <= $hash{ 'अ' })) {
			$syllabified_word =~ s/ $//g;
			$syllabified_word .= &dec2hex(${ $_[0] }[$i]) . " ";
		}
	}
	return $syllabified_word;
}

#Function to break Word into isolated utf8 characters
sub splitWord2Letters {
	my @utf8char;
	my $i=0;
	foreach ( split( //, $_[0] ) ) {
		push( @utf8char,$_ );
	}
	return @utf8char;
}

sub printArrayValues {
	foreach my $arr_values ( @{ $_[0] } ) {
		if($arr_values eq "") {
			print "$arr_values \n";
		}
		else {
			print " else $arr_values \n";
		}
	}
}

sub utf8_2_unicode {
	my $nutf8char = $#{ $_[0] } + 1;
	my @utf8char = @{ $_[0] };
	my @unicode_array;
	for ( my $loop = 0 ; $loop < $nutf8char ; ) {
		$t = 0;
		my $dec_input = &hex2dec( $utf8char[$loop] );
		if ( ( my $value = $dec_input & 128 ) == 0 ) {
			$t = $t | $dec_input;
			$loop++;
			$eng = 1;
		}
		elsif ( ( $value = $dec_input & 224 ) == 192 ) {
			$eng = 1;
			$t = $t | ( $dec_input & 31 );
			$t = $t << 6;
			$loop++;
			$t = $t | ( $dec_input & 63 );
			$loop++;
		}
		elsif ( ( $value = $dec_input & 240 ) == 224 ) {
			$other = 1;
			$t = $t | ( $dec_input & 15 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t | ( $dec_input & 63 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t | ( $dec_input & 63 );
			$loop++;
		}
		elsif ( ( $value = $dec_input & 248 ) == 240 ) {
			$other = 1;
			$t = $t + ( $dec_input & 7 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t + ( $dec_input & 63 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t + ( $dec_input & 63 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t + ( $dec_input & 63 );
			$loop++;
		}
		elsif ( ( $value = $dec_input & 252 ) == 248 ) {
			$other = 1;
			$t = $t + ( $dec_input & 3 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t + ( $dec_input & 63 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t + ( $dec_input & 63 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t + ( $dec_input & 63 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t + ( $dec_input & 63 );
			$loop++;
		}
		elsif ( ( $value = $dec_input & 254 ) == 252 ) {
			$other = 1;
			$t = $t + ( $dec_input & 63 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t + ( $dec_input & 63 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t + ( $dec_input & 63 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t + ( $dec_input & 63 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t + ( $dec_input & 63 );
			$t = $t << 6;
			$loop++;
			$dec_input = &hex2dec( $utf8char[$loop] );
			$t = $t + ( $dec_input & 63 );
			$loop++;
		}
		else {
			$loop++;
		}
		push(@unicode_array,$t);
	}
	return @unicode_array;
}

sub char2utf8num {
	my @utf8num;
	foreach $_ (@{ $_[0] }) {
		push(@utf8num , &string2bin($_) );
	}
	return @utf8num;
}

sub string2bin($) {
	return sprintf( "%02x ", ord($_) );
}

sub hex2dec($) {
	eval "return sprintf(\"\%d\", 0x$_[0])";
}

sub dec2hex {
	my $decnum = $_[0];
	my ( $hexnum, $tempval );
	while ( $decnum != 0 ) {
		$tempval = $decnum % 16;
		$tempval = chr( $tempval + 55 ) if ( $tempval > 9 );
		$hexnum= $tempval . $hexnum;
		$decnum= int( $decnum / 16 );
		if ( $decnum < 16 ) {
			$decnum = chr( $decnum + 55 ) if ( $decnum > 9 );
			$hexnum = $decnum . $hexnum;
			$decnum = 0;
		}
	}
	return $hexnum;
}
