#!/usr/bin/python
#-------------------------------------------------------------------------------
# The MIT License (MIT)
#
# Copyright (c) 2015-16 Scripps Institute (USA) - Dr. Benjamin Good
#                       STAR Informatics / Delphinai Corporation (Canada) - Dr. Richard Bruskiewich
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------
#
# This Python script cleans up ill-formed KB 3.0 data input files 
# which have the following problematic content:
#
# 1) Non-escaped single or double quotation marks
# 2) Surplus embedded white space
# 3) Empty lines (deleted)
#
import sys
import codecs
import re

if len(sys.argv)<2:
	print >>sys.stderr,"Usage: kb3_V5_preprocessor.py <inputfile>\n\nCreates a new version of the file with the\nsuffix '_clean' added to the input file name.\n"
	exit(1)

inputfilename=sys.argv[1]
outputfilename = inputfilename+"_cleaned"

with codecs.open(outputfilename, encoding='utf-8', mode='w' ) as output:

	with codecs.open(inputfilename, encoding='utf-8', mode = 'r' ) as input:

		for line in input:

			line = line.strip()
			if not len(line)>0: continue
			
			fields = line.split("\t")
			record = None
			for field in fields:
				# strip off any flanking double quotes
				field = field.strip('"') 
	
				# tweak internal (double) quotes
				field = field.replace("'","''")
				field = field.replace('"','""')
				
				# collapse whitespace except tabs to single space character
				field = re.sub(r'[ \n\r\f\v]+'," ",field,flags=re.UNICODE)
			
				# add back in flanking double quotes
				field = '"'+field+'"'
				
				if not record:
					record = field
				else:
					record += "\t"+field
			
			print >>output, record
