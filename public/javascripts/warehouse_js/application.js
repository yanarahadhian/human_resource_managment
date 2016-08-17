function AddMoreRows() {

    var $main_div  = $('#product_form');
    var table = $('<table>');
    var tr_lot = $('<tr>');
    var tr_grade = $('<tr>');
    var tr_div = $('<tr>');
    var tr_link = $('<tr>');

    var td_lot_title  = $('<td>');
    var td_grade_title = $('<td>');
    var td_lot_field = $('<td>');
    var td_grade_field = $('<td>');
    var td_div_title = $('<td>');
    var td_div_field = $('<td>');
    var td_link_title = $('<td>');
    var td_link_field = $('<td>');

    var input_lot = $('<input type="text">');
    var grade = $('<select>');
    var grade1= $('<option>');
    var grade2= $('<option>');
    var grade3= $('<option>');
    var grade4= $('<option>');
    var grade5= $('<option>');
    var grade6= $('<option>');
    var link = $('<a>');
    var num = $("#product_form > table").size();

    grade1.append('A');
    grade2.append('A1');
    grade3.append('AL');
    grade4.append('AA');
    grade5.append('AM');
    grade6.append('B');
    grade.append(grade1).append(grade2).append(grade3).append(grade4).append(grade5).append(grade6);

    table.attr('id', 'new_grade'+num);
    table.attr('class', 'editor');
    input_lot.attr('class', 'inputtext')
    link.attr('href', '#new_grade'+num);
    link.attr('onclick', "$('#new_grade"+num+"').remove();$('#retur_save').removeAttr('disabled');");
    link.attr('id', 'remove_link'+num);
    link.html(' Hapus');

    td_lot_title.attr('class', 'label');
    td_lot_title.html('<label class="row_description">Lot:</label>');
    td_lot_field.append(input_lot);
    tr_lot.append(td_lot_title).append(td_lot_field);

    td_grade_title.attr('class', 'label');
	td_grade_title.html('<label class="row_description">Grade :</label>');
    td_grade_field.append(grade);
    tr_grade.append(td_grade_title).append(td_grade_field);

    td_link_field.append(link);
    tr_link.append(td_link_title).append(td_link_field);

    td_div_field.html('<div class="divider" style=""> dd</div>');
    tr_div.append(td_div_title).append(td_div_field);

    table.append(tr_lot).append(tr_grade).append(tr_link).append(tr_div);
    $main_div.append(table);
}

function AddMoreProducts(id, title, type, num_added) {


    var num = $("#product_form > table").size() + 4 + num_added;

    //for( num=num_awal; num < (num_awal + 5); num++){
    var $form = $('#product_form');
    var table = $('<table class="formtable" style="width: 900px;margin-left: 15px" >');

    var tr_all = $('<tr>');
    var tr_link = $('<tr>');

    var td_num_field = $('<td>');
    var td_unit_field = $('<td>');
    var td_weight_field = $('<td>');
    var td_link_field = $('<td>');
    var td_div_field = $('<td>');

    var tr_hr = $('<tr>');
    var td_hr = $('<td>');
    var input_hr = $('<hr>');
    input_hr.attr('style', "width:875px")
    td_hr.attr('colspan',"7");
    td_hr.append(input_hr);
    tr_hr.append(td_hr);

    td_num_field.attr('style', "width:347px");
    td_unit_field.attr('style', 'width:119px')
    td_weight_field.attr('style', 'width:204px')
    /*before 94-96
    td_name_field.attr('style', "width:225px");
    td_num_field.attr('style', "width:225px");
    td_prod_link.attr('style', 'width:117px');
    td_unit_field.attr('style', 'width:100px')
    td_weight_field.attr('style', 'width:95px')
    */
    var link = $('<a>');
    var input_name = $('<input type="text" id="product_name_'+ num +'">');
    var input_num = $('<input type="text">');
    var input_unit = $('<input type="text">');
    var input_weight = $('<input type="text">');
    var prod_detail = $('<div id="product_detail_'+num+'">');
    if(type =='memo') {
        var prod_id = $('<input type="hidden" id="rgm_details_'+num+'_product_id" name="rgm_details['+ num +'][product_id]">');
    }else{
        var prod_id = $('<input type="hidden" id="product_id_'+num+'" name="product_id['+ num +']">');
        var input_lost_hidden = $('<input type="hidden" id="grn_details_'+num+'_lost_box_code" name="grn_details['+num+'][lost_box_code]" value="0">');
        var input_lost_code = $('<input type="checkbox" id="grn_details_'+num+'_lost_box_code" name="grn_details['+num+'][lost_box_code]" value="1">');
    }

    var name = $('<input type="hidden" id="name_'+num+'" name="name['+ num +']">')
    var new_prod_link = $('<a rel="facebox_'+num+'" id="new_product_link_'+num+'" href="/products/new?from=lpb&id='+id+'">');
    var edit_prod_link = $("<a style='' onclick='$(\"#new_product_link_"+num+"\").show();$(\"#edit_product_link_"+num+"\").hide();$(\"#product_detail_"+num+"\").hide();$(\"#product_name_"+num+"\").removeAttr(\"disabled\");$(\"#product_name_"+num+"\").attr(\"value\", \"\"); return false' id=\"edit_product_link_"+num+"\" href=''>")

    //title = title.split(',');

    table.attr('id', 'new_product'+num);
    table.attr('class', 'editor');
    link.attr('href', '#new_product'+num);
    if(type =='memo'){
        link.attr('onclick', "$('#new_product"+num+"').remove();$('#retur_save').removeAttr('disabled'); return false;");
    }else{
        link.attr('onclick', "$('#new_product"+num+"').remove(); return false;");
    }
    link.attr('id', 'remove_link'+num);
    link.html(' Hapus');

    input_name.attr('class', 'inputtext');
    input_name.attr('name', 'product_name['+ num +']');

    new_prod_link.html(' Input Produk');
    edit_prod_link.attr('style', "display:none");
    var br = $('<br/>')
    edit_prod_link.html(' Ganti Produk');


    if(type =='memo') {
        input_name.attr('style', "width:200px");
        input_name.attr('onchange', "validateReturProduct("+num+");");
        input_num.attr('id', 'rgm_details_'+num+'_unit_count');
        input_num.attr('class', 'inputtext');
        input_num.attr('name', 'rgm_details['+ num +'][unit_count]');
        input_num.attr('style', "width:50px");

        input_unit.attr('class', 'inputtext');
        input_unit.attr('name', 'rgm_details['+ num +'][net_weight]');
        input_unit.attr('id', 'rgm_details_'+num+'_net_weight');
        input_unit.attr('style', "width:50px");

        input_weight.attr('class', 'inputtext');
        input_weight.attr('name', 'rgm_details['+ num +'][reason_for_returning]');
        input_weight.attr('id', 'rgm_details_'+num+'_reason_for_returning');
        input_weight.attr('style', "width:300px");
        var td_no_prod = $('<td id="no_product_'+num+'" style="display:none">Tidak ada produk yang sesuai. <a onclick="changeReturProduct('+num+')" href="#product_name_'+num+'">Ganti Produk</a></td>');
        var tr_box  = $('<tr>');
        var td_box_title  = $('<td>');
        var td_box_field  = $('<td>');
        var input_box = $('<input type="text">');
        input_box.attr('class', 'inputtext');
        input_box.attr('name', 'rgm_details['+ num +'][box_count]');
        input_box.attr('id', 'rgm_details_'+num+'_box_count');
        input_box.attr('style', "width:50px");
    }
    else {
        input_name.attr('style', "width:200px");
        input_num.attr('class', 'inputtextbox');
        input_num.attr('onkeypress', 'return event.keyCode != 13 || ($("s").click(),false)');
        input_num.attr('onblur', 'this.value = this.value.toUpperCase();');
        input_num.attr('name', 'grn_details['+ num +'][box_code]');
        input_num.attr('style', "width:200px");

        input_unit.attr('class', 'inputtext');
        input_unit.attr('name', 'grn_details['+ num +'][unit_count]');
        input_unit.attr('style', "width:50px");

        input_weight.attr('class', 'inputtext');
        input_weight.attr('name', 'grn_details['+ num +'][net_weight]');
        input_weight.attr('style', "width:50px");
        var td_no_prod = $('<td id="no_product_'+num+'" style="display:none;width:170px;">Tidak ada produk yang sesuai. Saya mau <a id="new_product_link_'+num+'" rel="facebox" href="/products/new?from=lpb&id='+id+'">input baru</a>. <a onclick="$(\'#product_'+num+'\').show();$(\'#no_product_'+num+'\').hide(); return false" href="">Cancel</a></td>');

        var loading = $('<div id="loading_'+num+'" style="display: none;"><img class="img_load" src="/images/ajax-loader.gif" alt="Ajax-loader"/>Loading ...</div>');
    }

/*<<<<<<< .mine

=======*/
    if(type =='memo') {
        td_name_field.append(input_name).append(prod_detail).append(prod_id).append(name);
    }else{
        td_name_field.append(input_name).append(loading).append(prod_detail).append(prod_id).append(name);
    }

/*
    if(type =='memo'){
        td_num_field.append(input_num);
    }else{
        td_num_field.append(input_num);
    }
*/
    td_unit_field.append(input_unit);

    td_weight_field.append(input_weight);

    td_link_field.append(link);

    td_div_field.html('<div class="divider" style=""></div>');

    td_prod_link.append(new_prod_link).append(br).append(edit_prod_link)


    tr_all.append(td_name_field).append(td_no_prod).append(td_prod_link).append(td_num_field).append(td_unit_field).append(td_weight_field).append(td_div_field).append(input_lost_hidden).append(input_lost_code);
    tr_link.append(td_link_field);
    table.append(tr_all).append(tr_hr).append(tr_link);


    $form.append(table);
    table.slideDown("slow");

    var url = ''
    if(type =='memo') {
        url = '/returned_memos/show_product_detail?id='
        autocomplete_url = "/inventories/product_show.json?with=product_detail&from=retur"
    }else{
        url = '/product_receipts/show_product_detail?id='
        autocomplete_url = "/inventories/product_show.json"
    }

    $('a[rel*=facebox_'+num+']').facebox();
    jQuery('#product_name_'+ num).autocomplete(autocomplete_url).result(function(event, row, formatted){
        if (type == 'memo'){
            if (row[1] != '0')
			  {$('#rgm_details_'+num+'_product_id').val(row[1]);
                $('#name_'+ num).val(row[0]);
                $('#product_name_'+ num).attr('disabled', 'true');
                $("#new_product_link_"+ num).hide();
                $("#edit_product_link_"+ num).show();
			  $("#product_detail_"+ num).show();}
            else{
                $("#product_name_"+ num).val('');
                $("#product_"+ num).hide();
				  $("#no_product_"+ num).show();}
        }else{
            if (row[1] != '0')
				  {$('#loading_'+ num).show();
                $('#product_detail_'+ num).load(url+row[1]+'&num='+num, null, function() {
				    $('#loading_'+ num).hide();});
                $('#product_id_'+ num).val(row[1]);
                $('#name_'+ num).val(row[0]);
                $('#product_name_'+ num).attr('disabled', 'true');
                $("#new_product_link_"+ num).hide();
                $("#edit_product_link_"+ num).show();
			  $("#product_detail_"+ num).show();}
            else{
                $("#product_name_"+ num).val('');
                $("#product_"+ num).hide();
                $("#no_product_"+ num).show();
            }
        }
    });
//}
}

function AddMoreBpb(i) {
    // alert(i);
    var $table = $('#products_table');
    var tr  = $('<tr>');
    var j
    if (i == undefined){
        j = $("#products_table > tbody > tr").size() - 1
    }else{
        j = $("#products_table > tbody > tr").size() - 1 //i
    }
    var num = j;

    var td_name  = $('<td id="product_'+ num +'">');
    var td_weight = $('<td>');
    var td_link = $('<td>');
    var link = $('<a>');

    var input_name = $('<input type="text" id="product_name_'+ num +'"/>');
    var input_weight = $('<input type="text">');
    var prod_detail_id = $('<input type="hidden" id="product_detail_id_'+num+'" name="product_detail_id['+ num +']">');
    var name = $('<input type="hidden" id="name_'+num+'" name="name['+ num +']">');
    var edit_prod_link = $("<a style='' onclick='$(\"#new_product_link_"+num+"\").show();$(\"#edit_product_link_"+num+"\").hide();$(\"#product_detail_"+num+"\").hide();$(\"#product_name_"+num+"\").removeAttr(\"disabled\");$(\"#product_name_"+num+"\").attr(\"value\", \"\"); return false' id=\"edit_product_link_"+num+"\" href=''>");
    var td_no_prod = $('<td id="no_product_'+num+'" style="display:none">Tidak ada produk yang sesuai. <a onclick="changeBpbProduct('+num+')" href="#">Ganti Produk</a></td>');

    input_weight.attr('name', 'ior_details['+ num +'][requested_weight]');
    input_name.attr('name', 'product_name['+ num +']');
    input_name.attr('onchange', "validateBpbProduct("+num+");");
    edit_prod_link.attr('style', "display:none");
    edit_prod_link.html(' Ganti');

    tr.attr('id', 'new_product'+num);
    link.attr('href', '#new_product'+num);
    link.attr('onclick', "$('#new_product"+num+"').remove(); $('#ior_save').removeAttr('disabled');");
    link.attr('id', 'remove_link'+num);
    link.html(' Hapus');
    td_link.attr('class', 'last');
    input_name.attr('class', 'inputtext');
    input_weight.attr('class', 'inputtext');
    input_name.attr('style', "width:330px");
    input_weight.attr('style', "width:50px");

    td_name.append(name).append(edit_prod_link).append(prod_detail_id).append(input_name);
    td_weight.append(input_weight);
    td_link.append(link);
    tr.append(td_no_prod).append(td_name).append(td_weight).append(td_link);

    $table.append(tr);

    jQuery('#product_name_'+ num).autocomplete("/inventories/product_show.json?with=product_detail&from=bpb").result(function(event, row, formatted){
        if (row != '')
		{$('#product_detail_id_'+ num).val(row[1]);
            $('#name_'+ num).val(row[0]);
            $('#product_name_'+ num).attr('disabled', 'true');
            $("#edit_product_link_"+ num).show();
		$("#product_detail_"+ num).show();}
        else
		{$("#product_name_"+ num).val('');
            $("#product_"+ num).hide();
		$("#no_product_"+ num).show();}
    });
}

function AddMoreGiven(i, product_id, grade, lot){
    var $td = $('#given_saldo_'+ i);
    var br = $('<br/>')
    var num = $("#given_saldo_"+ i +" > div").size()
    var div  = $('<div style="padding: 5px 10px;" id="saldo_'+ i +'_'+num+'">');
    var span_given = $("<span id='mutation_saldo_"+i+"_"+num+"'>")
    var input_code = $('<input type="text" class="inputtext" style="width: 50px; float: left;" name="ior_details['+ i +']['+ num +'][box_code]" id="ior_details_'+ i +'_'+ num +'_box_code">');
    var link = $('<a>');
    var link_cek = $('<a id="link_cek_saldo_'+ i +'_'+ num +'" style="padding-left: 10px;" onclick="$(\'#link_cek_saldo_'+ i +'_'+ num +'\').hide(); showGivenSaldo(document.getElementById(\'ior_details_'+ i +'_'+ num +'_box_code\').value, '+ i +', '+ num +', '+ product_id +', \''+ grade +'\', \''+ lot +'\')" href="#given_table">Cek Saldo Box</a>')
    var loading = $('<div style="display: none;" id="loading_'+ i +'_'+ num +'"> <img style="padding-left: 10px;" src="/images/ajax-loader.gif" class="img_load" alt="Ajax-loader">Loading ...</div>')
    link.attr('href', '#saldo_'+ i +'_'+num);
    link.attr('onclick', "$('#saldo_"+i+"_"+num+"').remove()");
    link.attr('id', 'remove_link_'+ i +'_'+num);
    link.attr('style', 'float:right');
    link.html(' Hapus');
    // if (num == 1){
    div.append(input_code).append(loading).append(span_given).append(link_cek).append(link);
    // }else{
    // 		div.append(br).append(input_code).append(span_given).append(link_cek).append(link);
    // 	}
    $td.append(div);
}

function showGivenSaldo(value, i, num, product_id, grade, lot){
    var lot = lot.replace(" ", "%20")
    $('#loading_'+ i +'_'+ num).show();
    $('#mutation_saldo_'+ i +'_'+ num).load('/product_requests/show_given?box_code='+value+'&i='+i+'&num='+num+'&product_id='+product_id+'&grade='+grade+'&lot='+lot, 	     function() {
        $('#loading_'+ i +'_'+ num).hide();
    });
}

function CreateRetur(id) {
    // html = "<a href='/passes/regenerate/'"+id+">Regenerate</a> | <a href ='/passes/sj_print' target='_blank'>Print</a> "
    // 	$('#sj_link'+id).html(html);
    $('#sj_link'+id).hide();
    $('#sj_form'+id).attr('style', 'display:block;');
// $.get('/passes/create_delivery_order', {id: id}, function(data) { eval(data);});
}

function EditReturStatus(id, status, number) {
    html = '<select id="status_'+id+'">'
    if(status == 'Pending'){
        html = html + '<option value="Yes To Return">Yes To Return</option><option value="No To Return">No To Return</option></select>'
    }else if (status == 'No To Return'){
        html = html + '<option value="Yes To Return">Yes To Return</option><option value="No To Return">No To Return</option></select>'
    }else{
        html = html + '<option value="Yes To Return">Yes To Return</option><option value="Returned">Returned</option></select>'
    }
    html = html + ' <a href ="#" onclick="SaveReturStatus(document.getElementById(\'status_'+id+'\').value,'+id+', \''+number+'\')"><img src="/images/icons/tick.png" alt="Rubah Status"/> </a> <a href ="#" onclick="cancelReturStatus(\''+status+'\','+id+', \''+number+'\')"><img src="/images/icons/cross.png" alt="Cancel Status"/> </a>'

    // ' <a href ="/returned_memos/save_status?id='+id+'&status='+status+'"><img src="/images/icons/tick.png" alt="Rubah Status"/> </a> <a href ="#" onclick="cancelReturStatus(document.getElementById(\'status_'+id+'\').value,'+id+', \''+number+'\')"><img src="/images/icons/cross.png" alt="Cancel Status"/> </a>'

    $('#retur_status'+id).html(html);
}

function SaveReturStatus(value, id, number){
    if(value =='Returned'){
        html = '<div class="tooltip_inv">Returned<div class="fb_menu_dropdown clearfix" style="width:200px;"><div class="fb_menu_item"><table><tbody><tr><td><b>Surat Jalan</b></td><td><b>SKB</b></td></tr><tr><td id="sj_link'+id+'"><a onclick="CreateRetur('+id+')" href="#">Create</a></td><td><a target="_blank" href="/passes/skb_print">Print</a></td></tr></tbody></table></div></div></div>'
    }else{
        html = value + ' | <a href ="#" onclick="EditReturStatus('+id+',\''+value+'\')">Take Action </a>'
    }
    // $('#retur_status'+id).html(value);
    // $('#retur_number'+id).html(number);
    //
    window.location='/returned_memos/save_status?id='+id+'&status='+value;
// $('#retur_status'+id).html(html);
// $.get('/returned_memos/save_status', {id: id, status: value}, function(data) { eval(data);});
}

function cancelReturStatus(value, id, number){
    html = value + ' | <a href ="#" onclick="EditReturStatus('+id+',\''+value+'\')">Take Action </a>'
    $('#retur_status'+id).html(html);
}

function EditBpbStatus(id, status, number) {
    html = '<select  id="status_'+id+'">'
    if(status == 'pending'){
        html = html + '<option value=""></option><option value="Pending">Pending</option><option value="Shipped">Shipped</option></select>'
    }else{
        html = html + '<option value="Received">Received</option></select>'
    }
    html = html + ' <a href ="#" onclick="SaveBpbStatus(document.getElementById(\'status_'+id+'\').value,'+id+', \''+number+'\')"><img src="/images/icons/tick.png" alt="Rubah Status"/> </a> <a href ="#" onclick="cancelBpbStatus(\''+status+'\','+id+', \''+number+'\')"><img src="/images/icons/cross.png" alt="Cancel Status"/> </a>'
    $('#bpb_status'+id).html(html);
}

function SaveBpbStatus(value, id, number){
    if(value !='Received'){
        html = value + ' | <a href ="#" onclick="EditBpbStatus('+id+', \''+value+'\', \''+number+'\')">Take Action</a>'
        if(value =='Shipped'){
            window.location='/product_requests/'+id+'/edit';
        // $('#bpb_status'+id).html(html);
        }else{
            window.location='/product_requests/save_status?id='+id+'&status='+value;
            $('#bpb_status'+id).html(html);
        }
    }else{
        html = value
        if(value =='Shipped'){
            window.location='/product_requests/'+id+'/edit';
        // $('#bpb_status'+id).html(html);
        }else{
            window.location='/product_requests/save_status?id='+id+'&status='+value;
            $('#bpb_status'+id).html(html);
        }
    }

// $('#bpb_number'+id).html(number);
// $.get('/product_requests/save_status', {id: id, status: value}, function(data) { eval(data);});
}

function cancelBpbStatus(value, id, number){
    html = value + ' | <a href ="#" onclick="EditBpbStatus('+id+',\''+value+'\')">Take Action </a>'
    $('#bpb_status'+id).html(html);
}

function FillInventoryForm(id, detail){
    var product_id = $("#product_id").val()
    if (id == 'custom'){
        if (detail == 'detail1'){
            $('#grade_opt').load('/inventories/show_product_detail?id='+product_id+'&detail_value='+id+'&detail='+detail);
        }
        else{
            $('#lot_opt').load('/inventories/show_product_detail?id='+product_id+'&detail_value='+id+'&detail='+detail);
        }

    }else if (id != 'custom' && detail == 'detail1'){
        $('#lot_opt').load('/inventories/show_lot?id='+id);
    }
}

function LpbFillInventoryForm(obj, detail, num){
    var $obj = $(obj);
    var $container = $obj.closest('.form-nama-produk');
    var num = $container.siblings('#index').val();
    var product_id = $('.product_id', $container).val();
    console.log($container)
    if ($obj.val() == 'custom'){
        if (detail == 'detail1'){
            $('.grade_opt', $container).load('/product_receipts/show_product_detail?id='+product_id+'&detail_value='+$obj.val()+'&detail='+detail+'&num='+num);
            $('.lot_opt', $container).load('/product_receipts/show_lot?product_id='+product_id+'&num='+num);
        }
        else{
            $('.lot_opt', $container).load('/product_receipts/show_product_detail?id='+product_id+'&detail_value='+$obj.val()+'&detail='+detail+'&num='+num);
        }

    }else if ($obj.val() != 'custom' && detail == 'detail1'){
        $('.lot_opt', $container).load('/product_receipts/show_lot?id='+$obj.val()+'&num='+num);
    }
}

function ReturFillInventoryForm(id, detail, num){
    var product_id = $("#product_id_"+num).val()
    if (id == 'custom'){
        if (detail == 'detail1'){
            $('#grade_opt_'+num).load('/returned_memos/show_product_detail?id='+product_id+'&detail_value='+id+'&detail='+detail+'&num='+num);
            $('#lot_opt_'+num).load('/returned_memos/show_lot?product_id='+product_id+'&num='+num);
        }
        else{
            $('#lot_opt_'+num).load('/returned_memos/show_product_detail?id='+product_id+'&detail_value='+id+'&detail='+detail+'&num='+num);
        }

    }else if (id != 'custom' && detail == 'detail1'){
        $('#lot_opt_'+num).load('/returned_memos/show_lot?id='+id+'&num='+num);
    }
}

function showNewBrand(id){
    if (id == 'custom' || id == 'cancel'){
        $('#new_brand').load('/products/show_brand_form?id='+id);
    }
}


function isApproved() {
    if(!$('#spv_chd').is(":checked")){
        alert("Silahkan klik check box persetujuan terlebih dahulu.");
        return false;
    }

    return true;
}

function isApproved1() {
    if(!$('#spv_chd1').is(":checked")){
        alert("Silahkan klik check box persetujuan terlebih dahulu.");
        return false;
    }

    return true;
}

function iorApproved() {
    if(!$('#internal_order_request_approval').is(":checked")){
        alert("Silahkan klik check box persetujuan terlebih dahulu.");
        return false;
    }

    return true;
}

function updateLot(s, page){
	var product_id = $("#product_id").val()
    if (s.value == 'custom'){
		$('#lot_opt').load('/inventories/show_product_detail?id='+product_id+'&detail_value='+s.value+'&detail=detail2');
    }else{
        if (page == 'prep'){
            $("#product_mutation_product_detail_id").attr("value", s.value);
            $("#product_mutation_lot").attr("value", s.options[s.selectedIndex].innerHTML);
        }else{
            $("#product_mutation_lot").attr("value", s.options[s.selectedIndex].innerHTML);
        }
        return false
    }
}

function lpbUpdateLot(s, num, page){
    var $obj = $(s);
    var $container = $obj.closest('.form-nama-produk');
    var num = $container.siblings('#index').val();
    var product_id = $('.product_id', $container).val();
    console.log($container);
    if (s.value == 'custom'){
        $('.lot_opt', $container).load('/product_receipts/show_product_detail?id='+product_id+'&detail_value='+s.value+'&detail=detail2&num='+num);
    }else{
        if (page == 'prep'){
            $('#grn_details_'+num+'_product_detail_id').attr("value", s.value);
            $('#grn_details_'+num+'_lot').attr("value", s.options[s.selectedIndex].innerHTML);
        }else{
            $('#grn_details_'+num+'_lot').attr("value", s.options[s.selectedIndex].innerHTML);
        }
        return false
    }
}

function returUpdateLot(s, num, page){
    var product_id = $("#product_id_"+num).val()
    if (s.value == 'custom'){
        $('#lot_opt_'+num).load('/returned_memos/show_product_detail?id='+product_id+'&detail_value='+s.value+'&detail=detail2&num='+num);
    }else{
        if (page == 'prep'){
            $('#rgm_details_'+num+'_product_detail_id').attr("value", s.value);
            $('#rgm_details_'+num+'_lot').attr("value", s.options[s.selectedIndex].innerHTML);
        }else{
            $('#rgm_details_'+num+'_lot').attr("value", s.options[s.selectedIndex].innerHTML);
        }
        return false
    }
}

function showDesc(val){
    if (val == 'Verified Not OK'){
        $('#verification_description').show();
    }else{
        $('#verification_description').hide();
    }
    return false
}

function showDivision(id){
    if (id == 4 || id == 5){
        $("#division_row").show();
    }else{
        $("#division_row").hide();
    }
    return false
}

function showDivisionMutation(id){
    if (id == 'BPB' || id == 'LPB'){
        $("#division_row").show();
    }else{
        $("#division_row").hide();
    }
    return false
}

function disableEnterKey(e)
{
    var key;

    if(window.event)
        key = window.event.keyCode;     //IE
    else
        key = e.which;     //firefox

    if(key == 13)
        return false;
    else
        return true;
}

function validateReturProduct(i){
    if($('.ac_results:visible').get(0)){
        setTimeout(function(){
            validateReturProduct(i);
        },500);
        return false
    }
    if (document.getElementById("name_"+i).value == ''){
        $("#product_name_"+i).val('');
        $("#product_"+i).hide();
        $("#no_product_"+i).show();
        $('#rgm_details_'+i+'_box_count').attr('disabled', 'true');
        $('#rgm_details_'+i+'_unit_count').attr('disabled', 'true');
        $('#rgm_details_'+i+'_net_weight').attr('disabled', 'true');
        $('#rgm_details_'+i+'_reason_for_returning').attr('disabled', 'true');
        $('#retur_save').attr('disabled', 'true');
    }
    return false
}

function changeReturProduct(i){
	$("#product_"+i).show();$("#no_product_"+i).hide();
    $('#rgm_details_'+i+'_box_count').removeAttr("disabled");
    $('#rgm_details_'+i+'_unit_count').removeAttr("disabled");
    $('#rgm_details_'+i+'_net_weight').removeAttr("disabled");
    $('#rgm_details_'+i+'_reason_for_returning').removeAttr("disabled");
    $('#retur_save').removeAttr("disabled");
    return false
}

function validateBpbProduct(i){
    if($('.ac_results:visible').get(0)){
        setTimeout(function(){
            validateBpbProduct(i);
        },500);
        return false
    }
    if (document.getElementById("name_"+i).value == ''){
        $("#product_name_"+i).val('');
        $("#product_"+i).hide();
        $("#no_product_"+i).show();
        $('#ior_details_'+i+'_requested_weight').attr('disabled', 'true');
        $('#ior_save').attr('disabled', 'true');
    }
    return false
}
function changeBpbProduct(i){
	$("#product_"+i).show();$("#no_product_"+i).hide();
    $('#ior_details_'+i+'_requested_weight').removeAttr("disabled");
    $('#ior_save').removeAttr("disabled");
    return false
}

function showPasswordField(){
    if($('#spv_chd').is(":checked")){
        $("#password_field").show();
    }else{
        $("#password_field").hide();
    }
    return false;
};

function showPasswordField1(){
    if($('#spv_chd1').is(":checked")){
        $("#password_field1").show();
    }else{
        $("#password_field1").hide();
    }
    return false;
};

function validateForm(){
    var  error = ""

    if ($('#product_brand_id').val() == ''){
        $('#error_brand').show();
        error = 'yes'
    }	else{
        $('#error_brand').hide();
    }

    if ($('#new_product_name').val() == ''){
        $('#error_name').show();
        error = 'yes'
    }else{
        $('#error_name').hide();
    }

    if ($('#brand_name').val() == ''){
        $('#error_new_brand').show();
        error = 'yes'
    }else{
        $('#error_new_brand').hide();

    }

    if (error == 'yes'){
        return false;
    }else{
        return true;
    }
};
