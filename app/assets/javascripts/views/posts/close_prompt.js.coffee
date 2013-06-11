## Module
class ClosePostModal extends Backbone.View
	el: "#postContolsActions"

	initialize: (options)->
		_.bindAll @
		@$modal = $("#closePromptModal")
		# We have to bind the click event this way instead of in the events hash because
		# next we're going to move the modal div out to the body.
		@$fieldsets = @$modal.find('fieldset')
		@$fieldsets.live "click", @selectRadio
		# We have to move this to the body element to get it out of the
		# page wrapper
		@$modal.appendTo("body")

	events:
		"click #archivePrompt" : "showModal"

	selectRadio: (e)->
		@radioToSelect = $(e.currentTarget).find("input[type='radio']").attr("checked", "checked")

	showModal: ()->
		@$modal.modal('show')


window.initPostModal = ()->
	new ClosePostModal