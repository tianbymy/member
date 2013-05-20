var myModal = '<div id="myModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" style="overflow: hidden;">'
$("#dg").html(myModal + '<%= j render_cell 'user', :new, :user=>@user %>' + '</div>');
$(".form-actions").append('<button type="reset" data-dismiss="modal" class="btn">关闭</button>');
$('#myModal').modal();
