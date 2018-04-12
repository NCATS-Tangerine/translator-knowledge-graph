// @author Richard Bruskiewich (minor modifications)
//
// This Cypher Query Language (CQL) Script is for 
// loading a file of WikiData-entity and property 
// indexed SemMedDb concept and statement data
//
// Input data are in tab delimited table files, one statement per row
//
// The script uses the CSV loader functionality of Neo4j.
//
// We've attempted to avoid 'Eager' CSV loading of the data
// (see http://www.markhneedham.com/blog/2014/10/23/neo4j-cypher-avoiding-the-eager/ for details)
//
// See the DATALOADING_R3_README.md for 
// more details on how to run this script.
//
// Version 6 of this script fixes 'Eager' loading issues
// for Evidence and Statement loading
//
// Version 7 loads a 'semanticGroup' property into Concepts 
// instead of 'type' property found in the V6 and earlier versions
//

// First, clean out the database(?)
//MATCH (n) DETACH DELETE n;

//****** WikiData Entities ******
MERGE (database:ExternalDatabase:IdentifiedEntity:DatabaseEntity{name : "WikiData Entity"})
ON CREATE SET database.name = "WikiData Entity",
    database.description = "WikiData Entities",
    database.url = "http://www.wikidata.org/entity/",
    database.nameSpacePrefix = "wd",
    database.accessionId = "wd:DB",
    database.versionDate = timestamp(),
    database.version = toInteger('1')
;

//
// concepts.tsv file format
//
// Columns: 
//
//		qid		semantic_groups		preflabel	synonyms	definition
//
// Where qid is the object id of a WikiData entity
//

//******Concept Loader*****
CREATE CONSTRAINT ON (concept:Concept) ASSERT concept.uri IS UNIQUE;

// Create Index for making initial search faster (need to review)
CREATE INDEX ON : Concept(name);
CREATE INDEX ON : Concept(usage);
CREATE INDEX ON : Concept(semanticGroup);

USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "file:///semmeddb/concepts.tsv" AS row FIELDTERMINATOR '\t'
WITH 
	row AS row, 
	"http://www.wikidata.org/entity/"+row.qid AS concept_uri,
	CASE  
		WHEN length(trim(row.semantic_groups)) = 0 THEN "OBJC"
		
		// if more than one semantic_groups specified, pick first one only for now
		WHEN size(split(row.semantic_groups,"|"))>1 THEN head(split(row.semantic_groups,"|")) 
		
		ELSE row.semantic_groups
	END AS concept_semanticGroup
WHERE NOT concept_uri IS NULL
MERGE (concept:Concept:AnnotatedEntity:IdentifiedEntity:DatabaseEntity { uri : concept_uri } )
ON CREATE SET 
    concept.uri = concept_uri,
    concept.accessionId = "wd:"+row.qid,
    concept.semanticGroup = concept_semanticGroup,
    concept.name = row.preflabel,
    concept.description = row.definition,
    concept.synonyms = row.synonyms,
    concept.usage = toInteger('0'),
    concept.versionDate = timestamp(),
    concept.version = toInteger('1')
MERGE (concept)-[:LIBRARY]->(library:Library)
ON CREATE SET 
    library.numberOfArchivedMaps = toInteger('0'),
    library.name = concept.name +"_Library",
    library.description = "Library Of "+ concept.name,
    library.accessionId = concept.accessionId,
    library.versionDate = timestamp(),
    library.version = toInteger('1')
;

// statements.tsv file format used for (meta-)data other than core concept descriptions
//
// Columns: 
//
// subject_qid	property_id	object_qid	reference_uri	reference_supporting_text	reference_date
//
// Where *_qid and property_id are object ids of WikiData entities, 
//

//******Predicate Loader*****
CREATE CONSTRAINT ON (predicate:Predicate) ASSERT predicate.uri IS UNIQUE;

// ... Capture Predicates from property_id columns in the input file...
USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "file:///semmeddb/statements.tsv" AS row FIELDTERMINATOR '\t'
WITH 
	row AS row, 
	"http://www.wikidata.org/entity/"+row.property_id AS property_uri
MERGE (predicate:Predicate:IdentifiedEntity:DatabaseEntity { uri : property_uri })
ON CREATE SET 
    predicate.uri = property_uri,
    predicate.accessionId = "wd:"+row.property_id,
    predicate.versionDate = timestamp(),
    predicate.version = toInteger('1')
;

//****** PubMed Catalog ******
MERGE (database:ExternalDatabase:IdentifiedEntity:DatabaseEntity{name : "PubMed"})
ON CREATE SET database.name = "PubMed",
    database.description = "Public Library of Medicine",
    database.url = "https://www.ncbi.nlm.nih.gov/pubmed/",
    database.nameSpacePrefix = "pmid",
    database.accessionId = "pmid:DB",
    database.versionDate = timestamp(),
    database.version = toInteger('1')
;

//******Reference loader******
// Here we assume PubMed identifiers... needs to be generalized
CREATE CONSTRAINT ON (reference:Reference) ASSERT reference.uri IS UNIQUE;
CREATE CONSTRAINT ON (reference:Reference) ASSERT reference.accessionId IS UNIQUE;

USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "file:///semmeddb/statements.tsv" AS row FIELDTERMINATOR '\t'
WITH row, last(split(row.reference_uri,"/")) AS pmid, split(row.reference_date,"-") AS date
WHERE NOT row.reference_uri IS NULL
MERGE (reference:Reference:AnnotatedEntity:IdentifiedEntity:DatabaseEntity { uri : row.reference_uri })
ON CREATE SET 
    reference.uri = row.reference_uri,
    reference.accessionId = "pmid:"+pmid,
    reference.pmid = pmid,
    reference.name = "pmid:"+pmid,
    reference.description = "",
    reference.year = CASE 
    					 WHEN 
    					 	size(date) < 3 OR 
    					 	trim(date[0]) = 'not set' OR 
    					 	length(trim(date[0])) = 0 
    					 THEN toInteger('0') 
    					 ELSE toInteger(date[0]) 
    				  END, 
    reference.month   = CASE 
    					WHEN size(date) < 3 OR 
    					 	 trim(date[0]) = 'not set' OR 
    					 	 length(trim(date[1])) = 0 
    					THEN toInteger('0') 
    					ELSE toInteger(date[1]) 
    				  END, 
    reference.day  = CASE 
    					WHEN size(date) < 3 OR 
    					 	 trim(date[0]) = 'not set' OR 
    					 	 length(trim(date[2])) = 0 
    					THEN toInteger('0') 
    					ELSE toInteger(date[2]) 
    				  END, 
    reference.versionDate = timestamp(),
    reference.version = toInteger('1')   
;

//******Annotation loader******
CREATE CONSTRAINT ON (annotation:Annotation) ASSERT annotation.accessionId IS UNIQUE;

// First, create the Annotation...
USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "file:///semmeddb/statements.tsv" AS row FIELDTERMINATOR '\t'
WITH row AS row, "pmid:"+last(split(row.reference_uri,"/")) AS name
MERGE (annotation:Annotation:IdentifiedEntity:DatabaseEntity { accessionId : "kba."+name })
ON CREATE SET 
    annotation.uri = "http://knowledge.bio/annotation/"+name,
    annotation.accessionId = "kba."+name,
    annotation.name = row.reference_supporting_text,
    annotation.description = "",
    annotation.versionDate = timestamp(),
    annotation.version = toInteger('1')	
;

// ...then, connect it to the Reference
USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "file:///semmeddb/statements.tsv" AS row FIELDTERMINATOR '\t'
WITH row AS row, "kba.pmid:"+last(split(row.reference_uri,"/")) AS annotationId
MATCH (reference:Reference   { uri : row.reference_uri })
MATCH (annotation:Annotation { accessionId : annotationId })
MERGE (annotation)-[:REFERENCE]->(reference)
;

//******Evidence Loader******
// Evidence node used to anchor Annotation associated with Reference uri's
CREATE CONSTRAINT ON (evidence:Evidence) ASSERT evidence.accessionId   IS UNIQUE;

// To avoid EAGER loads, should perform the Evidence MERGE once to create the Evidence...
// Note that you don't need  to MATCH the component nodes simply to create the Evidence
// but simply need to compile the stmtId from CSV inputs...
//
USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "file:///semmeddb/statements.tsv" AS row FIELDTERMINATOR '\t'
WITH row.subject_qid + "." + row.property_id + "." + row.object_qid  AS stmtId
MERGE (evidence:Evidence:IdentifiedEntity:DatabaseEntity { accessionId : "kbe:"+stmtId })
ON CREATE SET 
    evidence.uri = "http://knowledge.bio/evidence/"+stmtId,
    evidence.name = "",
    evidence.description = "",
	evidence.count = toInteger('0'),
    evidence.versionDate = timestamp(),
    evidence.version = toInteger('1')
;

// Then, link the Evidence to its Annotation...
USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "file:///semmeddb/statements.tsv" AS row FIELDTERMINATOR '\t'
WITH 
	"kbe:" + row.subject_qid + "." + row.property_id + "." + row.object_qid  AS evidenceId,
	"kba.pmid:"+last(split(row.reference_uri,"/")) AS annotationId
MATCH (evidence:Evidence:IdentifiedEntity:DatabaseEntity { accessionId : evidenceId })
MATCH (annotation:Annotation { accessionId : annotationId })
MERGE (evidence)-[:ANNOTATION]->(annotation)
ON CREATE SET evidence.count = evidence.count + 1
;

//******Statement Loader******
CREATE CONSTRAINT ON (statement:Statement)   ASSERT statement.accessionId  IS UNIQUE;

// Same issue as with Evidence above:
// To avoid EAGER loads, should perform the Statement MERGE once to create the Statement node...
// Note that you don't need  to MATCH the component nodes simply to create the Statement node...
// but rather simply need to compile the stmtId from CSV inputs...
// Note, however, with the new RDF input format, we don't really know
// How to set the 'name' attribute of the statement since 
// the subject/relation/object name components will later be retrieved from WikiData(?)
//

// First, create the Statement by identifier
USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "file:///semmeddb/statements.tsv" AS row FIELDTERMINATOR '\t'
WITH row.subject_qid + "." + row.property_id + "." + row.object_qid  AS stmtId
MERGE (stmt:Statement:IdentifiedEntity:DatabaseEntity { accessionId : "kbs:"+stmtId })
ON CREATE SET 
    stmt.description = "",
    stmt.uri = "http://knowledge.bio/statement/"+stmtId,
    stmt.accessionId = "kbs:"+stmtId,
    stmt.versionDate = timestamp(),
    stmt.version = toInteger('1')
;

// ...Now, link everything up...
USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "file:///semmeddb/statements.tsv" AS row FIELDTERMINATOR '\t'
WITH 
	row as row,
	"http://www.wikidata.org/entity/"+row.subject_qid AS subject_uri,
	"http://www.wikidata.org/entity/"+row.property_id AS property_uri,
	"http://www.wikidata.org/entity/"+row.object_qid  AS object_uri,
	row.subject_qid + "." + row.property_id + "." + row.object_qid  AS stmtId
MATCH (subject:Concept    { uri : subject_uri })
MATCH (relation:Predicate { uri : property_uri })
MATCH (object:Concept     { uri : object_uri })
MATCH (evidence:Evidence:IdentifiedEntity:DatabaseEntity { accessionId : "kbe:"+stmtId })
MATCH (stmt:Statement:IdentifiedEntity:DatabaseEntity    { accessionId : "kbs:"+stmtId })
MERGE (subject)<-[:SUBJECT]-(stmt)-[:OBJECT]->(object)
ON CREATE SET subject.usage = subject.usage + 1, object.usage = object.usage + 1
MERGE (relation)<-[:RELATION]-(stmt)-[:EVIDENCE]->(evidence)
ON CREATE SET evidence.count = toInteger('1')
ON MATCH  SET evidence.count = evidence.count + 1
;

// Finally, "warm" up the cache...
//MATCH (n)
//OPTIONAL MATCH (n)-[r]->()
//RETURN count(n) + count(r);

