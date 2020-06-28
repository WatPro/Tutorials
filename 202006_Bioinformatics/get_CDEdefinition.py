import json
import glob

if ( __name__ == '__main__' ):
  
  for filepath in glob.glob('02raw_xml/publicId_*.json'):
    with open(filepath) as f:
      data = json.load(f)
      try: 
        publicId=data['dataElementConcept']['selectedDataElement']['publicId']
        perferred=data['dataElementConcept']['selectedDataElement']['preferredQuestionText']
        elementDefinition=data['dataElementConcept']['selectedDataElement']['definition']
        conceptDefinition=data['dataElementConcept']['dataElementConceptDetails']['definition']
        print(publicId,perferred,elementDefinition,conceptDefinition,sep='\t')
      except TypeError: 
        continue
  
  for filepath in glob.glob('02raw_xml/deIdseq_*.json'):
    with open(filepath) as f:
      data = json.load(f)
      publicId=data['dataElementConcept']['selectedDataElement']['publicId']
      perferred=data['dataElementConcept']['selectedDataElement']['preferredQuestionText']
      elementDefinition=data['dataElementConcept']['selectedDataElement']['definition']
      conceptDefinition=data['dataElementConcept']['dataElementConceptDetails']['definition']
      print(publicId,perferred,elementDefinition,conceptDefinition,sep='\t')

