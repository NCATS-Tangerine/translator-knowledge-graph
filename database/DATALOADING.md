#Knowledge.Bio Release 2.3 Neo4j SemMedDB Data Loading Protocol#

This data loading current targets for input the set of pipe-delimited data files 
dumped, table-by-table, from a MySQL instance of the Semantic Medline Database (SemMedDb).

##Basic Steps:##

1.  Create symbolic link ('ln -s') named "import" under /usr/share/neo4j (in linux) and point your /semmeddb_*_* files.
Under Microsoft Windows, you can put your data files into an "import" subdirectory located within the directory you have specified as the location of your database (if not the default directory).

You can also specify absolute file paths in the script, by commenting out the following directive:
 
	dbms.directories.import=import directive 

in the neo4j.conf file.

2.  We have to run CSV loader in particular sequence :

	Reference, Sentence, Predication, SentencePredication, ExplicitConcept, ConceptSemanticType, PredicationArgument, Definition

3.  For running this, we need to run from neo4j-shell, or running each command from within the Neo4j web page command shell.  (Ensure that your shell is configured to point to the target database, if not the default). Under UNIX:

	/usr/share/neo4j/bin/neo4j-shell

Under Microsoft Windows, you may need to run the shell inside a PowerShell as an Administrator.
	 
4.  Loading of data requires the running of the Cypher loading scripts under the ~kb2/dataloader/scripts folder:

	./neo4j-shell -c < /path/to/kb2/dataloader/scripts/somescript.cql

There may be various versions of 'cql' scripts found inside this folder. The script name helps identify which one you need. 
Generally, the higher Version 'V#' numbered script is the most correct one to run, but read the inline comments in the script file
and check your file input formats to be sure.

For KB3, for example, reading in WikiData encoded SemMedDB data will use the kb3_semmeddb_concepts_dataloader-V5.cql and
kb3_semmeddb_statement_dataloader-V5.cql, to separately load concepts and statements, or perhaps the kb3_V5_dataloader.cql which loads them both.

Before using these scripts, you may (especially in Microsoft Windows), you *may* sometimes need to fix the file paths. Unix file paths will be something like:

	file:///data_file.tsv

whereas under Windows, you may need a path like:

	file:/C:/data_file.tsv

where your data resides on C: drive (for example).
 

5. The data should now be visible when you run the Web Application, as per instructions in the main README file.

6. If you wish to clear out the database (to reload it), you can got to the Neo4j web interface, i.e. http://localhost:7474, and type the following Cypher command:

	MATCH (n) DETACH DELETE n;
	
#UPDATED INSTRUCTIONS FOR LOADING AWS NEO4J 3.1 SERVER INSTANCE ... TO BE MERGED#

#Direct Loading of an AWS Ubuntu Hosted Neo4j 3.1 Database#

One can directly load the KB 3.0 database using suitable CQL scripts, but the task is tricky.

1. The main production server is best first turned off 

	sudo /etc/init.d/neo4j stop

2. The neo4j-shell is best run as user 'Neo4j', NOT as root (sudo), i.e.

	sudo su neo4j

Running as sudo (root) is dangerous since parts of the database data and log files 
may end up having incorrect file permissions, which will prevent future neo4j sessions 
from running (in fact, they may silently fail!). In fact, if you have problems 
running the database at any point, you might wish to double check the file permissions in the
data folders (e.g. within the directory /var/lib/neo4j/data/databases/graph.db)

3. You will likely wish to run the dataloader inside a directory where user neo4j has local file permissions to write a local log file.

4. Under 3.1, the neo4j-shell is likely best run directly against the graph database directory, that is, with a database -path, i.e.

	neo4j-shell -v -path /var/lib/neo4j/data/databases/graph.db -file /home/ubuntu/kb3_V5_dataloader.cql > kb3_V5_dataloader.out 2>&1

Note that you may need to ensure that you have a large enough data heap for Neo4j to load (versus simply running the database later...).
The neo4j-shell doesn't seem to see the heap settings in neo4j.conf but does accept direct JVM parameters in the environment variable JAVA_OPTS.

For example, if you wish to set a huge heap for loading (recommended!), on a very large (>120GB) AWS instance, the following seems to work:

	JAVA_OPTS=-Xmx80g

5. Check whether or not your *.out log file shows any batch loading errors to correct.  A common failure is one of data access.
Your LOAD CSV commands may assume a data access path for 'file://' protocols different from expected. Generally, an absolute unix
file path follows the file:// protocol. Obviously, the permissions for reading the input data should be set permissive for Neo4j access. For example, your data may be under /opt/data, hence, the CSV target should be something like 'file:///opt/data/<path-to-data-file>.tsv'

6. Finally, after apparently successful batch CQL data loading, you might attempt to restart the main neo4j database to see the data, i.e.

	sudo /etc/init.d/neo4j start

You should probably exit the neo4j user shell first, since the neo4j user account may not have sudo access!

 