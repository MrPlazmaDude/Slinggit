## Module
class QuickSearchView extends Backbone.View
	el: "#quickSearchWrapper"

	events:
		"keypress #quickSearch": "buildUrl"

	buildUrl: (e)->
		if e.which is 13
			e.preventDefault()
			document.location.href = "/posts/results/#{$('#quickSearch').val()}"


## Exports
@quickSearchView = ()->
	return new QuickSearchView