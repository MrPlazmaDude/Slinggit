## Counter module
window.displayCounter = (field_name, max) ->
  field_object = $("#" + field_name)
  counter_object = $("#counter_" + field_name)
  if counter_object.length is 0
    field_object.parent().prepend "<div id=\"counter_" + field_name + "\" class=\"counter\">" + field_object.val().length + "/" + max.toString() + "</div>"
    counter_object = $("#counter_" + field_name)
  else
    counter_object.show()
  field_object.blur(->
    counter_object.hide()
  ).keyup ->
    if parseInt(field_object.val().length) < max
      counter_object.html field_object.val().length + "/" + max
    else
      counter_object.html max + "/" + max
      field_object.val field_object.val().substring(0, 300)
$("input, textarea").focus (field_object) ->
  displayCounter field_object.target.id, field_object.target.getAttribute("counterMax")  if field_object.target.getAttribute("counterMax")?


## Bind focus event to fields with counter max attributes
$(document).ready ->
  $("input, textarea").focus (field_object) ->
    displayCounter field_object.target.id, field_object.target.getAttribute("counterMax")  if field_object.target.getAttribute("counterMax")?