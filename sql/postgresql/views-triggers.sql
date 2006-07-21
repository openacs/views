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

create function views_views_ins_tr () returns opaque as '
begin
    if not exists (select 1 from view_aggregates where object_id = new.object_id) then 
        INSERT  INTO view_aggregates (object_id,views_count,unique_views,last_viewed) 
        VALUES (new.object_id,1,1,now());
    else
        UPDATE view_aggregates 
           SET views_count = views_count + 1, unique_views = unique_views + 1, last_viewed = now() 
         WHERE object_id = new.object_id;
    end if;

    return new;
end;' language 'plpgsql';

create trigger views_views_ins_tr 
after insert on views_views
for each row
execute procedure views_views_ins_tr();

create function views_views_upd_tr () returns opaque as '
begin
    UPDATE view_aggregates 
       SET views_count = views_count + 1, last_viewed = now() 
     WHERE object_id = new.object_id;

    return new;
end;' language 'plpgsql';

create trigger views_views_upd_tr
after update on views_views
for each row
execute procedure views_views_upd_tr();

-- XXXJCD: Should there be a delete trigger?
