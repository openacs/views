-- Views
--
-- Tracking and aggregating object views - triggers for denormalization
--
-- Copyright (C) 2003 Jeff Davis
-- @author Jeff Davis <davis@xarg.net>
-- Adapted for Oracle by Mario Aguado <maguado@innova.uned.es>
-- @author Mario Aguado <maguado@innova.uned.es>
-- @creation-date 28/06/2006
--
-- @cvs-id $Id$
--
-- This is free software distributed under the terms of the GNU Public
-- License.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html
CREATE OR REPLACE TRIGGER views_views_ins_tr AFTER INSERT ON views_views
FOR EACH ROW
DECLARE 
	v_count integer;
BEGIN
    select count(*) into v_count from view_aggregates where object_id = :new.object_id;
    if v_count  < 1 then 
        INSERT  INTO view_aggregates (object_id,views_count,unique_views,last_viewed) 
        VALUES (:new.object_id,1,1,sysdate);
    else
        UPDATE view_aggregates 
           SET views_count = views_count + 1, unique_views = unique_views + 1, last_viewed = sysdate 
         WHERE object_id = :new.object_id;
    end if;
end;
/
CREATE OR REPLACE TRIGGER views_views_upd_tr 
AFTER UPDATE ON views_views
FOR EACH ROW
BEGIN
    UPDATE view_aggregates 
       SET views_count = views_count + 1, last_viewed = sysdate
     WHERE object_id = :new.object_id;
END;
/
-- XXXJCD: Should there be a delete trigger?
