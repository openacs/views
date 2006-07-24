-- Views
--
-- Tracking and aggregating object views -- procedures.
--
-- Copyright (C) 2003 Jeff Davis
-- @author Jeff Davis <davis@xarg.net>
-- 
-- Adapted for Oracle by Mario Aguado <maguado@innova.uned.es>
-- @author Mario Aguado <maguado@innova.uned.es>
-- @creation-date 28/06/2006
--
-- @cvs-id $Id$
--
-- This is free software distributed under the terms of the GNU Public
-- License.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html
CREATE OR REPLACE PACKAGE views_view AS
 
	FUNCTION record_view (object_id IN acs_objects.object_id%TYPE,
							viewer_id IN views_views.viewer_id%TYPE) RETURN integer;
	--update the view count of object_id for viewer viewer_id, returns view count
END views_view;
/
CREATE OR REPLACE PACKAGE BODY views_view AS

	FUNCTION record_view (object_id IN acs_objects.object_id%TYPE, 
							viewer_id in views_views.viewer_id%TYPE) RETURN integer IS
	   v_count integer;
	   views_count  views_views.views_count%TYPE;
	BEGIN 
    	select count(*) into v_count from views_views where object_id = object_id and viewer_id = viewer_id;

	    if v_count = 0 then 
    	    INSERT into views_views(object_id,viewer_id) 
        	VALUES (object_id, viewer_id);
	        views_count := 0;
    	else
    	    select views_count into views_count from views_views where object_id = object_id and viewer_id = viewer_id;
	        UPDATE views_views
    	       SET views_count = views_count + 1, last_viewed = sysdate
        	 WHERE object_id = object_id
	           and viewer_id = viewer_id;
    	end if;
	    return views_count + 1;
	END record_view;

END views_view;
/ 
show errors;
