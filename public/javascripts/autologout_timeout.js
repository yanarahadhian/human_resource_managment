var timer;
function updateActiveTime(platformUrl, userLogId){
  set_timeout(platformUrl, userLogId);
  $(document).bind('mousemove click keypress scroll', reset_timer);
}

function reset_timer(platformUrl, userLogId) {
  clearTimeout(timer);
  set_timeout(platformUrl, userLogId);
}

function set_timeout(platformUrl, userLogId) {
  timer=setTimeout(function(){logoutIfNoActivity(platformUrl, userLogId)},1000*5*60);	// 5 mins
}

function logoutIfNoActivity(platformUrl, userLogId ){
  $.get('/logout_by_checkloginstatus', function(data){
    if(data == '0'){
      window.location = '/logout';
    } else if(data == '-1'){
      window.location = platformUrl+'/api/'+userLogId+'/redirect_to_dashboard'
    }
  });
  timer=setTimeout(function(){logoutIfNoActivity(platformUrl, userLogId)},1000*5*60);	// 5 mins
}

