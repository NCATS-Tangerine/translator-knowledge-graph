// @author Richard Bruskiewich (minor modifications)
//
// This Cypher Query Language (CQL) Script to be used to transform
// the original RKB concept semantics into a TKG / Biolink model compliant encoding
//
// The original RKB has two concept node property tags, one old ('type') and one new ('semanticGroup')
//
// In the proposed TKG standard, these are replaced by a 'category' Neo4j property tag
// and the UMLS Semantic Group label rewritten into its corresponding Biolink Model concept type label.
//
MATCH (concept:Concept)
SET concept.category = 
   CASE
		WHEN concept.semanticGroup = "ACTI" THEN "activity and behaviour"
		WHEN concept.semanticGroup = "ANAT" THEN "anatomical entity"
		WHEN concept.semanticGroup = "CHEM" THEN "chemical substance"
		WHEN concept.semanticGroup = "CONC" THEN "information content entity"
		WHEN concept.semanticGroup = "DEVI" THEN "device"
		WHEN concept.semanticGroup = "DISO" THEN "disease"
		WHEN concept.semanticGroup = "GENE" THEN "genomic entity"
		WHEN concept.semanticGroup = "GEOG" THEN "geographic location"
		WHEN concept.semanticGroup = "LIVB" THEN "organismal entity"
		WHEN concept.semanticGroup = "OBJC" THEN "named thing"
		WHEN concept.semanticGroup = "OCCU" THEN "named thing"
		WHEN concept.semanticGroup = "ORGA" THEN "administrative entity"
		WHEN concept.semanticGroup = "PHEN" THEN "phenomenon"
		WHEN concept.semanticGroup = "PHYS" THEN "physiology"
		WHEN concept.semanticGroup = "PROC" THEN "procedure"
		ELSE "named thing"
   END
REMOVE concept.semanticGroup, concept.type
;
 
