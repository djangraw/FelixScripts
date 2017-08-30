# The file genome_stuff.csv is a comma-delineated output file fram an 
# unnamed application.  You want to pull out the data related to chrX,
# converting the delineator to a tab character, then sort based on the
# SNP id, if present.  Also, you want to maintain the column headers
# (the topmost line).

# Note the use of line continuation markers and named pipes.

cat <(cut -d',' -f1,2,22-33 genome_stuff.csv | head -1 \
  | tr ',' $'\t') <(cut -d',' -f1,2,22-33 genome_stuff.csv \
  | grep chrX |  tr ',' $'\t' | sort -k3) 
