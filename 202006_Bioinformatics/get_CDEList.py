import xml.sax
import re
import glob

class ContentHandler( xml.sax.ContentHandler ): 
  def __init__(self): 
    self.isBody            = False
    self.currentTag        = ''
    self.CommonDataElement = ''
    
  def startElement(self, tag, attributes): 
    self.currentTag = tag
    if 'cde' in attributes: 
      self.CommonDataElement = attributes['cde']
    if tag == 'laml:patient':
      self.isBody = True 
  
  def characters(self, content):
    thisContent = content.strip() 
    thisTag     = re.sub('^.+:','',self.currentTag)
    if self.isBody and (thisTag != '') and not (thisContent == ''): 
      print(filename,thisTag,self.CommonDataElement.strip(),sep='\t')
  
  def endElement(self, tag): 
    self.currentTag        = ''
    self.CommonDataElement = ''
    if tag == 'laml:patient':
      self.isBody = False

if ( __name__ == '__main__'):
  
  parser = xml.sax.make_parser()
  Handler = ContentHandler()
  parser.setContentHandler( Handler )
  
  for filepath in glob.glob('02raw_xml/*.xml'): 
    filename = re.sub('^.*/','',filepath)
    parser.parse(filepath) 
