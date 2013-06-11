#module
class AdminPhotoView extends Backbone.View
  tagName: "article"
  className: "postedPhoto"

  initialize: (options)->
  	_.bindAll @
  	@$photoContent = @options.photoContent
  	@imagePath = @options.imagePath
  	@postId = @options.postId
  	@eradicateUrl = @options.eradicateUrl

  events:
  	"click span": "deletePhoto"

  deletePhoto: (e)->
  	#console.log @postId
  	self = @
  	if confirm "Are you sure?"
  		$.ajax(
  			type: "POST"
  			url: @eradicateUrl
  			data: {post_id: self.postId}
  		).done (response)->
  			#console.log response
  			unless response.toLowerCase().indexOf("error") is -1
  				$("#errorDiv").html response
  			else
  				self.$el.remove()


  render: ->
  	template = @getTemplate()
  	@$el.append template
  	@$photoContent.append @el

  getTemplate: ->
  	template = "<img src='#{@imagePath}'></img><span id='#{@postId}'>Delete</span>"

#exports @=window at this tab level
@createPhotoArticle = (photoWrapper, imagePath, postId, eradicateUrl)->
  return new AdminPhotoView
  	photoContent: photoWrapper
  	imagePath: imagePath
  	postId: postId
  	eradicateUrl: eradicateUrl
