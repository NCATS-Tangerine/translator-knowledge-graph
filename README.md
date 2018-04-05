# Translator Knowledge Graph

Practical experience with graph algorithms suggest that "just-in-time" mining of distributed knowledge sources is sometimes non-performant
and that central warehousing of knowledge concepts and relationships is desirable.  Also, several Translator architecture and reasoner 
teams currently use graph databases (Neo4j, RDF triple stores (e.g. Wikidata), custom graph stores (e.g. Minikanren file store) for 
accessing, persisting and annotating knowledge subgraphs (concept nodes and edges) retrieved by queries. The Translator team have therefore
recently converged on a proposal to develop a Translator-wide shared standards-driven knowledge graph.

This project serves as a hub for the collaboration, design and prototyping of such a Translator Knowledge Graph (TKG) resource.

# Getting Started

We will provide links to various Translator efforts supporting the goal of creating a shared Translator knowledge graph platform, but will
also attempt here to provide one or more reference implementations to drive the learning process of creating such a resource.

## Reference Beacon Prototype

The [Reference Knowledge Beacon ("RKB")](https://rkb.ncats.io) is a [Java language implementation](https://github.com/NCATS-Tangerine/reference-beacon) of the 
[Translator Knowledge Beacon API](https://github.com/NCATS-Tangerine/translator-knowledge-beacon) which wraps a Neo4j database
containing a substantial version (circa June 2016 release) of the Semantic Medline Database (plus some additional drug-disease)
relational statements, with associated evidence.  A set of batch loading scripts is available which can be used to batch load additional
data into the database.  The RKB beacon code itself is parameterized to point to any installation of Neo4j, hence, could be used, 
with some modifications (e.g. mapping of semantic fields to the biolink model), as one starting point to create a prototype of the TKG.

The RKB beacon code is already designed for Docker deployment.

