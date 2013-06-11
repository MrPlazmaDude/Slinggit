## Module
class PostCommentValidator extends Backbone.View
	el: ".new_comment"

	initialize: (options)->
		_.bindAll @
		@$commentBox = $("#comment_body")

	events: 
		"click #submitComment": "submitComment"

	submitComment: (e)->
		e.preventDefault()
		@$el.submit() unless @$commentBox.val() is ""



## Exports
window.commentInputValidator = ()->
	new PostCommentValidator()