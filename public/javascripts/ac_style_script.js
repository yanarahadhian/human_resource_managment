(function($) {
	
	$.fn.zoomListener = function () {
		var data = this.data("zoomEvent"); 
		if(!data){
			this.data("zoomEvent", data = {
				interval: 20,
				lastWidth: 0,
				lastHeight: 0/*,
				lastFontSize: 0*/
			});
			data = this.data("zoomEvent"); 
		}
		this.animate({opacity:"1.0"}, data.interval, function() {
			
			$(this).toggle().zoomListener();
			var widthNow = $(window).width() /*fontSizeNow = 100 * $("body").height()/heightNow*/,heightNow = $(window).height();
			if (data.lastWidth !== widthNow/* || data.lastFontSize !== fontSizeNow*/){	// || data.lastHeight !== heightNow){
				$(this).data("zoomEvent",{
					interval: data.interval,
					lastWidth: widthNow,
					lastHeight: heightNow/*,
					lastFontSize: fontSizeNow*/
				});
				$.event.trigger("documentzoom",$(this).data("zoomEvent"));	
			}
		
			return $(this);
		});
	}
	
	$(document).ready(function(){
		$("script:first").zoomListener();
	})
	

})(jQuery);



/** Zoom Resize */
$(document).ready(function($){
				// zoomEvent exposes its internal data, alongside a regular jQuery Event.
				$(document).bind("documentzoom",function(event,data){
					$('#main-content').css("min-height", data.lastHeight);
				});
});



/* Tooltip (Please Include bt.js) */
$(document).ready(function() {
	var background = 'rgba(251,251,251,0.9)';
	var border = '#A9D5F2';
	var font_color = '#557F9B';
	$('.bt-tooltip-bt').bt({
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
		hadowOffsetY: 0
	});
}); 

/* Glowing Howto*/
/** Plugins */
(function(jQuery) {
/*
 * jQuery Color Animations
 * Copyright 2007 John Resig
 * Released under the MIT and GPL licenses.
 */

// We override the animation for all of these color styles
jQuery.each(['backgroundColor', 'borderBottomColor', 'borderLeftColor', 'borderRightColor', 'borderTopColor', 'color', 'outlineColor'], function(i,attr){
		jQuery.fx.step[attr] = function(fx){
				if ( fx.state == 0 ) {
						fx.start = getColor( fx.elem, attr );
						fx.end = getRGB( fx.end );
				}

				fx.elem.style[attr] = "rgb(" + [
						Math.max(Math.min( parseInt((fx.pos * (fx.end[0] - fx.start[0])) + fx.start[0]), 255), 0),
						Math.max(Math.min( parseInt((fx.pos * (fx.end[1] - fx.start[1])) + fx.start[1]), 255), 0),
						Math.max(Math.min( parseInt((fx.pos * (fx.end[2] - fx.start[2])) + fx.start[2]), 255), 0)
				].join(",") + ")";
		}
});

// Color Conversion functions from highlightFade
// By Blair Mitchelmore
// http://jquery.offput.ca/highlightFade/

// Parse strings looking for color tuples [255,255,255]
function getRGB(color) {
		var result;

		// Check if we're already dealing with an array of colors
		if ( color && color.constructor == Array && color.length == 3 )
				return color;

		// Look for rgb(num,num,num)
		if (result = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(color))
				return [parseInt(result[1]), parseInt(result[2]), parseInt(result[3])];

		// Look for rgb(num%,num%,num%)
		if (result = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(color))
				return [parseFloat(result[1])*2.55, parseFloat(result[2])*2.55, parseFloat(result[3])*2.55];

		// Look for #a0b1c2
		if (result = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(color))
				return [parseInt(result[1],16), parseInt(result[2],16), parseInt(result[3],16)];

		// Look for #fff
		if (result = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(color))
				return [parseInt(result[1]+result[1],16), parseInt(result[2]+result[2],16), parseInt(result[3]+result[3],16)];

		// Look for rgba(0, 0, 0, 0) == transparent in Safari 3
		if (result = /rgba\(0, 0, 0, 0\)/.exec(color))
				return colors['transparent']

		// Otherwise, we're most likely dealing with a named color
		return colors[jQuery.trim(color).toLowerCase()];
}

function getColor(elem, attr) {
		var color;

		do {
				color = jQuery.curCSS(elem, attr);

				// Keep going until we find an element that has color, or we hit the body
				if ( color != '' && color != 'transparent' || jQuery.nodeName(elem, "body") )
						break;

				attr = "backgroundColor";
		} while ( elem = elem.parentNode );

		return getRGB(color);
};

// Some named colors to work with
// From Interface by Stefan Petre
// http://interface.eyecon.ro/

var colors = {
	aqua:[0,255,255],
	azure:[240,255,255],
	beige:[245,245,220],
	black:[0,0,0],
	blue:[0,0,255],
	brown:[165,42,42],
	cyan:[0,255,255],
	darkblue:[0,0,139],
	darkcyan:[0,139,139],
	darkgrey:[169,169,169],
	darkgreen:[0,100,0],
	darkkhaki:[189,183,107],
	darkmagenta:[139,0,139],
	darkolivegreen:[85,107,47],
	darkorange:[255,140,0],
	darkorchid:[153,50,204],
	darkred:[139,0,0],
	darksalmon:[233,150,122],
	darkviolet:[148,0,211],
	fuchsia:[255,0,255],
	gold:[255,215,0],
	green:[0,128,0],
	indigo:[75,0,130],
	khaki:[240,230,140],
	lightblue:[173,216,230],
	lightcyan:[224,255,255],
	lightgreen:[144,238,144],
	lightgrey:[211,211,211],
	lightpink:[255,182,193],
	lightyellow:[255,255,224],
	lime:[0,255,0],
	magenta:[255,0,255],
	maroon:[128,0,0],
	navy:[0,0,128],
	olive:[128,128,0],
	orange:[255,165,0],
	pink:[255,192,203],
	purple:[128,0,128],
	violet:[128,0,128],
	red:[255,0,0],
	silver:[192,192,192],
	white:[255,255,255],
	yellow:[255,255,0],
	transparent: [255,255,255]
};
})(jQuery);
//
(function($) {
  var currentRadius, multiplier;

  function parseOptions(options) {
    return {
      RADIUS:     (options.radius    || 20),
      DURATION:   (options.duration  || 500),
      TEXT_COLOR: (options.textColor || '#fff'),
      HALO_COLOR: (options.haloColor || '#777')
    }
  }

  function currentRadius(elem) {
    if (prop = elem.style['text-shadow']) {
      return parseInt(prop.match(/0 0 (\d+)px/));
    } else {
      return 0;
    }
  }

  function stepTextShadow(fx) {
    if (fx.state == 0) {
      fx.start = currentRadius(fx.elem);
    }

    updatedRadius = fx.end.begin ?
      Math.max(Math.min(parseInt(fx.end.radius * fx.pos))) :
      Math.max(Math.min(parseInt(fx.end.radius - (fx.end.radius * fx.pos))))

    if (fx.end.begin || (fx.state < 1)) {
      fx.elem.style['text-shadow'] = fx.end.color + ' 0 0 ' + updatedRadius + 'px';
    } else {
      fx.elem.style['text-shadow'] = 'none';
    }
  }

  function addGlow(opts) {
    var opts = parseOptions(opts || { });

    function startGlow() {
      $(this).animate({
        color: opts.TEXT_COLOR,
        textShadow: {
          begin: true,
          color: opts.HALO_COLOR,
          radius: opts.RADIUS
        }
      }, opts.DURATION);
    }

    function startFade() {
      $(this).animate({
        color: $(this).data('glow.originColor'),
        textShadow: {
          begin: false,
          color: opts.HALO_COLOR,
          radius: opts.RADIUS
        }
      }, opts.DURATION);
    }

    with($(this)) {
      bind('mouseenter', startGlow);
      bind('mouseleave', startFade);
      data('glow.originColor', css('color'));
    }

    return this;
  }

  $.fx.step['textShadow'] = stepTextShadow;
  $.fn.addGlow = addGlow;
})(jQuery);
//

/* End */
/* Slider (Please Include mobilyslider.js) */
$(function() {
	$('#slider').mobilyslider({
		content: '.notify_how',
		children: 'div',
		transition: 'fade',
		animationSpeed: 500,
		autoplay: false,
		autoplaySpeed: 3000,
		pauseOnHover: false,
		bullets: true,
		arrows: false,
		arrowsHide: true,
		prev: 'prev',
		next: 'next',
		animationStart: function() {},
		animationComplete: function() {}
	}).css("position", "relative");
});
/* End Slider */
/* Hint for text-box*/
$(function() {
	$('input.hint').hint();
})
/* End */

/* Button Animation */
$(function() {
	$('#header .listSubscribe ul li a .desc_ico, #header .secondNavigation ul li a').hover(function() {
		$(this).stop().animate({
			//backgroundColor: '#F1F9FF'
			//backgroundColor: 'rgba(241,249,255,1)'
			color : '#58ADDD'
		},
		"medium");
	},
	function() {
		$(this).stop().animate({
			//backgroundColor: '#FFF'
			//backgroundColor: 'rgba(241,249,255,0)'
			color: '#095D99'
		},
		"fast");
	});
	//
	$('#header .secondNavigation ul li a.user-name').hover(function() {
		$(this).stop().animate({
			backgroundColor: 'none'
		},
		"medium");	
	});
	//
	$('.panelNavTab ul li a, .panelNav ul li a').hover(function() {
		$(this).stop().animate({
			//color: '#E6FF5B'
		},
		"medium");
	},
	function() {
		$(this).stop().animate({
			//color: '#FFF'
		},
		"fast");
	});
	$('.panelNavTab ul li a, .panelNav ul li a').hover(function() {
		$(this).stop().animate({
			//color: '#E6FF5B'
		},
		'slow');
	},
	function() {
		$(this).stop().animate({
			//color: '#FFF'
		},
		"medium");
	});
	//
	
	
	$('#header .secondNavigation .account-menu2 a.button-inline, #header .secondNavigation .account-menu2 a.button-inline').hover(function() {
		$(this).stop().animate({
			backgroundColor: '#96CFF7'
		},
		'slow');
	},
	function() {
		$(this).stop().animate({
			backgroundColor: '#C4DFFF'
		},
		"fast");
	});
	//
	$('table thead th').hover(
		function(){
			$(this).stop().animate({
				backgroundColor: '#DEEDFC'	
			},'fast');	
		},
		function(){
			$(this).stop().animate({
				backgroundColor: '#D2E8FF'	
			},'fast');	
		}
	);
	//
	$('.grey_button2').hover(function(){
		$(this).stop().animate({
			//opacity : 1,
			color	: '#6DB4DB;'
		},'medium');	
	},
	function(){
		$(this).stop().animate({
			//opacity : 0.9,
			color	: '#59779c;'
		},'medium');	
	});
});
//
/*$(function(){
	$('input[type="text"]').focus(function(){
		$(this).stop().animate({
			//boxShadow:"0px 0px 3px 1px #85bcff"
			//-moz-box-shadow:0px 0px 3px 1px #85bcff;
			//-webkit-box-shadow:0px 0px 3px 1px #85bcff;	
		},'slow');
	},
	function(){
			//boxShadow:"0px 0px 0px 0px #85bcff"	
	},'medium');
});*/
//
/* End */

/* Loading Button Settings*/
$(function(){
	$("#loading.loading-btn").html(
		'<span class="message">Processing </span><img src="http://appschef.com/images/ajax-loader.gif" alt="Processing">'
	)
	$('.loading-progress').click(function(){
		$(this).hide();
		$('<div class="loading"><span class="message">Processing</span><img src="http://appschef.com/images/ajax-loader.gif" alt="Processing"/></div>').insertAfter(this);	
	});
	$('#left-sidebar ul li .submenu a').click(function(){
		$('#left-sidebar ul li .submenu a img').remove();
		$(this).append('<img src="http://appschef.com/images/ajax-loader.gif" alt="Processing"/>');
	});
	$(".panelNavTab ul li a, .panelNav ul li a, #left-sidebar h2").click(function(){
		$('#left-sidebar ul li .submenu a img').remove();	
	})
});
/* End */


/* Styling Checkbox && Radio */
(function($) {
  $.fn.ezMark = function(options) {
	options = options || {}; 
	var defaultOpt = { 
		checkboxCls   	: options.checkboxCls || 'ez-checkbox' , radioCls : options.radioCls || 'ez-radio' ,	
		checkedCls 		: options.checkedCls  || 'ez-checked'  , selectedCls : options.selectedCls || 'ez-selected' , 
		hideCls  	 	: 'ez-hide'
	};
    return this.each(function() {
    	var $this = $(this);
    	var wrapTag = $this.attr('type') == 'checkbox' ? '<div class="'+defaultOpt.checkboxCls+'">' : '<div class="'+defaultOpt.radioCls+'">';
    	// for checkbox
    	if( $this.attr('type') == 'checkbox') {
    		$this.addClass(defaultOpt.hideCls).wrap(wrapTag).change(function() {
    			if( $(this).is(':checked') ) { 
    				$(this).parent().addClass(defaultOpt.checkedCls); 
    			} 
    			else {	$(this).parent().removeClass(defaultOpt.checkedCls); 	}
    		});
    		
    		if( $this.is(':checked') ) {
				$this.parent().addClass(defaultOpt.checkedCls);    		
    		}
    	} 
    	else if( $this.attr('type') == 'radio') {

    		$this.addClass(defaultOpt.hideCls).wrap(wrapTag).change(function() {
    			// radio button may contain groups! - so check for group
   				$('input[name="'+$(this).attr('name')+'"]').each(function() {
   	    			if( $(this).is(':checked') ) { 
   	    				$(this).parent().addClass(defaultOpt.selectedCls); 
   	    			} else {
   	    				$(this).parent().removeClass(defaultOpt.selectedCls);     	    			
   	    			}
   				});
    		});
    		
    		if( $this.is(':checked') ) {
				$this.parent().addClass(defaultOpt.selectedCls);    		
    		}    		
    	}
    });
  }
})(jQuery);

// Controller 
$(function(){
	/*$('input[type="checkbox"]').ezMark();
	$('input[type="radio"]').ezMark();*/
});
/* END */

/*Checking Highlite*/
	
/*$(function(){
	$('table tbody tr td:nth-child(1) input[type="checkbox"]').click(function(event){
		if(!($(this).parents("table").is(".no-border"))){
			if($(this).is(":checked")){
				$(this).parents("tr").css("border", "2px dotted #FCD45A");
				$(this).parents("tr").stop().animate({backgroundColor:"#FFF2D3"}, 300);
			}else{
				$(this).parents('tr').css("border", "none");
				$(this).parents("tr").stop().animate({backgroundColor:"#FFF"}, 500).queue(function(){
						$(this).removeAttr("style");
				});
			}
		}
	});
	$('table thead tr th:nth-child(1) input[type="checkbox"]').click(function(event){
		var this_table = $('#'+this.id).parents("table");
		var id_table = this_table.attr("id");
			if($(this).is(":checked")){
				$("#"+id_table+" tbody tr").css("border", "2px dotted #FCD45A");
				$("#"+id_table+" tbody tr").stop().animate({backgroundColor:"#FFF2D3"}, 300);
				$('#'+id_table+" tbody tr td:nth-child(1) .ez-checkbox").addClass("ez-checked");
			}else{
				$("#"+id_table+" tbody tr").css("border", "none");
				$("#"+id_table+" tbody tr").stop().animate({backgroundColor:"#FFF"}, 500).queue(function(){
						$(this).removeAttr("style");
				});
				$('#'+id_table+" tbody tr td:nth-child(1) .ez-checkbox").removeClass("ez-checked");
			}
			
	});
});*/

/* End */





/*$(function(){
	("<div class='gn'>&nbsp;</div>").insertAfter(".notify_error");
	
	$("input[type='button'], input[type='submit']").click(function(){
		if($(".notify_error").attr("style")){
			$('.gn').show();	
		}else{
			$('.gn').hide();	
		}
	});
	$(".notify_error a").click(function(){
		$('.gn').slideUp(500);	
	});
	
});*/
/* End */

/* Spell & Check*/
$(function(){
	$("textarea").attr("spellcheck",false);	
});
/* END */



/* Table Odd Even */
/*$(function(){
	$('table tr:nth-child(even)').addClass('alt');
	$('table tr:nth-child(odd)').removeClass('alt');
	$('.panelFilter table tr').removeClass('alt').removeAttr("class");
});*/
function alt(){
	$('table tr:nth-child(even)').addClass('alt');
	$('table tr:nth-child(odd)').removeClass('alt');
}

/* END */
/* Focus On Enter*/
$(document).ready(function() {
 /*$('input:text:first').focus();
    
 $('input:text').bind("keydown", function(e) {
    var n = $("input").length;
    if (e.which == 13) 
    { 
      e.preventDefault();
      var nextIndex = $('input').index(this) + 1;
      if(nextIndex < n)
        $('input')[nextIndex].focus();
      else
      {
        $('input')[nextIndex-1].blur();
      }
    }
  });*/

/*  $('#btnSubmit').click(function() {
     alert('Form Submitted');
  });*/
});
/* END */

/* Colorbox Loading*/
$(function(){
	$('#cboxLoadingOverlay').html("<img src='http://../images/loading.gif' alt='loading' />");
});
/* END */
$(function(){
	$('.ajax-load img').attr("alt","loading");
});
/* Z-Index */

/* END */

