class JankyHeaderHider extends Backbone.View
	el: "body"

	initialize: (options)->
		@headerHidden = false
		@$headerEl = $("#mainHeader")

	events:
		"focus input": "focus"
		"focus textarea": "focus"
		"blur input": "blur"
		"blur textarea": "blur"

	focus: (e)->
		@$headerEl.addClass "headerHideOnFocus" unless e.currentTarget.id is "quickSearch"

	blur: (e)->
		setTimeout ()=>
			@$headerEl.removeClass "headerHideOnFocus" if document.activeElement is document.body
		, 1000

		
## Export
$(document).ready ->
	#new JankyHeaderHider