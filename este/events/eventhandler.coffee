###*
  @fileoverview Powerfull event delegation for este.ui.Component.
  @see este.ui.Component
###
goog.provide 'este.events.EventHandler'

goog.require 'este.events.GestureHandler'
goog.require 'este.events.SubmitHandler'
goog.require 'goog.dom'
goog.require 'goog.events.EventHandler'
goog.require 'goog.events.FocusHandler'
goog.require 'goog.events.InputHandler'
goog.require 'goog.events.KeyHandler'
goog.require 'goog.events.MouseWheelHandler'

class este.events.EventHandler extends goog.events.EventHandler

  ###*
    @param {Object=} opt_handler Object in whose scope to call the listeners.
    @constructor
    @extends {goog.events.EventHandler}
  ###
  constructor: (opt_handler) ->
    super opt_handler

  ###*
    Global cache for synthetic event handlers. Useful for example when twelve
    components use tap event on the same element, GestureHandler is created
    only once.
    @type {Object}
    @private
  ###
  @handlers: {}

  ###*
    Return event handler for concrete src and type.
    @param {goog.events.ListenableType} src
    @param {string} type
    @return {Function}
    @private
  ###
  @getHandlerClass: (src, type) ->
    return null if !goog.dom.isElement src
    switch type
      when 'tap', 'swipeleft', 'swiperight', 'swipeup', 'swipedown'
        este.events.GestureHandler
      when 'submit'
        este.events.SubmitHandler
      when 'focusin', 'focusout'
        goog.events.FocusHandler
      when 'input'
        goog.events.InputHandler
      when 'key'
        goog.events.KeyHandler
      when 'mousewheel'
        goog.events.MouseWheelHandler
      else
        null

  ###*
    @param {goog.events.ListenableType} src
    @param {Function} handlerClass
    @return {goog.events.ListenableType}
    @private
  ###
  @lazyCreateHandler: (src, handlerClass) ->
    key = EventHandler.getKey src, handlerClass
    EventHandler.handlers[key] ?= new handlerClass src
    EventHandler.handlers[key]

  ###*
    @param {goog.events.ListenableType} src
    @param {Function} handlerClass
    @return {goog.events.ListenableType}
    @private
  ###
  @getHandler: (src, handlerClass) ->
    key = EventHandler.getKey src, handlerClass
    EventHandler.handlers[key]

  ###*
    @param {goog.events.ListenableType} src
    @param {Function} handlerClass
  ###
  @removeHandler: (src, handlerClass) ->
    key = EventHandler.getKey src, handlerClass
    handler = EventHandler.handlers[key]
    delete EventHandler.handlers[key]
    return if !handler
    handler.dispose()

  @removeHandlersWithoutListeners: ->
    EventHandler.handlers = goog.object.filter EventHandler.handlers, (v, k) ->
      return true if v.hasListener()
      v.dispose()
      false

  ###*
    @param {goog.events.ListenableType} src
    @param {Function} handlerClass
    @return {string}
    @private
  ###
  @getKey: (src, handlerClass) ->
    [goog.getUid(src), goog.getUid(handlerClass)].toString()

  ###*
    @override
  ###
  listen: (src, type, opt_fn, opt_capture, opt_handler) ->
    if goog.isArray type
      @listen src, t, opt_fn, opt_capture, opt_handler for t in type
      return @

    type = (`/** @type {string} */`) type
    handlerClass = EventHandler.getHandlerClass src, type

    if handlerClass
      src = EventHandler.lazyCreateHandler src, handlerClass

    super src, type, opt_fn, opt_capture, opt_handler

  ###*
    @override
  ###
  unlisten: (src, type, opt_fn, opt_capture, opt_handler) ->
    if goog.isArray type
      @listen src, t, opt_fn, opt_capture, opt_handler for t in type
      return @

    type = (`/** @type {string} */`) type
    handlerClass = EventHandler.getHandlerClass src, type
    originalSrc = null

    if handlerClass
      originalSrc = src
      src = EventHandler.getHandler src, handlerClass
      return @ if !src

    super src, type, opt_fn, opt_capture, opt_handler

    if handlerClass && !src.hasListener()
      EventHandler.removeHandler originalSrc, handlerClass
    @

  ###*
    @override
  ###
  removeAll: ->
    super()
    EventHandler.removeHandlersWithoutListeners()
    return