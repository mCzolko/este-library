###*
  @fileoverview este.ui.Components provides easy event delegation and synthetic
  events registration. For example, if you want to use bubbling focus/blur, you
  have to instantiate goog.events.FocusHandler in enterDocument method, and
  dispose it in exitDocument. With este.ui.Component, you don't have to write
  this boilerplate code. For easy event delegation, replace event src with
  matching string selector.

  Supported synthetic (with bubbling) events:
    - tap, swipeleft, swiperight, swipeup, swipedown
    - focusin, focusout
    - input
    - submit
    - key or number from goog.events.KeyCodes enumeration

  Examples:
    this.registerEvents ->
      this.on this.getElement(), 'click', this.onClick
      this.on '.box', 'tap', this.onBoxTap
      this.on 'input', 'focusin', this.onInputFocus
      this.on this.boxElement, 'tap', this.onTap
      this.on '.button', 'swipeleft', this.onButtonSwipeleft
      this.on '#new-todo-form', 'submit', this.onNewTodoFormSubmit
      this.on '.toggle', 'dblclick', this.onToggleDblclick
      this.on '.new-post', goog.events.KeyCodes.ENTER, this.onNewCommentKeyEnter
  @see ../demos/component.html
###
goog.provide 'este.ui.Component'

goog.require 'este.dom'
goog.require 'este.dom.merge'
goog.require 'este.events.EventHandler'
goog.require 'goog.asserts'
goog.require 'goog.dom.classlist'
goog.require 'goog.ui.Component'

class este.ui.Component extends goog.ui.Component

  ###*
    @param {goog.dom.DomHelper=} domHelper Optional DOM helper.
    @constructor
    @extends {goog.ui.Component}
  ###
  constructor: (domHelper) ->
    super domHelper

  ###*
    @param {Function} fn
    @param {number} keyCode
    @param {*} handler
    @return {Function}
    @protected
  ###
  @wrapListenerForKeyHandlerKeyFilter: (fn, keyCode, handler) ->
    (e) ->
      return if e.keyCode != keyCode
      fn.call handler, e

  ###*
    @param {Function} fn
    @param {string} selector
    @param {string|number} type
    @return {Function}
    @protected
  ###
  @wrapListenerForEventDelegation: (fn, selector, type) ->
    matcher = (node) ->
      goog.dom.isElement(node) && este.dom.match node, selector
    (e) ->
      target = goog.dom.getAncestor e.target, matcher, true
      return if !target || este.dom.isMouseHoverEventWithinElement e, target
      e.originalTarget = e.target
      e.target = target
      fn.call @, e

  ###*
    @type {este.events.EventHandler}
    @private
  ###
  esteHandler_: null

  ###*
    @param {goog.events.ListenableType|string} src Event source.
    @param {string|number|!Array.<string|number>} type Event type to listen for
      or array of event types.
    @param {Function} fn Optional callback function to be used as the listener.
    @param {boolean=} capture Optional whether to use capture phase.
    @param {Object=} handler Object in whose scope to call the listener.
    @protected
  ###
  on: (src, type, fn, capture, handler) ->
    goog.asserts.assert @isInDocument(), "Use registerEvents method to ensure
      events are registered in enterDocument. @on has to be called only in
      enterDocument method, because exitDocument will @off it."
    if goog.isArray type
      @on src, t, fn, capture, handler for t in type
      return
    useEventDelegation = goog.isString src
    if goog.isString src
      selector = src
      src = @getElement()
    if goog.dom.isElement(src) && goog.isNumber type
      fn = Component.wrapListenerForKeyHandlerKeyFilter fn, type, @
      type = 'key'
    if useEventDelegation
      # assert to make compiler happy about selector is string number
      goog.asserts.assertString selector
      fn = Component.wrapListenerForEventDelegation fn, selector, type
    # assert to make compiler happy about type is not number
    goog.asserts.assertString type
    @getHandler().listen src, type, fn, capture, handler
    return

  ###*
    @param {goog.events.ListenableType|string} src Event source.
    @param {string|number|!Array.<string|number>} type Event type to listen for
      or array of event types.
    @param {Function} fn Optional callback function to be used as the listener.
    @param {boolean=} capture Optional whether to use capture phase.
    @param {Object=} handler Object in whose scope to call the listener.
    @protected
  ###
  once: (src, type, fn, capture, handler) ->
    throw Error 'not yet implemented'
    # goog.asserts.assert @isInDocument(), "Use registerEvents method to ensure
    #   events are registered in enterDocument. @on has to be called only in
    #   enterDocument method, because exitDocument will @off it."
    # if goog.isArray type
    #   @once src, t, fn, capture, handler for t in type
    #   return
    # # assert to make compiler happy about type is not number
    # goog.asserts.assertString type
    # @getHandler().listenOnce src, type, fn, capture, handler

  ###*
    @param {goog.events.ListenableType|string} src Event source.
    @param {string|number|!Array.<string|number>} type Event type to listen for
      or array of event types.
    @param {Function} fn Optional callback function to be used as the listener.
    @param {boolean=} capture Optional whether to use capture phase.
    @param {Object=} handler Object in whose scope to call the listener.
    @protected
  ###
  off: (src, type, fn, capture, handler) ->
    throw Error 'not yet implemented'
    # if goog.isArray type
    #   @off src, t, fn, capture, handler for t in type
    #   return
    # # assert to make compiler happy about type is not number
    # goog.asserts.assertString type
    # @getHandler().listenOnce src, type, fn, capture, handler

  ###*
    @override
  ###
  getHandler: ->
    @esteHandler_ ?= new este.events.EventHandler @

  ###*
    @override
  ###
  enterDocument: ->
    super
    @registerEvents()
    return

  ###*
    @override
  ###
  exitDocument: ->
    @esteHandler_?.removeAll()
    super()
    return

  ###*
    Should be overridden by subclasses.
    @protected
  ###
  registerEvents: ->