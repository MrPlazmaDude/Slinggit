## Module
class PostZoomer extends Backbone.View
	el: "#postDetails"

	initialize: (options)->
		_.bindAll @
		@$postImageMain = $('#post_mainImage')
		# Clone image main for use in zoomed view
		@$clonedImageMain = @$postImageMain.clone()
		# Clone the detail so that it can be removed and reappended at any time
		@clonedInnerDetail = $("#postDetailInner").clone(true)
		# clone image port with cloned main image
		@$clonedZoomPhoto = $('#post_imagePort').append(@$clonedImageMain.attr("id", "zoomedImage")).clone(true)
		# remove imagePort from the dom now that we have it cloned.  Probably could have built this
		# up instead of cloning and removing.  May consider changing up in the future. 
		$('#post_imagePort').remove()
		@zoomed = false

	events:
		"click #post_mainImage": "zoomPhoto"
		"click #post_imagePort": "hideZoomed"

	zoomPhoto: (e)->
		if not @zoomed
			$("#postDetailInner").remove()
			@$el.append(@$clonedZoomPhoto)
			#@$postImageZoomed.fadeIn(100)
			@zoomed = true

	hideZoomed: (e)->
		if @zoomed
			@$clonedZoomPhoto.remove()
			@$el.append(@clonedInnerDetail)
			@zoomed = false


## Exports
window.startPostZoomer = ()->
	new PostZoomer