Oracle_Spatial_SQL_Scripts
==========================

Some random Oracle Spatial SQL Scripts


### create_grids.sql

SQL and PL/SQL to create three types of grids:
 - An Orthoganal grid of lines *not split* at each junction
 - An Orthoganal grid of lines *split* at each junction
 - An Orthoganal grid of lines *split* at each junction
 
### create_point_sets.sql

Functions to create multi-point geometries 

Function  | Description
------------- | -------------
point_grid_from_geometry()  | Function that accepts a Geometry and return a multi-point that covers either its MBR, or is clipped to a buffer of the polygon
point_grid_from_start_end() | Function that accepts start/end coordinates and returns a multi-point that covers the area at the specified spacing
point_grid_from_start_and_max() | Function that accepts start/end coordinates and returns a multi-point that covers the area at the specified spacing

And a method of inserting into a table a series of points filling a grid space.

### Round_Coordinates_Supercharged_SQL.sql

Techniques to round data directly via SQL rather than using a function call.  For large datasets, this can help 
improve performance dramatically.  
The script also demonstrates the use of dbms_parallel_execute to parallelize the statement. 
dbms_parallel_execute is a useful technique to parallelize SQL on SDO_GEOMETRY updates as typical Parallel DML cannot be 
executed on object types ( https://docs.oracle.com/database/121/VLDBG/GUID-6626C70C-876C-47A4-8C01-9B66574062D8.htm#GUID-6626C70C-876C-47A4-8C01-9B66574062D8 ).
