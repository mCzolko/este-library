###*
  @fileoverview este.ui.FieldReset.
###
goog.provide 'este.ui.FieldReset'

goog.require 'este.mobile'
goog.require 'goog.dom.classlist'
goog.require 'goog.events.InputHandler'
goog.require 'goog.string'
goog.require 'este.ui.Component'

class este.ui.FieldReset extends este.ui.Component

  ###*
    @param {Element} element
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: (element) ->
    @inputHandler = new goog.events.InputHandler element
    @resetBtn = goog.dom.createDom 'div', 'e-ui-fieldreset'
    @decorate element

  ###*
    @type {string}
  ###
  @CLASS_NAME: 'e-ui-fieldreset-empty'

  ###*
    @enum {string}
  ###
  @EventType:
    INPUT: 'input'

  ###*
    @type {goog.events.InputHandler}
    @protected
  ###
  inputHandler: null

  ###*
    @type {Element}
    @protected
  ###
  resetBtn: null

  ###*
    @override
  ###
  enterDocument: ->
    super()
    @on @inputHandler, 'input', @onInputHandlerInput
    @on '.e-ui-fieldreset tap', @onResetBtnTap
    @update()
    return

  ###*
    @override
  ###
  canDecorate: (element) ->
    element.tagName in ['INPUT', 'TEXTAREA']

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onInputHandlerInput: (e) ->
    @update()
    @dispatchEvent FieldReset.EventType.INPUT

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onResetBtnTap: (e) ->
    # prevents paste bubble in ios5 emulator
    e.preventDefault()
    @getElement().value = ''
    @update()
    @getElement().focus()
    @dispatchEvent FieldReset.EventType.INPUT

  ###*
    @protected
  ###
  update: ->
    isEmpty = !goog.string.trim(@getElement().value).length
    goog.dom.classlist.enable @getElement(), FieldReset.CLASS_NAME, isEmpty
    if isEmpty
      goog.dom.removeNode @resetBtn
    else
      goog.dom.insertSiblingAfter @resetBtn, @getElement()

  ###*
    @override
  ###
  disposeInternal: ->
    @inputHandler.dispose()
    super()
    return