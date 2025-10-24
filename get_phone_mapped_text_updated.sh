#!/bin/bash

file=$1

sed -i 's/ aa$/ A/g' $file
sed -i 's/ ii$/ I/g' $file
sed -i 's/ uu$/ U/g' $file
sed -i 's/ ee$/ E/g' $file
sed -i 's/ oo$/ O/g' $file
sed -i 's/ nn$/ N/g' $file

sed -i 's/ ae$/ ऍ/g' $file
sed -i 's/ ag$/ ऽ/g' $file

sed -i 's/ au$/ औ/g' $file
sed -i 's/ axx$/ अ/g' $file
sed -i 's/ ax$/ ऑ/g' $file
sed -i 's/ bh$/ B/g' $file
sed -i 's/ ch$/ C/g' $file
sed -i 's/ dh$/ ध/g' $file


sed -i 's/ dx$/ ड/g' $file
sed -i 's/ dxh$/ ढ/g' $file
sed -i 's/ dxhq$/ T/g' $file
sed -i 's/ dxq$/ D/g' $file
sed -i 's/ ei$/ ऐ/g' $file
sed -i 's/ ai$/ ऐ/g' $file
sed -i 's/ eu$/ உ/g' $file

sed -i 's/ gh$/ घ/g' $file
sed -i 's/ gq$/ G/g' $file
sed -i 's/ hq$/ H/g' $file
sed -i 's/ jh$/ J/g' $file
sed -i 's/ kh$/ ख/g' $file
sed -i 's/ khq$/ K/g' $file
sed -i 's/ kq$/ क/g' $file
sed -i 's/ ln$/ ൾ/g' $file
sed -i 's/ lw$/ ൽ/g' $file
sed -i 's/ lx$/ ള/g' $file
sed -i 's/ mq$/ M/g' $file
sed -i 's/ nd$/ न/g' $file
sed -i 's/ ng$/ ङ/g' $file
sed -i 's/ nj$/ ञ/g' $file
sed -i 's/ nk$/ Y/g' $file

sed -i 's/ nw$/ ൺ/g' $file
sed -i 's/ nx$/ ण/g' $file
sed -i 's/ ou$/ औ/g' $file
sed -i 's/ ph$/ P/g' $file
sed -i 's/ rq$/ R/g' $file
sed -i 's/ rqw$/ ॠ/g' $file
sed -i 's/ rw$/ ർ/g' $file
sed -i 's/ rx$/ र/g' $file
sed -i 's/ sh$/ श/g' $file

sed -i 's/ sx$/ ष/g' $file
sed -i 's/ th$/ थ/g' $file
sed -i 's/ tx$/ ट/g' $file
sed -i 's/ txh$/ ठ/g' $file
sed -i 's/ wv$/ W/g' $file
sed -i 's/ zh$/ Z/g' $file

sed -i 's/ SIL$/ ./g' $file
sed -i 's/ sp$/ */g' $file
sed -i 's/ _flat$/ ௦/g' $file
sed -i 's/ _H$/ ௧/g' $file
sed -i 's/ _L$/ ௨/g' $file
sed -i 's/ _HLL$/ ௩/g' $file
sed -i 's/ _LHH$/ ௪/g' $file
sed -i 's/ _HHL$/ ௬/g' $file
sed -i 's/ _LLH$/ ௫/g' $file
sed -i 's/ _LHL$/ ௭/g' $file
sed -i 's/ _HLH$/ ௮/g' $file
sed -i 's/ _hat$/ ௯/g' $file
sed -i 's/ _bucket$/ ೧/g' $file
sed -i 's/ 1$/ 1/g' $file
sed -i 's/ 2$/ 2/g' $file
sed -i 's/ 3$/ 3/g' $file
sed -i 's/ 4$/ 4/g' $file
sed -i 's/ 5$/ 5/g' $file
