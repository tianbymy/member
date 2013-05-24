$("#dg").html('<%= j render_cell 'user', :update_info, :user=>@user %>');
$('#myModal').modal();
