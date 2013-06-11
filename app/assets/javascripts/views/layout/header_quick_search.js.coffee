## Module
class HeaderSearch extends Backbone.View
  el: "#mainHeader"

  initialize: (options) ->
    _.bindAll @
    @$searchBox = $("#quickSearch")
    @$qsWrapper = $('#quickSearchWrapper')
    @isUp = true

  events:
    "click .quickSearchLabel": "upDown"
    #"focus #quickSearch": "setPosition"

  upDown: (e) ->

    if @isUp and @$qsWrapper.hasClass("hideSearch")
      @$qsWrapper.removeClass "hideSearch"
      @$searchBox.focus()
      @isUp = false

    else if not @isUp and not @$qsWrapper.hasClass("headerUp")
      if @$searchBox.val() isnt ""
        document.location.href = "/posts/results/#{$('#quickSearch').val()}"
      else
        @$searchBox.blur()
        @$qsWrapper.addClass "hideSearch"
        @isUp = true

  
## Export
window.initiHeaderSearch = ->
  new HeaderSearch