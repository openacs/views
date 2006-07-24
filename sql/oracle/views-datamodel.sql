-- Views
--
-- Tracking and aggregating object views...
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

create table views_views (
        object_id       integer
                        constraint views_views_object_id_fk
                        references acs_objects(object_id) on delete cascade
                        constraint views_views_object_id_nn
                        not null,
        viewer_id       integer
                        constraint views_views_owner_id_fk
                        references parties(party_id) on delete cascade
                        constraint views_views_viewer_id_nn
                        not null,
        views_count           integer default 1,
        last_viewed     date default sysdate,
        constraint views_views_pk 
        primary key (object_id, viewer_id)
);

create unique index views_views_viewer_idx on views_views(viewer_id, object_id);

comment on table views_views is '
        a simple count of how many times an object is viewed.
';

create table view_aggregates (
        object_id       integer
                        constraint view_aggs_object_id_fk
                        references acs_objects(object_id) on delete cascade
                        constraint view_aggs_object_id_nn
                        not null 
                        constraint view_aggregatess_pk 
                        primary key,
        views_count           integer default 1,
        unique_views    integer default 1,
        last_viewed     date default sysdate
);

comment on table view_aggregates is '
        a simple count of how many times an object is viewed, multiple visits
        trigger maintained by updates on views.
';
