###*
  @fileoverview Bubbled submit event. You can use activeElement property to
  distinguish which submit button caused form submit. If form submit is caused
  by enter key in text input field, then first submit button in document is
  used. This is default DOM behaviour hard to override without ugly hacks.
  Ex.
  # default submit button has to be first in DOM
  <input type="submit" name="save" value="save song">
  <input type="submit" name="delete" value="delete song">
  @see ../demos/submithandler.html
###
goog.provide 'este.events.SubmitEvent'
goog.provide 'este.events.SubmitHandler'
goog.provide 'este.events.SubmitHandler.EventType'

goog.require 'este.Base'
goog.require 'este.dom'
goog.require 'goog.events.BrowserEvent'
goog.require 'goog.events.ActionHandler'
goog.require 'goog.userAgent'

class este.events.SubmitHandler extends este.Base

  ###*
    @param {Element|Document=} node
    @constructor
    @extends {este.Base}
  ###
  constructor: (node = document) ->
    super()
    @actionHandler = new goog.events.ActionHandler node
    @on @actionHandler, 'action', @onActionHandlerAction
    # IE doesn't bubble submit event, but focusin with lazy submit registration
    # workarounds it well.
    eventType = if goog.userAgent.IE && !goog.userAgent.isDocumentModeOrHigher 9
      'focusin'
    else
      'submit'
    @on node, eventType, @

  ###*
    @enum {string}
  ###
  @EventType:
    SUBMIT: 'submit'

  ###*
    @type {Node|Element}
  ###
  activeElement: null

  ###*
    @type {goog.events.ActionHandler}
    @protected
  ###
  actionHandler: null

  ###*
    Enter on input field will fire click event on first submit button in
    document. So put
    @param {goog.events.ActionEvent} e
    @protected
  ###
  onActionHandlerAction: (e) ->
    @activeElement = e.target

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  handleEvent: (e) ->
    target = (`/** @type {Element} */`) e.target
    if e.type == 'focusin'
      form = goog.dom.getAncestorByTagNameAndClass target, 'form'
      @on form, 'submit', @ if form
      return
    e.preventDefault()
    json = este.dom.serializeForm target
    submitEvent = new este.events.SubmitEvent json, @activeElement, e
    @dispatchEvent submitEvent

  ###*
    @override
  ###
  disposeInternal: ->
    @actionHandler.dispose()
    super()
    return

###*
  @fileoverview este.events.SubmitEvent.
###
class este.events.SubmitEvent extends goog.events.BrowserEvent

  ###*
    @param {Object} json
    @param {Node|Element} activeElement
    @param {goog.events.BrowserEvent} browserEvent
    @constructor
    @extends {goog.events.BrowserEvent}
  ###
  constructor: (@json, @activeElement, browserEvent) ->
    super browserEvent

  ###*
    @type {Object}
  ###
  json: null

  ###*
    @type {Node|Element}
  ###
  activeElement: null