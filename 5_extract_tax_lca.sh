#!/bin/bash
# yilei wu

# process MARTI-LCAparse results
# $1/2: two inputs
LCAresultsFolder=$1
prefix=$2
Rscript 5_extract_tax_lca.R $LCAresultsFolder $prefix

# make these results in a unified format by TJC.'s script get_NCBI_taxonomy.py
db="ncbi database"
py_ncbi="get_NCBI_taxonomy.py written by Thomas J. Creedy, please check https://github.com/tjcreedy/biotools/blob/main/get_NCBI_taxonomy.py"
py_ncbi_auth="ncbiauth.txt, generate it through the guidance in get_NCBI_taxonomy.py"
python "$py_ncbi" -i "${prefix}_short.txt" -l "$db" -o "${prefix}_final.txt" -n "$py_ncbi_auth" --chunksize 4000
