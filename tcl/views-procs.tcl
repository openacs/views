# /packages/cop-base/tcl/ratings-procs.tcl
ad_library {
    TCL library for recoding views

    @author Jeff Davis <davis@xarg.net>

    @creation-date 2004-05-20
    @cvs-id $Id$
}

namespace eval views {}

ad_proc -public views::record_view {
    -object_id
    -viewer_id
} {
    Record an object view by viewer_id

    @param dimension_key
    @param object_id 

    @return the total view count for the user

    @author Jeff Davis davis@xarg.net
    @creation-date 2004-01-30
} {
    set views [db_string record_view "select views__record_view(:object_id, :viewer_id)" -default 1]

    return $views
}

ad_proc -public views::get { 
    -object_id
} {

    Return an array (which you have to set with "array set your_array [views::get -object_id $object_id]") with the elements:
    <ul>
    <li>views
    <li>unique_views
    <li>last_viewed
    </ul>
    
    @param object_id ID of the object for which you want to return the views
} {
    if {[db_0or1row views {
        SELECT views, unique_views, to_char(last_viewed,'YYYY-MM-DD HH24:MI:SS') as last_viewed
        FROM view_aggregates
        WHERE object_id = :object_id
    } -column_array ret] } {
        return [array get ret]
    }

    return {views {} unique_views {} last_viewed {}}
}

ad_proc -public views::viewed_p { 
    -object_id
    {-user_id 0}
} {
    if {!$user_id} {
        set user_id [ad_conn user_id]
    }
    return [db_string get_viewed_p {
        select count(*)
        from views
        where object_id = :object_id
              and viewer_id = :user_id
    } -default 0]
}
