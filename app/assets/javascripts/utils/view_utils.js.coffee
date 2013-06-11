# File: utils/view_utils

## Imports
Slinggit.Utils ||= {}

## Module
Slinggit.Utils.ViewUtils =
  get_scroll: ->
    $(window).scrollTop @scroll_position
    console.log "get"

  set_scroll: (reset_scroll_onrender) ->
    @scroll_position = $(window).scrollTop() if @reset_scroll
    @reset_scroll = @_reset_scroll(reset_scroll_onrender)
    console.log "set"

  _reset_scroll: (reset) ->
    (if not reset then reset else true)