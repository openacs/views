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
    v_views integer;
BEGIN
    INSERT INTO views_views AS v
        (object_id, viewer_id, views_count, last_viewed)
    VALUES
        (p_object_id, p_viewer_id, 1, now())
    ON CONFLICT (object_id, viewer_id)
    DO UPDATE SET
        views_count = v.views_count + 1,
        last_viewed = now()
    RETURNING views_count INTO v_views;

    RETURN v_views;
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
    v_views views_by_type.views_count%TYPE;
BEGIN
    INSERT INTO views_by_type AS v
        (object_id, viewer_id, view_type, views_count, last_viewed)
    VALUES
        (p_object_id, p_viewer_id, p_view_type, 1, now())
    ON CONFLICT (object_id, viewer_id, view_type)
    DO UPDATE SET
        views_count = v.views_count + 1,
        last_viewed = now()
    RETURNING views_count INTO v_views;

    RETURN v_views;
END;
$$ LANGUAGE plpgsql;


comment on function views_by_type__record_view(integer, integer, varchar) is 'update the view by type count of object_id for viewer viewer_id, returns view count';

select define_function_args('views_by_type__record_view','object_id,viewer_id,view_type');
