$(document).ready(function() {
            liveStats();
});

    /*LIVE CHECK USER LOGIN/LOGOUT*/
        function  liveStats() {
                $.ajax({
                        url : "<?php echo Router::url('/', true); ?>checkuserlogout",
                        success : function (data) {
                                //alert(data);
                                //$("#targetStatusUser").html(data);
                                if(data == 'false') { //if user still login
                                        return false;
                                } else {
                                        window.location='<?php echo Router::url('/', true); ?>users/logout2';
                                }
                        }
                });
                setTimeout("liveStats()", 3000);
        }

