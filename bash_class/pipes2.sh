# This little doozie specifically pulls out segements from a narrow band of chrX, then
# adds an additional column and sorts it by position.

cat <(zgrep ^chrX ins.bed.gz | \
  awk '{if ($2 > 100000000 && $2 < 100500000) print "INS\t" $0}') \
  <(zgrep ^chrX del.bed.gz | \
  awk '{if ($2 > 100000000 && $2 < 100500000) print "DEL\t" $0}') \
  <(zgrep ^chrX jun.bed.gz | \
  awk '{if ($2 > 100000000 && $2 < 100500000) print "JUN\t" $0}') | \
  sort -nk3,4

