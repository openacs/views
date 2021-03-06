-- Views
--
-- Tracking and aggregating object views...
--
-- Copyright (C) 2007 Mario
-- @author Mario Aguado
-- @creation-date 2007-07-30
--
-- @cvs-id $Id$
-- Adapted to Oracle from Jeff Davis <davis@xarg.net> postgresql's implementation
-- This is free software distributed under the terms of the GNU Public
-- License.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html

CREATE TABLE VIEWS_VIEWS (
        OBJECT_ID       INTEGER
                        CONSTRAINT VIEWS_VIEWS_OBJECT_ID_FK
                        REFERENCES ACS_OBJECTS(OBJECT_ID) ON DELETE CASCADE
                        CONSTRAINT VIEWS_VIEWS_OBJECT_ID_NN
                        NOT NULL,
        VIEWER_ID       INTEGER
                        CONSTRAINT VIEWS_VIEWS_OWNER_ID_FK
                        REFERENCES PARTIES(PARTY_ID) ON DELETE CASCADE
                        CONSTRAINT VIEWS_VIEWS_VIEWER_ID_NN
                        NOT NULL,
        VIEWS_COUNT           INTEGER DEFAULT 1,
        LAST_VIEWED     DATE DEFAULT SYSDATE,
        CONSTRAINT VIEWS_VIEWS_PK 
        PRIMARY KEY (OBJECT_ID, VIEWER_ID)
);

CREATE UNIQUE INDEX VIEWS_VIEWS_VIEWER_IDX ON VIEWS_VIEWS(VIEWER_ID, OBJECT_ID);

COMMENT ON TABLE VIEWS_VIEWS IS '
        A SIMPLE COUNT OF HOW MANY TIMES AN OBJECT IS VIEWED.
';

CREATE TABLE VIEW_AGGREGATES (
        OBJECT_ID       INTEGER
                        CONSTRAINT VIEW_AGGS_OBJECT_ID_FK
                        REFERENCES ACS_OBJECTS(OBJECT_ID) ON DELETE CASCADE
                        CONSTRAINT VIEW_AGGS_OBJECT_ID_NN
                        NOT NULL 
                        CONSTRAINT VIEW_AGGREGATESS_PK 
                        PRIMARY KEY,
        VIEWS_COUNT           INTEGER DEFAULT 1,
        UNIQUE_VIEWS    INTEGER DEFAULT 1,
        LAST_VIEWED     DATE DEFAULT SYSDATE
);

COMMENT ON TABLE VIEW_AGGREGATES IS '
        A SIMPLE COUNT OF HOW MANY TIMES AN OBJECT IS VIEWED, MULTIPLE VISITS
        TRIGGER MAINTAINED BY UPDATES ON VIEWS.
';


CREATE TABLE VIEWS_BY_TYPE (
        OBJECT_ID       INTEGER
                        CONSTRAINT VIEWS_BY_TYPE_OBJECT_ID_FK
                        REFERENCES ACS_OBJECTS(OBJECT_ID) ON DELETE CASCADE
                        CONSTRAINT VIEWS_BY_TYPE_OBJECT_ID_NN
                        NOT NULL,
        VIEWER_ID       INTEGER
                        CONSTRAINT VIEWS_BY_TYPE_OWNER_ID_FK
                        REFERENCES PARTIES(PARTY_ID) ON DELETE CASCADE
                        CONSTRAINT VIEWS_BY_TYPE_VIEWER_ID_NN
                        NOT NULL,
        VIEW_TYPE       VARCHAR(100) NOT NULL,
        VIEWS_COUNT     INTEGER DEFAULT 1,
        LAST_VIEWED     DATE DEFAULT SYSDATE,
        CONSTRAINT VIEWS_BY_TYPE_PK 
        PRIMARY KEY (OBJECT_ID, VIEWER_ID, VIEW_TYPE)
);

CREATE UNIQUE INDEX VIEWS_BY_TYPE_VIEWER_IDX ON VIEWS_BY_TYPE(VIEWER_ID, OBJECT_ID, VIEW_TYPE);

COMMENT ON TABLE VIEWS_BY_TYPE IS '
        A SIMPLE COUNT OF HOW MANY TIMES AN OBJECT IS VIEWED FOR EACH TYPE.
';

CREATE TABLE VIEW_AGGREGATES_BY_TYPE (
        OBJECT_ID       INTEGER
                        CONSTRAINT VIEW_AGG_B_TYPE_OB_ID_FK
                        REFERENCES ACS_OBJECTS(OBJECT_ID) ON DELETE CASCADE
                        CONSTRAINT VIEW_AGG_B_TYPE_OB_ID_NN
                        NOT NULL,
        VIEW_TYPE       VARCHAR(100) NOT NULL,
        VIEWS_COUNT     INTEGER DEFAULT 1,
        UNIQUE_VIEWS    INTEGER DEFAULT 1,
        LAST_VIEWED     DATE DEFAULT SYSDATE,
        CONSTRAINT VIEW_AGGREGATES_BY_TYPE_PK
        PRIMARY KEY (OBJECT_ID, VIEW_TYPE)
);

COMMENT ON TABLE VIEW_AGGREGATES_BY_TYPE IS '
        A SIMPLE COUNT OF HOW MANY TIMES AN OBJECT IS VIEWED FOR EACH TYPE,
        MULTIPLE VISITS TRIGGER MAINTAINED BY UPDATES ON VIEWS_BY_TYPE.
';

