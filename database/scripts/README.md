# Data Loading Scripts

This folder contains Cypher data loading scripts adapted from the RKB for possible use in loading the prototype 
TKG using a standard flat file TSV format. Here we provide a basic synopsis of these scripts and the associated TSV input files.

# TSV Input Files

This system of scripts assumes independent loading of a small number of files:

1. *Concepts:* the file containing the identification and semantic details of the concepts being loaded (as nodes) into the TKG. Concept types are assumed to be based on the [Biolink Model](https://github.com/biolink/biolink-model).
2. *Statements:* the file containing the subject concept - predicate - object concept - evidence assertions of the TKG. Predicates used are also drawn from the the [Biolink Model](https://github.com/biolink/biolink-model). 
