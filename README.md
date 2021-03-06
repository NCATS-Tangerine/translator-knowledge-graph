# Translator Knowledge Graph

Practical experience with graph algorithms suggest that "just-in-time" mining of distributed knowledge sources is sometimes non-performant
and that central warehousing of knowledge concepts and relationships is desirable.  Also, several Translator architecture and reasoner 
teams currently use graph databases (Neo4j, RDF triple stores (e.g. Wikidata), custom graph stores (e.g. Minikanren file store) for 
accessing, persisting and annotating knowledge subgraphs (concept nodes and edges) retrieved by queries. The Translator team have therefore
recently converged on a proposal to develop a Translator-wide shared standards-driven knowledge graph.

This project serves as a hub for the collaboration, design and prototyping of such a Translator Knowledge Graph (TKG) resource.  In addition to this README, we are using the [project repository wiki](https://github.com/NCATS-Tangerine/translator-knowledge-graph/wiki) to document design discussions and cross link with resources.

# Getting Started

We will provide links to various Translator efforts supporting the goal of creating a shared Translator knowledge graph platform, but will
also attempt here to provide one or more reference implementations to drive the learning process of creating such a resource.

## Standards Feeding into the TKG

The design of the TKG can be seen at three levels:

1. *Ontology Standards*: common concept types and predicates. The [Biolink Model](https://github.com/biolink/biolink-model) is proposed to coordinate these standards. A CSV of a subset of Translator-specific excerpts of the model are [here](https://github.com/NCATS-Tangerine/translator-knowledge-beacon/blob/develop/api/types.csv). Discussions about predicates (coordinated by Matt Brush) are summarized in a worksheet [here](https://docs.google.com/spreadsheets/d/1zXitcR1QjHyh6WocukgshSR7IoAVg7MJQG-HNh96Jec/edit#gid=3366698).
2. *Data Model*: referring to the general schema to represent knowledge graph nodes and edges. At the moment, we are focused on a Neo4j specification of node labels and property tags (see [discussion](https://github.com/NCATS-Tangerine/translator-knowledge-graph/wiki/Consensus-Neo4j-Schema-to-Represent-Knowledge-Graph-Nodes-and-Edges)) but this could be generalized to other formats such as [RDF triple stores](). Once again, the [Biolink Model](https://github.com/biolink/biolink-model)  of classes and slots may translate into such a specification.
3. *Input/Output Exchange Formats*: for importing and exporting knowledge (sub)graphs to/from the TKG. A [JSON-LD draft specification for standardized Reasoning Tool API responses](https://docs.google.com/document/d/1O6_sVSdSjgMmXacyI44JJfEVQLATagal9ydWLBgi-vE/edit) that was initiated by members of the Translator community, may be a worthy starting point.

# Exploratory Software Implementations

* A prototype version of the TKG is being developed, as described in the [project repository wiki](https://github.com/NCATS-Tangerine/translator-knowledge-graph/wiki/Reference-Knowledge-Beacon-as-Prototype-TKG) and in the [database folder](https://github.com/NCATS-Tangerine/translator-knowledge-graph/database/README.md) of the TKG project.
