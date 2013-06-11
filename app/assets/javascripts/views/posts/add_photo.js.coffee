
## Module
class Photo extends Backbone.View
  el: "#addPhotoControlGroup"

  initialize: ->
    $("#additional_photo_photo").bind("change", @showFile)

  events:
    "click #photoSelect": "trigger"

  trigger: (e)->
    if $('#additional_photo_photo').length
      $('#additional_photo_photo').trigger "click"
    e.preventDefault();

  showFile: (el)->
    file = @files[0]
    imageType = /image.*/

    if file.type.match imageType
      $('#new_additional_photo').submit();

$(document).ready ->
  @photo = new Photo