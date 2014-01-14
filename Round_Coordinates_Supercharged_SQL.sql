--
-- Assuming a table name of TEST_DATA in schema SCOTT, with geometry column GEOMETRY.
-- The scripts below demonstate methods of rounding data rapidly without resorting to 
-- a function call which will dramatically slow down the process on large datasets.
-- 
-- John O'Toole 14-JAN-2014
--

--
-- Point data can be updated simply by updating the sdo_point.  This example assumes the data is x,y,z
--
update test_data t set 
	t.geometry.sdo_point.x = round(t.geometry.sdo_point.x, 2),
	t.geometry.sdo_point.y = round(t.geometry.sdo_point.y, 2),
	t.geometry.sdo_point.z = round(t.geometry.sdo_point.z, 2)
where t.geometry.sdo_gtype = 3001;

--
-- This SQL statement will round line and polygon data.  This technique updates the sdo_ordinate_array 
-- directly without resorting to a function call.
--
update /*+ rowid(t) */ test_data t
  set t.geometry.sdo_ordinates = 
	(select cast(collect(round(t2.column_value, 2)) as sdo_ordinate_array)  
		 from test_data t1, table(t1.geometry.sdo_ordinates) t2  
		where t1.rowid = t.rowid)
and geometry is not null
and mod(t.geometry.sdo_gtype,10) in (2,3,6,7);


--
-- Taking it a step further, use dbms_parallel_execute to parallelize the statement.
-- Note that the schema needs the "CREATE JOB" privilage to execute this.
--
declare
 l_sql_stmt varchar2(1000);
 c_task_name  constant varchar2 (20) := 'ROUNDING';
 l_round_factor pls_integer := 2;
 l_chunk_size pls_integer := 500;
 l_parallel_level pls_integer := 8;
begin

  -- create a task
  dbms_parallel_execute.create_task(c_task_name);

  -- chunk the table by ROWID
   dbms_parallel_execute.create_chunks_by_rowid (
		 task_name => c_task_name
		 , table_owner => 'SCOTT'
		 , table_name => 'TEST_DATA'
		 , by_row => true
		 , chunk_size =>  l_chunk_size
		 );

  -- execute the dml in parallel
  l_sql_stmt := 'update /*+ rowid(t) */ test_data t
  set t.geometry.sdo_ordinates = 
	(select cast(collect(round(t2.column_value, ' || l_round_factor || ')) as sdo_ordinate_array)  
		 from test_data t1, table(t1.geometry.sdo_ordinates) t2  
		where t1.rowid = t.rowid)
  where rowid between :start_id and :end_id
	and geometry is not null
	and mod(t.geometry.sdo_gtype,10) in (2,3,6,7)
	';

	  dbms_parallel_execute.run_task (task_name => c_task_name
      , sql_stmt => l_sql_stmt
      , language_flag => dbms_sql.native
      , parallel_level => l_parallel_level
      );
			
  -- done with processing; drop the task
  dbms_parallel_execute.drop_task(c_task_name);
commit;	
end;
/
