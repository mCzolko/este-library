###*
  @fileoverview Click handler for client side routing.

  - Handle only relevant anchors, see este.dom.isRoutingClick.
  - Uses Polymer's PointerEvents to enable fast click on touch devices.

  Another trick, but this one does not work on iOS also sometimes we need zoom.
  https://plus.google.com/u/0/+RickByers/posts/ej7nsuoaaDa
###
goog.provide 'este.labs.events.RoutingClickHandler'

goog.require 'este.Base'
goog.require 'este.dom'
goog.require 'este.thirdParty.pointerEvents'

class este.labs.events.RoutingClickHandler extends este.Base

  ###*
    @param {Element=} element
    @constructor
    @extends {este.Base}
  ###
  constructor: (@element = document.documentElement) ->
    super()
    este.thirdParty.pointerEvents.install()
    @registerEvents()

  ###*
    @type {Element}
    @protected
  ###
  element: null

  ###*
    @protected
  ###
  registerEvents: ->
    # We need to listen click to be able to prevent anchor redirection.
    @on @element, goog.events.EventType.CLICK, @onElementClick
    return if !este.thirdParty.pointerEvents.isSupported()
    # Use pointerup for fast click.
    @on @element, goog.events.EventType.POINTERUP, @onElementPointerUp

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onElementClick: (e) ->
    anchor = @tryGetRoutingAnchor e
    return if !anchor
    e.preventDefault()
    return if este.thirdParty.pointerEvents.isSupported()
    # IE<10 does not support pointer events, so emulate it via click.
    @dispatchClick anchor

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onElementPointerUp: (e) ->
    anchor = @tryGetRoutingAnchor e
    return if !anchor
    @dispatchClick anchor

  ###*
    @param {goog.events.BrowserEvent} e
    @return {Element}
    @protected
  ###
  tryGetRoutingAnchor: (e) ->
    return null if !este.dom.isRoutingEvent e
    anchor = goog.dom.getAncestorByTagNameAndClass e.target, goog.dom.TagName.A
    return null if !anchor || !este.dom.isRoutingAnchor anchor
    anchor

  ###*
    @param {Element} anchor
    @protected
  ###
  dispatchClick: (anchor) ->
    @dispatchEvent
      target: anchor
      type: goog.events.EventType.CLICK