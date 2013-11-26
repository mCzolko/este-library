###*
  @fileoverview Watch clicking on anchors elements. It uses Polymer
  PointerEvents to enable fast click on touch devices.
  Note, this trick does not work on iOS also sometimes we need zoom.
  https://plus.google.com/u/0/+RickByers/posts/ej7nsuoaaDa
  @see TODO
###
goog.provide 'este.labs.events.AnchorClickHandler'

goog.require 'este.Base'
goog.require 'este.thirdParty.pointerEvents'

class este.labs.events.AnchorClickHandler extends este.Base

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
    # To prevent default anchor redirection behavior.
    @on @element, goog.events.EventType.CLICK, @onElementClick
    return if !este.thirdParty.pointerEvents.isSupported()
    # Use pointerup for fast click.
    @on @element, goog.events.EventType.POINTERUP, @onElementPointerUp

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onElementClick: (e) ->
    anchor = @tryGetClickableAnchor e.target
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
    anchor = @tryGetClickableAnchor e.target
    return if !anchor
    @dispatchClick anchor

  ###*
    @param {Node} node
    @return {Element}
    @protected
  ###
  tryGetClickableAnchor: (node) ->
    goog.dom.getAncestorByTagNameAndClass node, goog.dom.TagName.A

  ###*
    @param {Element} anchor
    @protected
  ###
  dispatchClick: (anchor) ->
    @dispatchEvent
      type: goog.events.EventType.CLICK
      target: anchor