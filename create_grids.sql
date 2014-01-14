----------------------------------
----- Setup
----------------------------------
create table grid_lines (
	id	number primary key,
	geometry	sdo_geometry,
	update_date	date);

insert into user_sdo_geom_metadata values ('GRID_LINES','GEOMETRY', 
	sdo_dim_array(
	sdo_dim_element('X',400000,750000,0.0005), 
	sdo_dim_element('Y',500000,1000000,0.0005)), 
2157);
commit;

----------------------------------------------------------------
-- Create an Orthoganal grid of lines *not split* at each junction
----------------------------------------------------------------
drop index grid_lines_spind;
truncate table grid_lines;
declare
	l_counter pls_integer := 0;
	geometry sdo_geometry;
	l_num_lines_x pls_integer;
	l_num_lines_y pls_integer;
	l_start_x pls_integer;
	l_start_y pls_integer;
	l_end_x pls_integer;
	l_end_y pls_integer;
	l_grid_size pls_integer;
	l_curr_x pls_integer;
	l_curr_y pls_integer;
	l_srid pls_integer; 
begin
	l_grid_size	:= 10000;	-- grid spacing
	l_start_x		:= 400000;  -- define extents beyond Ireland
	l_end_x			:= 800000;
	l_start_y		:= 500000;
	l_end_y			:= 1000000;
	l_srid			:= 2157;
	
	-- how many lines in x do we need?
	l_num_lines_x := ceil((l_end_x-l_start_x) / l_grid_size);
	-- how many lines in y do we need?
	l_num_lines_y := ceil((l_end_y-l_start_y) / l_grid_size);

	-- insert a line for each step in the x direction
	for x in 0..l_num_lines_x loop
		l_curr_x := l_start_x + (l_grid_size * x);
		geometry := sdo_geometry(2002, l_srid, null, sdo_elem_info_array(1,2,1), sdo_ordinate_array(l_curr_x, l_start_y, l_curr_x, l_end_y));
		l_counter := l_counter + 1;
		insert into grid_lines(id, geometry, update_date) values (l_counter, geometry, sysdate);
	end loop;

	-- insert a line for each step in the y direction
	for y in 0..l_num_lines_y loop
		l_curr_y := l_start_y + (l_grid_size * y);
		geometry := sdo_geometry(2002, l_srid, null, sdo_elem_info_array(1,2,1), sdo_ordinate_array(l_start_x, l_curr_y, l_end_x, l_curr_y));
		l_counter := l_counter + 1;
		insert into grid_lines(id, geometry, update_date) values (l_counter, geometry, sysdate);
	end loop;
commit;	
end;
/

create index grid_lines_spind on grid_lines(geometry) indextype is mdsys.spatial_index;

----------------------------------------------------------------
-- Create an Orthoganal grid of lines *split* at each junction
----------------------------------------------------------------

drop index grid_lines_spind;
truncate table grid_lines;
declare
	l_counter			pls_integer := 0;
	geometry		sdo_geometry;
	l_num_lines_x		pls_integer;
	l_num_lines_y		pls_integer;
	l_initial_x		pls_integer;
	l_initial_y		pls_integer;
	l_end_x pls_integer;
	l_end_y pls_integer;
	l_grid_size pls_integer;
	l_curr_x pls_integer;
	l_curr_y pls_integer;
	l_next_x pls_integer;
	l_next_y pls_integer;
	l_srid pls_integer; 	
begin
	l_grid_size	:= 10000;	-- grid spacing
	l_initial_x	:= 400000;  -- define extents beyond ireland
	l_end_x			:= 800000;
	l_initial_y	:= 500000;
	l_end_y			:= 1000000;
	l_srid 			:= 2157;
	
	-- how many lines in x do we need?
	l_num_lines_x := ceil((l_end_x-l_initial_x) / l_grid_size);

	-- how many lines in y do we need?
	l_num_lines_y := ceil((l_end_y-l_initial_y) / l_grid_size);

	-- insert a line for each step in the x direction
	for x in 0..l_num_lines_x loop
		l_curr_x := l_initial_x + (l_grid_size * x);
		l_curr_y := l_initial_y;

		for i in 0..(l_num_lines_y-1) loop
			l_next_y := l_curr_y + l_grid_size;
			geometry := sdo_geometry(2002, l_srid, null, sdo_elem_info_array(1,2,1), sdo_ordinate_array(l_curr_x, l_curr_y, l_curr_x, l_next_y));
			insert into grid_lines(id, geometry, update_date) values (l_counter, geometry, sysdate);
			l_curr_y := l_next_y;
			l_counter := l_counter + 1;
		end loop;

	end loop;

	-- insert a line for each step in the x direction
	for y in 0..l_num_lines_y loop
		l_curr_y := l_initial_y + (l_grid_size * y);
		l_curr_x := l_initial_x;

		for i in 0..(l_num_lines_x-1) loop
			l_next_x := l_curr_x + l_grid_size;
			geometry := sdo_geometry(2002, l_srid, null, sdo_elem_info_array(1,2,1), sdo_ordinate_array(l_curr_x, l_curr_y, l_next_x, l_curr_y));
			insert into grid_lines(id, geometry, update_date) values (l_counter, geometry, sysdate);
			l_curr_x := l_next_x;
			l_counter := l_counter + 1;
		end loop;
	end loop;
end;
/
commit;
create index grid_lines_spind on grid_lines(geometry) indextype is mdsys.spatial_index;

----------------------------------------------------------------
-- Create an Orthoganal grid of polygons
----------------------------------------------------------------

drop index grid_lines_spind;
truncate table grid_lines;
declare
	l_counter			pls_integer := 0;
	geometry		sdo_geometry;
	l_num_lines_x		pls_integer;
	l_num_lines_y		pls_integer;
	l_initial_x		pls_integer;
	l_initial_y		pls_integer;
	l_end_x pls_integer;
	l_end_y pls_integer;
	x_l_grid_size pls_integer;
	y_l_grid_size pls_integer;
	l_curr_x pls_integer;
	l_curr_y pls_integer;
	l_next_x pls_integer;
	l_next_y pls_integer;
	l_srid pls_integer; 		
begin
	x_l_grid_size	:= 10000;		-- grid spacing for x axis
	y_l_grid_size	:= 10000;		-- grid spacing for y axis
	l_initial_x		:= 400000;  -- define extents 
	l_end_x				:= 800000;
	l_initial_y		:= 500000;
	l_end_y				:= 1000000;
	l_srid				:= 2157;

	-- how many cells in x do we need?
	l_num_lines_x := ceil((l_end_x-l_initial_x) / x_l_grid_size);

	-- how many cells in y do we need?
	l_num_lines_y := ceil((l_end_y-l_initial_y) / y_l_grid_size);

	-- insert a polygon for each step in the x and y directions
	for x in 0..l_num_lines_x loop
		l_curr_x := l_initial_x + (x_l_grid_size * x);
		l_curr_y := l_initial_y;

		for i in 0..(l_num_lines_y-1) loop
			l_next_x := l_curr_x + x_l_grid_size;
			l_next_y := l_curr_y + y_l_grid_size;
			
			-- form the polygon
			geometry := sdo_geometry(2003, l_srid, null, sdo_elem_info_array(1,1003,3), sdo_ordinate_array(l_curr_x, l_curr_y, l_next_x, l_next_y));

			insert into grid_lines(id, geometry, update_date) values (l_counter, geometry, sysdate);
			l_curr_y := l_next_y;
			l_counter := l_counter + 1;
		end loop;

	end loop;

end;
/
commit;
create index grid_lines_spind on grid_lines(geometry) indextype is mdsys.spatial_index;
