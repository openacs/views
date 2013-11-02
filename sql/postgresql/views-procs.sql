-- Views
--
-- Tracking and aggregating object views -- procedures.
--
-- Copyright (C) 2003 Jeff Davis
-- @author Jeff Davis <davis@xarg.net>
-- @creation-date 1/12/2003
--
-- @cvs-id $Id$
--
-- This is free software distributed under the terms of the GNU Public
-- License.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html



--
-- procedure views__record_view/2
--
CREATE OR REPLACE FUNCTION views__record_view(
   p_object_id integer,
   p_viewer_id integer
) RETURNS integer AS $$
DECLARE
    v_views    views_views.views_count%TYPE;
BEGIN 
    select views_count into v_views from views_views where object_id = p_object_id and viewer_id = p_viewer_id;

    if v_views is null then 
        INSERT into views_views(object_id,viewer_id) 
        VALUES (p_object_id, p_viewer_id);
        v_views := 0;
    else
        UPDATE views_views
           SET views_count = views_count + 1, last_viewed = now()
         WHERE object_id = p_object_id
           and viewer_id = p_viewer_id;
    end if;

    return v_views + 1;
END;
$$ LANGUAGE plpgsql;

comment on function views__record_view(integer, integer) is 'update the view count of object_id for viewer viewer_id, returns view count';

select define_function_args('views__record_view','object_id,viewer_id');



--
-- procedure views_by_type__record_view/3
--
CREATE OR REPLACE FUNCTION views_by_type__record_view(
   p_object_id integer,
   p_viewer_id integer,
   p_view_type varchar
) RETURNS integer AS $$
DECLARE
    v_views     views_views.views_count%TYPE;
BEGIN 
    select views_count into v_views from views_by_type where object_id = p_object_id and viewer_id = p_viewer_id and view_type = p_view_type;

    if v_views is null then 
        INSERT into views_by_type(object_id,viewer_id,view_type) 
        VALUES (p_object_id, p_viewer_id,p_view_type);
        v_views := 0;
    else
        UPDATE views_by_type
           SET views_count = views_count + 1, last_viewed = now(), view_type = p_view_type
         WHERE object_id = p_object_id
           and viewer_id = p_viewer_id
           and view_type = p_view_type;
    end if;

    return v_views + 1;
END;
$$ LANGUAGE plpgsql;

comment on function views_by_type__record_view(integer, integer, varchar) is 'update the view by type count of object_id for viewer viewer_id, returns view count';

select define_function_args('views_by_type__record_view','object_id,viewer_id,view_type');
