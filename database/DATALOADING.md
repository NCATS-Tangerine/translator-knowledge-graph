#Translator Knowledge Graph (TKG) Data Loading Protocol#

This data loading protocol describes how to input a set of correctly formatted TSV data files into your own copy of the TKG. Here are the steps:

1. The main production server is best first turned off 

	sudo /etc/init.d/neo4j stop

2.  Create symbolic link ('ln -s') named "import" under /usr/share/neo4j (in linux) and point your TSV data files.

Under Microsoft Windows, you can put your data files into an "import" subdirectory located 
within the directory you have specified as the location of your database (if not the default directory).

You can also specify absolute file paths in the script, by commenting out the following directive:
 
	dbms.directories.import=import directive 

in the neo4j.conf file.

2.  For running this, we need to run from neo4j-shell, or running each command from within the Neo4j web page command shell.  (Ensure that your shell is configured to point to the target database, if not the default). Under UNIX:

	/usr/share/neo4j/bin/neo4j-shell

Under Microsoft Windows, you may need to run the shell inside a PowerShell as an Administrator. The neo4j-shell is best run as user 'Neo4j', NOT as root (sudo), i.e.

	sudo su neo4j

Note that running as regular sudo (root) is dangerous since parts of the database data and log files may end up having incorrect file permissions, which will prevent future neo4j sessions 
from running (in fact, they may silently fail!). In fact, if you have problems running the database at any point, you might wish to double check the file permissions in the
data folders (e.g. within the directory /var/lib/neo4j/data/databases/graph.db).

You will likely wish to run the dataloader inside a directory where the user 'neo4j' has local file permissions to write a local log file.

Note that you may need to ensure that you have a large enough data heap for Neo4j to load (versus simply running the database later...).
The neo4j-shell doesn't seem to see the heap settings in neo4j.conf but does accept direct JVM parameters in the environment variable JAVA_OPTS.

For example, if you wish to set a huge heap for loading (recommended!), on a very large (>120GB) AWS instance, the following seems to work:

	JAVA_OPTS=-Xmx80g

3.  Loading of data requires the running of the Cypher loading scripts 
under the ~/database/scripts folder of the translator-knowledge-graph project.
 Assuming that the neo4j-shell is on your path:
	
	neo4j-shell -v -path /path/to/database/graph.db -file /path/to/translator-knowledge-graph/database/scripts/tkg_dataloader.cql > tkg_dataloader.out 2>&1

(where '/path/to/database/graph.db' may typically be something like '/var/lib/neo4j/data/databases/graph.db').

Before using the script, you may (especially in Microsoft Windows), you *may* sometimes need to 
make a copy of the script and fix the file paths. 

Unix file paths will be something like:

	file:///data_file.tsv

whereas under Windows, you may need a path like:

	file:/C:/data_file.tsv

where your data resides on C: drive (for example). 

TODO: At some point, we will fix the scripting system to parameterize this for you.

4. Check whether or not your *.out log file shows any batch loading errors to correct.  A common failure is one of data access.
Your LOAD CSV commands may assume a data access path for 'file://' protocols different from expected. Generally, an absolute unix
file path follows the file:// protocol. Obviously, the permissions for reading the input data should be set permissive for Neo4j access. 
For example, your data may be under /opt/data, hence, the CSV target should be something like 'file:///opt/data/<path-to-data-file>.tsv'

5. Finally, after apparently successful batch CQL data loading, you might attempt to restart the main neo4j database to see the data, i.e.

	sudo /etc/init.d/neo4j start

You should probably exit the neo4j user shell first, since the neo4j user account may not have sudo access!

The data should now be visible when you run the Web Application, as per instructions in the main project README file.

# Clearing the Database

If you wish to clear out your local copy of the TKG database (to reload it), 
you can got to the Neo4j web interface, and type the following Cypher command:

	MATCH (n) DETACH DELETE n;
