#!/usr/bin/python

genedict = {}

import csv
with open('GPL17586-45144-gene.txt') as csvfile:
  dictreader = csv.reader(csvfile, delimiter='\t')
  header = True
  for row in dictreader:
    if header == True:
      header = False
      continue
    key   = row[0]
    value = row[1]
    if key in genedict:
      print 'Duplicate Found'
    elif value == '' or value == '---': 
      continue 
    else: 
      genedict[key] = value 

import re
with open('GSE114868_series_matrix.txt','r') as f:
  lines = f.readlines() 
  for line in lines: 
    if re.search('^!',line):
      continue
    line = line.strip()
    id = re.sub('^"|"$','',re.split('\t',line)[0])
    if id in genedict:
      print re.sub('^"'+id+'"',genedict[id],line)
    else: 
      print re.sub('^"'+id+'"',id,line)


