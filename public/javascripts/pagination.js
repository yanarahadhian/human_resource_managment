$(function() {
    $(".pages a").click(function(){
        $(".pages").html("Loading...");
        $.getScript(this.href);
        return false;
    });
});