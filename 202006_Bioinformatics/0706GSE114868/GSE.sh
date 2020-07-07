
curl --output 'GSE114868_series_matrix.txt.gz' 'https://ftp.ncbi.nlm.nih.gov/geo/series/GSE114nnn/GSE114868/matrix/GSE114868_series_matrix.txt.gz'
gunzip --decompress 'GSE114868_series_matrix.txt.gz'

curl --output 'GPL17586-45144.txt' 'https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?mode=raw&is_datatable=true&acc=GPL17586&id=45144&db=GeoDb_blob119'
cat 'GPL17586-45144.txt' |
  sed '/^#/d' |
  awk 'BEGIN{FS="\t"; OFS=" // "} {print $2,$8}' |
  awk 'BEGIN{FS=" // "; OFS="\t"; flag=0} {if(flag==0){print $1,$2;flag=1;}else{print $1,$3;}}' > 'GPL17586-45144-gene.txt'

python GSE.py > GSE114868_series_matrix_replaced.txt


