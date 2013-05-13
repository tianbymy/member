$("#dg").html("<%= j render :partial =>'reset_password', :locals =>{:user => @user} %>");
$('#myModal').modal({
  keyboard: false
});