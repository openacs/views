-- Upgrade Views recording functions to atomic INSERT ... ON CONFLICT.
--
-- Existing installations need these replacements as well as fresh installs.
-- Preserve the function signatures, ownership, grants and existing rows.
-- Aggregate maintenance continues through the existing row triggers.
--
-- Copyright (C) 2026 Gustaf Neumann
-- This is free software distributed under the terms of the GNU Public License.

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
