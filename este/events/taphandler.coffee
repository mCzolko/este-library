###*
  @fileoverview TapHandler is general tap event both for mobile and desktop.
  For touch devices, touchstart is used, which fixes 300ms click delay.
  This approach is also known as FastButton, but TapHandler implementation
  is better, because works fine with native mobile scroll momentum.

  TODO: enable deprecated annotation
  (at)deprecated Use este.events.GestureHandler
  @see ../demos/taphandler.html
###
goog.provide 'este.events.TapHandler'
goog.provide 'este.events.TapHandler.EventType'

goog.require 'este.Base'
goog.require 'goog.dom'
goog.require 'goog.math.Coordinate'
goog.require 'goog.userAgent'

class este.events.TapHandler extends este.Base

  ###*
    @param {Element} element
    @param {boolean=} touchSupported
    @constructor
    @extends {este.Base}
  ###
  constructor: (@element, touchSupported) ->
    super()
    @touchSupported = touchSupported ? goog.userAgent.MOBILE
    @registerEvents()

  ###*
    @enum {string}
  ###
  @EventType:
    START: 'start'
    END: 'end'
    TAP: 'tap'

  ###*
    TapHandler needs to know scrollable elements to listen its scroll and
    prevent tap dispatching on scroll momentum. Very useful feature. OneView
    screen uses only body element. FxView will have to add all its srollable
    views.
    @param {Element} element
  ###
  @addScrollable: (element) ->
    if element.tagName == 'BODY'
      window = goog.dom.getWindow element.ownerDocument
      TapHandler.scrollables.push window
      return
    TapHandler.scrollables.push element

  ###*
    @param {goog.events.BrowserEvent} e
    @return {!goog.math.Coordinate}
  ###
  @getTouchClients: (e) ->
    touches = e.getBrowserEvent().touches[0]
    new goog.math.Coordinate touches.clientX, touches.clientY

  ###*
    @param {Node} target
    @return {Node}
  ###
  @ensureTargetIsElement: (target) ->
    # IOS4 bug: touch events are fired on text nodes
    target = target.parentNode if target.nodeType == 3
    target

  ###*
    @type {Array.<Element|Window>}
    @protected
  ###
  @scrollables: []

  ###*
    @type {number}
  ###
  touchMoveSnap: 10

  ###*
    @type {number}
  ###
  touchEndTimeout: 10

  ###*
    @type {Element}
    @protected
  ###
  element: null

  ###*
    @type {boolean}
    @protected
  ###
  touchSupported: false

  ###*
    @type {goog.math.Coordinate}
    @protected
  ###
  coordinate: null

  ###*
    @type {boolean}
    @protected
  ###
  scrolled: false

  ###*
    @return {Element}
  ###
  getElement: ->
    @element

  ###*
    @protected
  ###
  registerEvents: ->
    if @touchSupported
      @on @element, 'touchstart', @onTouchStart
    else
      @on @element, ['mousedown', 'mouseup', 'click'], @onMouseAction

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onTouchStart: (e) ->
    @coordinate = TapHandler.getTouchClients e
    @scrolled = false
    @enableScrollEvents true
    @enableTouchMoveEndEvents true
    @dispatchTapEvent TapHandler.EventType.START, e.target

  ###*
    @param {boolean} enable
    @protected
  ###
  enableScrollEvents: (enable) ->
    for scrollable in TapHandler.scrollables
      if enable
        @on scrollable, 'scroll', @onScroll
      else
        @off scrollable, 'scroll', @onScroll
    return

  ###*
    @param {boolean} enable
    @protected
  ###
  enableTouchMoveEndEvents: (enable) ->
    html = @element.ownerDocument.documentElement
    if enable
      @on html, 'touchmove', @onTouchMove
      @on @element, 'touchend', @onTouchEnd
    else
      @off html, 'touchmove', @onTouchMove
      @off @element, 'touchend', @onTouchEnd

  ###*
    @param {string} type
    @param {Node} target
    @param {goog.events.BrowserEvent=} clickEvent
    @protected
  ###
  dispatchTapEvent: (type, target, clickEvent) ->
    target = TapHandler.ensureTargetIsElement target
    return if !target
    @dispatchEvent
      type: type
      target: target
      clickEvent: clickEvent

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onTouchMove: (e) ->
    return if !@coordinate? # because compiler needs !null
    distance = goog.math.Coordinate.distance @coordinate,
      TapHandler.getTouchClients e
    return if distance < @touchMoveSnap
    @dispatchTapEvent TapHandler.EventType.END, e.target
    @enableTouchMoveEndEvents false
    @enableScrollEvents false

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onTouchEnd: (e) ->
    target = e.target
    @enableTouchMoveEndEvents false
    setTimeout =>
      @dispatchTapEvent TapHandler.EventType.END, target
      @enableScrollEvents false
      return if @scrolled
      @dispatchTapEvent TapHandler.EventType.TAP, target
    , @touchEndTimeout

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onScroll: (e) ->
    @scrolled = true

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onMouseAction: (e) ->
    switch e.type
      when 'mousedown'
        @dispatchTapEvent TapHandler.EventType.START, e.target
      when 'mouseup'
        @dispatchTapEvent TapHandler.EventType.END, e.target
      when 'click'
        @dispatchTapEvent TapHandler.EventType.TAP, e.target, e