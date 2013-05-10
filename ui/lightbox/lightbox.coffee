###*
  @fileoverview este.ui.lightbox.Lightbox.
###
goog.provide 'este.ui.lightbox.Lightbox'

goog.require 'este.ui.Component'

class este.ui.lightbox.Lightbox extends este.ui.Component

  ###*
    @param {Function} createView
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: (@createView) ->
    super()

  ###*
    @type {Function}
    @protected
  ###
  createView: null

  ###*
    @override
  ###
  registerEvents: ->
    @on @, este.ui.lightbox.View.EventType.CLOSE, @onViewClose
    @on
      'a click': @onAnchorClick
      'a tap': @onAnchorTap
    return

  ###*
    @param {goog.events.Event} e
    @protected
  ###
  onViewClose: (e) ->
    @closeView()

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onAnchorClick: (e) ->
    return if !@isLightboxAnchor e.target
    e.preventDefault()

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onAnchorTap: (e) ->
    return if !@isLightboxAnchor e.target
    @showView e.target

  ###*
    @param {Node} node
    @protected
  ###
  isLightboxAnchor: (node) ->
    node.rel.indexOf('lightbox') == 0

  ###*
    @param {Node} anchor
    @protected
  ###
  showView: (anchor) ->
    @closeView()
    anchors = @getAnchorsWithSameRelAttribute anchor.rel
    view = @createView anchor, anchors
    @addChild view, true

  ###*
    @protected
  ###
  closeView: ->
    @removeChildren true

  ###*
    @param {string} rel
    @protected
  ###
  getAnchorsWithSameRelAttribute: (rel) ->
    @getElement().querySelectorAll "a[rel='#{rel}']"