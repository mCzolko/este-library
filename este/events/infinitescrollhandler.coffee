###*
  @fileoverview Class to detect scrollable content reaching scroll end. Then
  'load' event is dispatched.

  @see /demos/events/infinitescrollhandler.html
###
goog.provide 'este.events.InfiniteScrollHandler'

goog.require 'este.Base'

class este.events.InfiniteScrollHandler extends este.Base

  ###*
    @param {Element} element
    @param {Function} load
    @constructor
    @extends {este.Base}
  ###
  constructor: (@element, @load) ->
    super()

  ###*
    @enum {string}
  ###
  @EventType:
    LOAD: 'load'

  ###*
    Threshold in px.
    @type {number}
  ###
  threshold: 0

  ###*
    @type {Element}
    @protected
  ###
  element: null

  ###*
    @type {Function}
    @protected
  ###
  load: null

  ###*
    @param {boolean} enable
  ###
  setEnabled: (enable) ->
    if enable
      @on @element, 'scroll', @onElementScroll
    else
      @off @element, 'scroll', @onElementScroll

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onElementScroll: (e) ->
    shouldScroll =
      @element.scrollTop + @element.offsetHeight >=
      @element.scrollHeight - @threshold
    return if !shouldScroll
    @setEnabled false
    @load => @setEnabled true