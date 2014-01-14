Oracle_Spatial_SQL_Scripts
==========================

Some random Oracle Spatial SQL Scripts


*** create_grids.sql *** 
SQL and PL/SQL to create three types of grids:
 - An Orthoganal grid of lines *not split* at each junction
 - An Orthoganal grid of lines *split* at each junction
 - An Orthoganal grid of lines *split* at each junction
 
*** Round_Coordinates_Supercharged_SQL.sql ***
Techniques to round data directly via SQL rather than using a function call.  For large datasets, this can help 
improve performance dramatically.  
The script also demonstrates the use of dbms_parallel_execute to parallelize the statement. 
dbms_parallel_execute is a useful technique to parallelize SQL on SDO_GEOMETRY updates as typical Parallel DML cannot be 
executed on object types ( http://docs.oracle.com/cd/E11882_01/server.112/e25523/parallel003.htm#VLDBG1455 ).
