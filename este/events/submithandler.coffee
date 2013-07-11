###*
  @fileoverview Wrapper for submit event with fix for IE8.
  @see ../demos/submithandler.html
###
goog.provide 'este.events.SubmitEvent'
goog.provide 'este.events.SubmitHandler'
goog.provide 'este.events.SubmitHandler.EventType'

goog.require 'este.Base'
goog.require 'este.dom'
goog.require 'goog.events.BrowserEvent'
goog.require 'goog.userAgent'

class este.events.SubmitHandler extends este.Base

  ###*
    @param {Element|Document=} node
    @constructor
    @extends {este.Base}
  ###
  constructor: (node = document) ->
    super()
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
    submitEvent = new este.events.SubmitEvent json, e
    @dispatchEvent submitEvent

###*
  @fileoverview este.events.SubmitEvent.
###
class este.events.SubmitEvent extends goog.events.BrowserEvent

  ###*
    @param {Object} json
    @param {goog.events.BrowserEvent} browserEvent
    @constructor
    @extends {goog.events.BrowserEvent}
  ###
  constructor: (@json, browserEvent) ->
    super browserEvent

  ###*
    @type {Object}
  ###
  json: null