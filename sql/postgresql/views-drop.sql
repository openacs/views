-- drop the tracking and aggregating object views...
-- 
-- Copyright (C) 2003 Jeff Davis
-- @author Jeff Davis davis@xarg.net
-- @creation-date 10/22/2003
--
-- @cvs-id $Id$
--
-- This is free software distributed under the terms of the GNU Public
-- License.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html

select drop_package('views');
drop table view_aggregates;
drop table views;
drop function views_upd_tr();
drop function views_ins_tr();

