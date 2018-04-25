# Reference Knowledge Beacon Prototype

This 'database' subdirectory of the TKG project is a first attempt at a prototype of the shared
knowledge using the Neo4j knowledge graph database of the [Reference Knowledge Beacon ("RKB")](https://rkb.ncats.io). 

The RKB is a [Java language implementation](https://github.com/NCATS-Tangerine/reference-beacon) of the [Translator Knowledge Beacon API](https://github.com/NCATS-Tangerine/translator-knowledge-beacon) which wraps a Neo4j database
containing a substantial version (circa June 2016 release) of the Semantic Medline Database subject-predicate-object knowledge statements, with associated evidence mainly consisting of PubMed citations. The RKB also has some additional drug-disease statements from outside SemMedDb. The RKB beacon wrapper code itself is already designed for Docker deployment.

The RKB beacon code itself is parameterized to point to any installation of Neo4j, hence, could be used, 
with some modifications (e.g. mapping of semantic fields to the biolink model), as one starting point to create a prototype of the TKG. 
Design discussions on how to evolve the RKB into a prototype TKG are documented [here](https://github.com/NCATS-Tangerine/translator-knowledge-graph/wiki/Reference-Knowledge-Beacon-as-Prototype-TKG).

An initial deployment of the prototype is [hosted online here](http://tkg.ncats.io).

# Data loading

This is a work in progress. A [Neo4j Cypher Query Language (CQL) script](https://github.com/NCATS-Tangerine/translator-knowledge-graph/blob/develop/database/scripts/tkg_dataloader.cql) is being derived from a script formerly used in the TKBIO predecessor ("Knowledge.Bio Release 3.0") is being adapted for TKG data loading.  This script could be used to bulk load additional data into the database, or to create a *'de novo'* custom version of at TKG standards compliant database.

