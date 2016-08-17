jQuery(document).ready(function() {
  /* Tree Menu */
  $('.tree_menu li')
  .css('pointer','default')
  .css('list-style-image','none');
  //
  $('.tree_menu li:has(ul) a')
  .click(function(event){
    var liParent = $(this).parent("li");
    $(this).children("span").toggleClass("drop_arrow_ico4").toggleClass("arrow_ico2");
    $(liParent).children("ul").toggle();
  });
  $('.tree_menu li:has(ul)').children("ul").hide();
  $('.tree_menu li:has(ul)').children("ul .active").show();
  $('li:not(:has(ul))').css({
    cursor: 'default',
    'list-style-image':'none'
  });
  // Folder Tree LV-1
  $('.tree_menu_folder li')
  .css('pointer','default')
  .css('list-style-image','none');
  $('.tree_menu_folder li:has(ul) a')
  .click(function(event){
    //if (this == event.target) {
    var liParent = $(this).parent("li");
    $(this).children("span").toggleClass("drop_arrow_ico4").toggleClass("arrow_ico2");
    $(liParent).children("ul").toggle();
  //}return false;
  });
  $('.tree_menu_folder li:has(ul)').children("ul").hide();
  $('li:not(:has(ul))').css({
    cursor: 'default',
    'list-style-image':'none'
  });
  // Folder Tree LV-2
  $('#treeview li')
  .css('pointer','default')
  .css('list-style-image','none');
  $('#treeview li:has(ul) a')
  .click(function(event){
    //if (this == event.target) {
    var liParent = $(this).parent("li");
    $(this).children("span").toggleClass("folder-open-ico").toggleClass("folder-close-ico").removeClass("drop_arrow_ico4, arrow_ico2");
    $(this).children("ul").toggle();
  //}return false;
  });

  $('#treeview li:has(ul)').children("ul").hide();
  $('li:not(:has(ul))').css({
    cursor: 'default',
    'list-style-image':'none'
  });
/* End Tree menu*/

});

function showFlashMessage(data){
  $('.notify_error .message').text(data);
  $('.notify_error').slideDown("fast");
  removeNotifyMessage();
}

function removeNotifyMessage(){
  setTimeout("HideNotifyMessage()",7000);
}

function HideNotifyMessage(){
  $(".notify_error").hide().html('<span class="message"></span><a class="icons close-error-icon right" onclick="CloseNotify()";return false;">&nbsp;</a>');
}

function showNewDivision(id){
  if (id == 'custom' || id == 'cancel'){
    $('#new_division').load('/division_form_for_employment/'+id);
  }
}

function showPasswordField(){
  if($('#spv_chd').is(":checked")){
    $("#password_field").show();
  }else{
    $("#password_field").hide();
  }
  return false;
}

function showActiveUntill(val){
  var a = val.indexOf('SP');
  if(a != -1){
    $('#active_until').show();
  }else{
    $('#active_until').hide();
  }
  return false;
}

$(function() {
  $('form a.add_child').click(function() {
    var assoc   = $(this).attr('data-association');
    var content = $('#' + assoc + '_fields_template').html();
    var regexp  = new RegExp('new_' + assoc, 'g');
    var new_id  = new Date().getTime();

    $(this).parent().before(content.replace(regexp, new_id));
    return false;
  });

  $('form a.remove_child').live('click', function() {
    var hidden_field = $(this).prev('input[type=hidden]')[0];
    if(hidden_field) {
      hidden_field.value = '1';
    }
    $(this).parents('.fields').hide();
    return false;
  });
});

function fnSetKey( aoData, sKey, mValue ){
  for ( var i=0, iLen=aoData.length ; i<iLen ; i++ ){
    if ( aoData[i].name == sKey ){
      aoData[i].value = mValue;
    }
  }
}

function fnGetKey( aoData, sKey ){
  for ( var i=0, iLen=aoData.length ; i<iLen ; i++ ){
    if ( aoData[i].name == sKey ){
      return aoData[i].value;
    }
  }
  return null;
}


$(function() {
  $("#person_table th a, #person_table .pagination a").live("click", function() {
    $.getScript(this.href);
    return false;
  });
//$("#products_search input").keyup(function() {
//  $.get($("#person_search").attr("action"), $("#person_search").serialize(), null, "script");
//  return false;
//});
});

function refresh_page(page){
  jQuery.ajax({
    beforeSend:function(request){
      $('.ajax-load').show();
    },
    complete:function(request){
      $('.ajax-load').hide();
    },
    success:function(request){
      $('.input-data').empty(); $('#app_two_con').html(request);
      removeNotifyMessage()
    },
    error:function(request){
      alert('error');
    },
    url:'/'+page
  });
}

function refresh_page_with_note(page,note){
  jQuery.ajax({
    beforeSend:function(request){
      $('.ajax-load').show();
    },
    complete:function(request){
      $('.ajax-load').hide();
    },
    success:function(request){
      ShowNotifyMessage(note);
      $('.input-data').empty(); $('#app_two_con').html(request);
      removeNotifyMessage()
    },
    error:function(request){
      alert('error');
    },
    url:'/'+page
  });
}
