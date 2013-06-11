## Module
class Photo extends Backbone.View
	el: "#photoControlGroup"

	initialize: ->
		$("#post_photo").bind("change", @showFile)
		@changePhotoEl = "<a href='#' id='changeFileSelect'>Change photo</a>"

	events:
		"click #fileSelect": "trigger"
		"click #changePhoto": "changePhoto"

	trigger: (e)->
		unsupported = ['iPad', 'iPhone', 'iPod']
		if navigator.platform in unsupported and _.isUndefined window.FileReader
			alert "Uploading a photo through the browser is not yet supported on your device or browser."
		else if $('#post_photo').length
			$('#post_photo').trigger "click"
		e.preventDefault();	

	changePhoto: (e)->
		e.preventDefault()
		$("#placeholderWrapper").find("form").submit()

	showFile: (el)->

		file = @files[0]
		imageType = /image.*/

		if file.type.match imageType
			img = document.createElement("img")
			img.classList.add "obj"
			img.classList.add "img_border"
			img.file = file
			$('#fileSelect').text("Change photo").addClass("col3")
			$controls = $('#photoControlGroup').find('.controls')
			imageToRemove = $controls.find('.obj')
			imageToRemove.remove()
			$controls.remove('.obj').append(img)
			reader = new FileReader()
			reader.onload = ((aImg)->
				(e)-> aImg.src = e.target.result)(img)
			reader.readAsDataURL(file)	


			##  So this is just a quick fix to make it easy for users to upload
			##  a photo for a post that has a placeholder post.  We can completely
			##  redo this once we figure out what we want to do with multiple photos
			if $("#placeholderWrapper").length > 0
				$("#placeholderImg").remove() 
				$('#fileSelect').after("<a href='#' class='col3' id='changePhoto'>Use Photo</a>")

$(document).ready ->
	@photo = new Photo