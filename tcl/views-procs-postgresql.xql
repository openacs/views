<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="views::record_view.record_view">      
	<querytext>
	select views__record_view(:object_id, :viewer_id)
	</querytext>
</fullquery>

</queryset>