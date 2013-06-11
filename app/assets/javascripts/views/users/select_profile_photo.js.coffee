## Module
class PhotoSelector extends Backbone.View
	el: "#photoSelectorWrapper"

	initialize: (options)->
		@$selectorWrapper = $("#selectorWrapper")
		@$clonedWrapper = @$selectorWrapper.clone(true)
		@$formEl = $("#edit_user_#{@options.i}")
		@$hidden = $("#user_photo_source")
		@submit = @options.submit
		@selectable = true

	events:
		"click img": "selectPhoto"

	selectPhoto: (e)->
		@$hidden.attr("value", e.target.id)
		@$el.find('img').removeClass("selected")
		$(e.target).addClass("selected")
		@$formEl.submit() if @submit

class PhotoEditor extends PhotoSelector

	events:
		"click img": "selectPhoto"
		"click a.col6": "returnPhotos"
	
	selectPhoto: (e)->
		if @selectable
			@$hidden.attr("value", e.target.id)
			@$el.fadeOut 100, ()=>
				@$el.empty().append(template(e.target.src, e.target.id)).fadeIn()
				@selectable = false

	returnPhotos: (e)->
		e.preventDefault()
		@$el.fadeOut 100, ()=>
			@$el.empty().append(@$clonedWrapper).fadeIn()
			@selectable = true


template = (img_url, img_id)->

	"""
		<div class="row">
			<div class="col6">
				<p>Save your profile to use this photo</p>
			</div>
		</div>
		<div class="row">
			<div class="col2 pull_left">
				<div class="row">
					<img src="#{img_url}" id="#{img_id}" class="selectedPhoto"/>
				</div>
			</div>
			<div class="col2 pull_left">
				<a class="col6 change" href="#">Change</a>
			</div>
		</div>
	"""



## Exports
window.initPhotoSelector = (i, s)->
	return new PhotoSelector i:i, submit:s

window.initPhotoEditor = (i, s)->
	return new PhotoEditor i:i, submit:s