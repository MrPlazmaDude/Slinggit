# File: collections/posts

## Imports
Slinggit.Collections ||= {}

## Module
class Slinggit.Collections.Posts extends Backbone.Collection
	url: "/posts"
	model: Slinggit.Models.Post

	initialize: (options)->
		@defaultUrl = @url
		@postType = options.post_list_type

	restoreDefualtUrl: =>
		@url = @defaultUrl

	setPostType: (type)=>
		@postType = type

	getPostType: =>
		return @postType