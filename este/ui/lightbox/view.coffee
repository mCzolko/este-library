###*
  @fileoverview este.ui.lightbox.View.
###
goog.provide 'este.ui.lightbox.View'
goog.provide 'este.ui.lightbox.View.EventType'

goog.require 'este.ui.Component'
goog.require 'este.ui.lightbox.templates'

class este.ui.lightbox.View extends este.ui.Component

  ###*
    @param {Element} currentAnchor
    @param {Array.<Element>} anchors
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: (@currentAnchor, @anchors) ->
    super()

  ###*
    @enum {string}
  ###
  @EventType:
    CLOSE: 'close'

  ###*
    @type {string}
  ###
  className: 'e-ui-lightbox'

  ###*
    @type {Element}
    @protected
  ###
  currentAnchor: null

  ###*
    @type {Array.<Element>}
    @protected
  ###
  anchors: null

  ###*
    @override
  ###
  createDom: ->
    super()
    @getElement().className = @className
    goog.dom.setFocusableTabIndex @getElement(), true
    @update()
    este.dom.focusAsync @getElement()
    return

  ###*
    @override
  ###
  canDecorate: (element) ->
    false

  ###*
    @override
  ###
  registerEvents: ->
    @on '.e-ui-lightbox-close', 'click', @close
    @on '.e-ui-lightbox-previous', 'click', @moveLeft
    @on '.e-ui-lightbox-next', 'click', @moveRight
    @on '*', goog.events.KeyCodes.ESC, @close
    @on '*', [
      goog.events.KeyCodes.LEFT
      goog.events.KeyCodes.UP
    ], @moveLeft
    @on '*', [
      goog.events.KeyCodes.RIGHT
      goog.events.KeyCodes.DOWN
    ], @moveRight
    @on '*', [
      goog.events.KeyCodes.HOME
      goog.events.KeyCodes.PAGE_UP
    ], @moveStart
    @on '*', [
      goog.events.KeyCodes.END
      goog.events.KeyCodes.PAGE_DOWN
    ], @moveEnd

  ###*
    @protected
  ###
  close: ->
    @dispatchEvent View.EventType.CLOSE

  ###*
    @protected
  ###
  moveLeft: ->
    @move false
    @update()

  ###*
    @protected
  ###
  moveRight: ->
    @move true
    @update()

  ###*
    @protected
  ###
  moveStart: ->
    @currentAnchor = @anchors[0]
    @update()

  ###*
    @protected
  ###
  moveEnd: ->
    @currentAnchor = @anchors[@anchors.length - 1]
    @update()

  ###*
    @param {boolean} next
    @protected
  ###
  move: (next) ->
    idx = goog.array.indexOf @anchors, @currentAnchor
    if next then idx++ else idx--
    anchor = @anchors[idx]
    return if !anchor
    @currentAnchor = anchor

  ###*
    @protected
  ###
  update: ->
    json = @getViewJson()
    html = este.ui.lightbox.templates.view json
    este.dom.merge @getElement(), html

  ###*
    @return {Object}
    @protected
  ###
  getViewJson: ->
    src: @currentAnchor.href
    title: @currentAnchor.title
    idx: goog.array.indexOf @anchors, @currentAnchor
    total: @anchors.length