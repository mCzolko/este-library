###*
  @fileoverview este.ui.Component provides easy event delegation and synthetic
  events registration. For example, if you want to use bubbling focus/blur, you
  have to instantiate goog.events.FocusHandler in enterDocument method, and
  dispose it in exitDocument. With este.ui.Component, you don't have to write
  this boilerplate code. For easy event delegation, replace event src with
  matching string selector.

  bindModel method is used for automatic element-model wiring via
  'e-model-cid' attribute in soy template.
  Example:
    este-library/este/demos/app/todomvc/js/todos/list/view.coffee
    este-library/este/demos/app/todomvc/js/todos/list/templates.soy

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

    this.registerEvents ->
      # note how bindModel is used
      this.on '.box', 'tap', this.bindModel this.onBoxTap
  @see ../demos/component.html
  @see ../demos/app/todomvc/js/todos/list/view.coffee
###
goog.provide 'este.ui.Component'

goog.require 'este.Collection'
goog.require 'este.dom'
goog.require 'este.dom.merge'
goog.require 'este.events.EventHandler'
goog.require 'este.Model'
goog.require 'goog.asserts'
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
    @param {Element} el
    @return {Element}
    @protected
  ###
  @getParentElementWithClientId: (el) ->
    parent = goog.dom.getAncestor el, (node) ->
      goog.dom.isElement(node) && node.hasAttribute 'e-model-cid'
    , true
    `/** @type {Element} */ (parent)`

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
    if useEventDelegation
      selector = src
      src = @getElement()

    isKeyEventType = goog.dom.isElement(src) && goog.isNumber type
    if isKeyEventType
      `var keyCode = /** @type {number} */ (type)`
      fn = Component.wrapListenerForKeyHandlerKeyFilter fn, keyCode, @
      type = 'key'

    if useEventDelegation
      # assert to make compiler happy about selector is string number
      goog.asserts.assertString selector
      fn = Component.wrapListenerForEventDelegation fn, selector, type
    `type = /** @type {string} */ (type)`
    `src = /** @type {goog.events.ListenableType} */ (src)`
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
    Should be overridden by subclasses.
    @protected
  ###
  registerEvents: ->

  ###*
    @override
  ###
  exitDocument: ->
    @esteHandler_?.removeAll()
    super()
    return

  ###*
    Use this method when target has e-model-cid attribute. It will pass model
    instead of element if such model exists on any collection on this instance.
    @param {Function} fn
    @return {Function}
  ###
  bindModel: (fn) ->
    (e) ->
      el = Component.getParentElementWithClientId e.target
      if el
        cid = el.getAttribute 'e-model-cid'
        model = @findModelOnInstanceByClientId cid
      fn.call @, model, el, e

  ###*
    @param {string} clientId
    @return {este.Model}
    @protected
  ###
  findModelOnInstanceByClientId: (clientId) ->
    for key, value of @
      if value instanceof este.Collection
        model = value.findByClientId clientId
        return model if model
      else if value instanceof este.Model
        return value if value.get('_cid') == clientId
    null