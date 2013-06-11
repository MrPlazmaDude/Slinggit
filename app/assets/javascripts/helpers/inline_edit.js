
$(document).ready(function () {

    $('[class~=editable_remote]').click(function (e) {
        editEvent(e.target.getAttribute('edit_target'))
    });

    $('[class~=editable]').dblclick(function (e) {
        editEvent(e.target.id)
    });
})

function editEvent(target_id) {

    target_object = $('#' + target_id);
    swapVal = target_object.text();
    edit_field = target_object.attr('edit_field');

    if (edit_field == 'price') {
        swapVal = swapVal.replace('$', '');
        maxlength = 6;
    } else if (edit_field == 'location') {
        maxlength = 16;
    } else if (edit_field == 'hashtag_prefix') {
        maxlength = 15;
    } else if (edit_field == 'content'){
       maxlength = 300;
    }

    target_object.html('<input maxlength="' + maxlength.toString() + '" type="text" style="font-size: 0.9em" id="' + edit_field + '_edit_active" value="' + swapVal + '"/>');
    active_textbox = $('#' + edit_field + '_edit_active');
    active_textbox.focus();
    active_textbox.keypress(
            function (key_enter) {
                if ((key_enter.keyCode || key_enter.which) == 13) {
                    closeTextbox(active_textbox, swapVal, edit_field, target_object);
                } else if ((key_enter.keyCode || key_enter.which) == 27) {
                    if(edit_field == 'price'){
                        target_object.html('$' + swapVal);
                    }else{
                        target_object.html(swapVal);
                    }
                }
            }).blur(function () {
                closeTextbox(active_textbox, swapVal, edit_field, target_object);
            })
}

function closeTextbox(active_textbox, swapVal, edit_field, target_object) {
    if (active_textbox.val() != swapVal && validateEditField(edit_field, active_textbox.val())) {
        $.ajax({
            url:'<%= url_for :controller => :posts, :action => :edit_field, :id => @post.id_hash %>',
            type:"POST",
            data:'field=' + edit_field + '&value=' + active_textbox.val(),
            complete:function (requestObj, textStatus) {
                target_object.html(requestObj.responseText);
            }
        });
    } else {
        if (edit_field == 'price') {
            target_object.html('$' + swapVal.toString());
        } else {
            target_object.html(swapVal.toString());
        }
    }

}

function validateEditField(edit_field, value) {
    value.replace(/\s+/g, ' ');
    if (value.length == 0) {
        return false;
    }

    if (edit_field == 'location') {
        if (value.length <= 16) {
            return true;
        }
    } else if (edit_field == 'price') {
        if (value.length <= 6 && parseInt(value, 10) > 0) {
            return true;
        }
    } else if (edit_field == 'hashtag_prefix') {
        if (value.length <= 15) {
            return true;
        }
    } else if (edit_field == 'content'){
       if (value.length <= 300){
return true;
}
    }
    return false;
}