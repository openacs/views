-- packages/views/sql/postgresql/upgrade/upgrade-0.1d2-0.1d3.sql
--
-- Upgrade tables names and column to Oracle compatibility
--
-- Copyright (C) 2006 Innova - UNED
-- @author Mario Aguado <maguado@innova.uned.es>
-- @creation-date 20/07/2006
--
-- @cvs-id $Id$
--
-- This is free software distributed under the terms of the GNU Public
-- License.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html

--Drop function triggers

drop function views_upd_tr() cascade;
drop function views_ins_tr() cascade;
drop function views_by_type_ins_tr() cascade;
drop function views_by_type_upd_tr() cascade;

--Rename table and column name

alter table views rename column views to views_count;
alter table view_aggregates rename column views to views_count;
alter table views rename to views_views;
alter index views_viewer_idx rename to views_views_viewer_idx;

alter table views_by_type rename column views to views_count;
alter table view_aggregates_by_type rename column views to views_count;

alter table views_by_type rename column type to view_type;
alter table view_aggregates_by_type rename column type to view_type;

--Modify function with new table and column names.



-- added
select define_function_args('views__record_view','object_id,viewer_id');

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

--Create new triggers with new names

CREATE OR REPLACE FUNCTION views_views_ins_tr () RETURNS trigger AS $$
BEGIN
    if not exists (select 1 from view_aggregates where object_id = new.object_id) then 
        INSERT  INTO view_aggregates (object_id,views_count,unique_views,last_viewed) 
        VALUES (new.object_id,1,1,now());
    else
        UPDATE view_aggregates 
           SET views_count = views_count + 1, unique_views = unique_views + 1, last_viewed = now() 
         WHERE object_id = new.object_id;
    end if;

    return new;
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

CREATE OR REPLACE FUNCTION views_by_type_ins_tr () RETURNS trigger AS $$
BEGIN
    if not exists (select 1 from view_aggregates_by_type where object_id = new.object_id and view_type = new.view_type) then 
        INSERT INTO view_aggregates_by_type (object_id,view_type,views_count,unique_views,last_viewed) 
        VALUES (new.object_id,new.view_type,1,1,now());
    else
        UPDATE view_aggregates_by_type
           SET views_count = views_count + 1, unique_views = unique_views + 1, last_viewed = now() 
         WHERE object_id = new.object_id
           AND view_type = new.view_type;
    end if;

    return new;
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
