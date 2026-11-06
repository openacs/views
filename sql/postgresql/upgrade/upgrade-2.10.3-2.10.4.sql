-- Make aggregate creation atomic for concurrent first views.
--
-- Replace only the INSERT trigger functions. Keep existing triggers, UPDATE
-- trigger functions, ownership, grants and aggregate data unchanged.
--
-- Copyright (C) 2026 Gustaf Neumann
-- This is free software distributed under the terms of the GNU Public License.

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
