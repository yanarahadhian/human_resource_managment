$(document).ready(function(){
  $('#person_tax_status_id').change(function(){
    var n = $(this).val();
    var title;
    switch(n){
      case '1' :
        title = "T/0: status pajak untuk yang tidak menikah dan tidak menanggung orangtua. Besar PTKP adalah 1320000.";
        break;
      case '2' :
        title = "T/1: status pajak untuk yang tidak menikah dan menanggung satu orang. Besar PTKP adalah 1430000.";
        break;
      case '3' :
        title = "T/2: status pajak untuk yang tidak menikah dan menanggung dua orang. Besar PTKP adalah 1540000.";
        break;
      case '4' :
        title = "T/3: status pajak untuk yang tidak menikah dan menanggung tiga orang. Besar PTKP adalah 1650000.";
        break;
      case '5' :
        title = "K/0: status pajak untuk yang menikah, tidak menanggung keluarga. Besar PTKP adalah 1430000.";
        break;
      case '6' :
        title = "K/1: status pajak untuk yang menikah dan menanggung satu orang. Besar PTKP adalah 1540000.";
        break;
      case '7' :
        title = "K/2: status pajak untuk yang menikah dan menanggung dua orang. Besar PTKP adalah 1650000.";
        break;
      case '8' :
        title = "K/3: status pajak untuk yang menikah dan menanggung tiga orang. Besar PTKP adalah 1760000.";
        break;
    // default : title = "Explanation Above than 9";
    }
    $(this).attr("bt-xtitle",title);
    var background = 'rgba(251,251,251,0.9)';
    var border = '#A9D5F2';
    var font_color = '#557F9B';
    $('.tooltip').bt({
      showTip: function(box) {
        $(box).fadeIn('fast');
      },
      shrinkToFit: true,
      hoverIntentOpts: {
        interval: 0,
        timeout: 0
      },
      positions: ['right', 'right'],
      fill: background,
      strokeStyle: border,
      overlap: 0,
      centerPointY: 1,
      centerPointX: 0,
      cornerRadius: 4,
      right: 20,
      cssStyles: {
        fontFamily: 'Arial,"Lucida Grande",Helvetica,Arial,Verdana,sans-serif',
        fontSize: '12px',
        color: font_color,
        width: 'auto',
        padding: 5
      },
      shadow: true,
      shadowColor: 'rgba(0,0,0,.2)',
      shadowBlur: 5,
      shadowOffsetX: 0,
      shadowOffsetY: 0
    });
  });
});