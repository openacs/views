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
    {-type ""}
} {
    Record an object view by viewer_id

    @param dimension_key
    @param object_id 

    @return the total view count for the user

    @author Jeff Davis davis@xarg.net
    @creation-date 2004-01-30
} {
    if { $type ne "" } {
	if { [lsearch [list views unique_views last_viewed] $type] >= 0 } {
	    # if the type is on of the list it will conflict on the views::get procedure
	    error "views::record_view type cannot be views, unique_views or last_viewed"
	}
	set views_by_type [db_string record_view_by_type "select views_by_type__record_view(:object_id, :viewer_id, :type)" -default 1]
    }

    if {[catch {db_string record_view "select views__record_view(:object_id, :viewer_id)" -default 1} views]} {
	set views 0
    }
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
        db_foreach select_views_by_type {
	    select type, views
              from view_aggregates_by_type
             where object_id = :object_id
	} {
	    set ret($type) $views
	}
        return [array get ret]
    }
    return {views {} unique_views {} last_viewed {}}
}


ad_proc -public views::viewed_p { 
    -object_id
    {-user_id 0}
    {-type ""}
} {
    if {!$user_id} {
        set user_id [ad_conn user_id]
    }
    if { $type ne "" } {
	return [db_string get_viewed_by_type_p {
	    select count(*)
	      from views_by_type
	     where object_id = :object_id
	       and viewer_id = :user_id
	       and type = :type
	} -default 0]
    } else {
	return [db_string get_viewed_p {
	    select count(*)
	      from views
	     where object_id = :object_id
	       and viewer_id = :user_id
	} -default 0]
    }

}
