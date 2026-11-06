-- Views
--
-- Tracking and aggregating object views - triggers for denormalization
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

CREATE OR REPLACE FUNCTION views_views_ins_tr () RETURNS trigger AS $$
BEGIN
    INSERT INTO view_aggregates AS a
        (object_id, views_count, unique_views, last_viewed)
    VALUES
        (NEW.object_id, 1, 1, now())
    ON CONFLICT (object_id)
    DO UPDATE SET
        views_count = a.views_count + 1,
        unique_views = a.unique_views + 1,
        last_viewed = now();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

create trigger views_views_ins_tr 
after insert on views_views
for each row
execute procedure views_views_ins_tr();

CREATE OR REPLACE FUNCTION views_views_upd_tr () RETURNS trigger AS $$
BEGIN
    UPDATE view_aggregates 
       SET views_count = views_count + 1, last_viewed = now() 
     WHERE object_id = new.object_id;

    return new;
END;
$$ LANGUAGE plpgsql;

create trigger views_views_upd_tr
after update on views_views
for each row
execute procedure views_views_upd_tr();

-- XXXJCD: Should there be a delete trigger?

CREATE OR REPLACE FUNCTION views_by_type_ins_tr () RETURNS trigger AS $$
BEGIN
    INSERT INTO view_aggregates_by_type AS a
        (object_id, view_type, views_count, unique_views, last_viewed)
    VALUES
        (NEW.object_id, NEW.view_type, 1, 1, now())
    ON CONFLICT (object_id, view_type)
    DO UPDATE SET
        views_count = a.views_count + 1,
        unique_views = a.unique_views + 1,
        last_viewed = now();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

create trigger views_by_type_ins_tr 
after insert on views_by_type
for each row
execute procedure views_by_type_ins_tr();

CREATE OR REPLACE FUNCTION views_by_type_upd_tr () RETURNS trigger AS $$
BEGIN
    UPDATE view_aggregates_by_type 
       SET views_count = views_count + 1, last_viewed = now() 
     WHERE object_id = new.object_id
       AND view_type = new.view_type;

    return new;
END;
$$ LANGUAGE plpgsql;

create trigger views_by_type_upd_tr
after update on views_by_type
for each row
execute procedure views_by_type_upd_tr();

