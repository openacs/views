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

create or replace function views__record_view (integer, integer) returns integer as '
declare
    p_object_id alias for $1;
    p_viewer_id alias for $2;
    v_views    views.views%TYPE;
begin 
    select views into v_views from views where object_id = p_object_id and viewer_id = p_viewer_id;

    if v_views is null then 
        INSERT into views(object_id,viewer_id) 
        VALUES (p_object_id, p_viewer_id);
        v_views := 0;
    else
        UPDATE views
           SET views = views + 1, last_viewed = now()
         WHERE object_id = p_object_id
           and viewer_id = p_viewer_id;
    end if;

    return v_views + 1;
end;' language 'plpgsql';

comment on function views__record_view(integer, integer) is 'update the view count of object_id for viewer viewer_id, returns view count';

select define_function_args('views__record_view','object_id,viewer_id');

create or replace function views_by_type__record_view (integer, integer, varchar) returns integer as '
declare
    p_object_id alias for $1;
    p_viewer_id alias for $2;
    p_type      alias for $3;
    v_views    views.views%TYPE;
begin 
    select views into v_views from views_by_type where object_id = p_object_id and viewer_id = p_viewer_id and type = p_type;

    if v_views is null then 
        INSERT into views_by_type(object_id,viewer_id,type) 
        VALUES (p_object_id, p_viewer_id,p_type);
        v_views := 0;
    else
        UPDATE views_by_type
           SET views = views + 1, last_viewed = now(), type = p_type
         WHERE object_id = p_object_id
           and viewer_id = p_viewer_id
           and type = p_type;
    end if;

    return v_views + 1;
end;' language 'plpgsql';

comment on function views_by_type__record_view(integer, integer, varchar) is 'update the view by type count of object_id for viewer viewer_id, returns view count';

select define_function_args('views_by_type__record_view','object_id,viewer_id,type');
