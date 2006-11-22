<?xml version="1.0"?>
<queryset>
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="views::record_view.record_view">      
	<querytext>
	begin
        :1 := views_view.record_view(p_object_id => :object_id, 
        			     p_viewer_id => :viewer_id);
    end;
	</querytext>
</fullquery>

</queryset>