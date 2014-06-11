
--
-- Function that accepts a Geometry and return a multi-point that covers either its MBR, or is clipped to a buffer of the polygon
--
create or replace function point_grid_from_geometry (geometry sdo_geometry, spacing number, clip boolean default true) 
return sdo_geometry is
	ll_x pls_integer;
	ll_y pls_integer;
	ur_x pls_integer;
	ur_y pls_integer;
	l_geometry sdo_geometry;
  l_ordinates sdo_ordinate_array;
begin
	-- Get the lower left, upper right coordinates
	ll_x := round(sdo_geom.sdo_min_mbr_ordinate(geometry,1));
	ll_y := round(sdo_geom.sdo_min_mbr_ordinate(geometry,2));	
	ur_x := round(sdo_geom.sdo_max_mbr_ordinate(geometry,1));
	ur_y := round(sdo_geom.sdo_max_mbr_ordinate(geometry,2));	

	-- align the grid to the input spacing
	ll_x := (ll_x - mod(ll_x, spacing));
	ll_y := (ll_y - mod(ll_y, spacing));
	ur_x := (ur_x - mod(ur_x, spacing) + spacing);
	ur_y := (ur_y - mod(ur_y, spacing) + spacing);

	-- Use recursive subquery factoring to generate the series of numbers (http://orafaq.com/wiki/Oracle_Row_Generator_Techniques)
	-- cross-join the x and y series
	-- unpivot the x and y into a single stream and bulk collect into the ordinate array
	select *
		bulk collect into l_ordinates 
	from (
		select coordinate
		from (
			select x.value as x, y.value as y
			from 
				(with data ( r ) as (select ll_x as r from dual union all select r + spacing from data where r < ur_x) select r as value from data) x 
			cross join
				(with data ( r ) as (select ll_y as r from dual union all select r + spacing from data where r < ur_y) select r as value from data) y)
		unpivot (coordinate for col in (x,y)) 
	);

	-- create the multi-point geometry
	l_geometry := sdo_geometry(2005, geometry.sdo_srid, null, sdo_elem_info_array(1, 1, l_ordinates.count/2), l_ordinates);
	
	if clip then
		-- intersect the multi-point geometry with a buffer of the input polygon
		l_geometry := sdo_geom.sdo_intersection(l_geometry, sdo_geom.sdo_buffer(sdo_cs.make_2d(geometry),spacing,0.005), 0.005);
	end if;
	
return l_geometry;

end point_grid_from_geometry;
/
show errors


--
-- Function that accepts start/end coordinates and returns a multi-point that covers the area at the specified spacing
--
create or replace function point_grid_from_start_end (start_x number, start_y number, end_x number, end_y number, spacing number, srid number) 
return sdo_geometry is
	ll_x pls_integer;
	ll_y pls_integer;
	ur_x pls_integer;
	ur_y pls_integer;
	l_geometry sdo_geometry;
  l_ordinates sdo_ordinate_array;
begin

	ll_x := start_x;
	ll_y := start_y;
	ur_x := end_x;
	ur_y := end_y;
	-- Use recursive subquery factoring to generate the series of numbers (http://orafaq.com/wiki/Oracle_Row_Generator_Techniques)
	-- cross-join the x and y series
	-- unpivot the x and y into a single stream and bulk collect into the ordinate array
	select *
		bulk collect into l_ordinates 
	from (
		select coordinate
		from (
			select x.value as x, y.value as y
			from 
				(with data ( r ) as (select ll_x as r from dual union all select r + spacing from data where r < (ur_x - spacing)) select r as value from data) x 
			cross join
				(with data ( r ) as (select ll_y as r from dual union all select r + spacing from data where r < (ur_y - spacing)) select r as value from data) y)
		unpivot (coordinate for col in (x,y)) 
	);

	-- create the multi-point geometry
	l_geometry := sdo_geometry(2005, srid, null, sdo_elem_info_array(1, 1, l_ordinates.count/2), l_ordinates);

return l_geometry;

end point_grid_from_start_end;
/
show errors


--
-- Function that accepts start/end coordinates and returns a multi-point that covers the area at the specified spacing
--
create or replace function point_grid_from_start_and_max (start_x number, start_y number, spacing number, max_points number, srid number)
return sdo_geometry is
	ll_x pls_integer;
	ll_y pls_integer;
	ur_x pls_integer;
	ur_y pls_integer;
	l_geometry sdo_geometry;
  l_ordinates sdo_ordinate_array;
begin

	-- align the grid to the input spacing
	ll_x := (start_x - mod(start_x, spacing));
	ll_y := (start_y - mod(start_y, spacing));
	ur_x := (start_x + (floor(sqrt(max_points) * spacing) - spacing));
	ur_y := (start_y + (floor(sqrt(max_points) * spacing) - spacing));
	
	-- Use recursive subquery factoring to generate the series of numbers (http://orafaq.com/wiki/Oracle_Row_Generator_Techniques)
	-- cross-join the x and y series
	-- unpivot the x and y into a single stream and bulk collect into the ordinate array
	select *
		bulk collect into l_ordinates 
	from (
		select coordinate
		from (
			select x.value as x, y.value as y
			from 
				(with data ( r ) as (select ll_x as r from dual union all select r + spacing from data where r < ur_x) select r as value from data) x 
			cross join
				(with data ( r ) as (select ll_y as r from dual union all select r + spacing from data where r < ur_y) select r as value from data) y)
		unpivot (coordinate for col in (x,y)) 
	);

	-- create the multi-point geometry
	l_geometry := sdo_geometry(2005, srid, null, sdo_elem_info_array(1, 1, l_ordinates.count/2), l_ordinates);
	dbms_output.put_line('num_points: ' || sdo_util.getnumvertices(l_geometry));
return l_geometry;

end point_grid_from_start_and_max;
/
show errors
