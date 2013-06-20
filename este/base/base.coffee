###*
  @fileoverview Base class for classes using events.
###
goog.provide 'este.Base'

goog.require 'goog.asserts'
goog.require 'goog.events.EventHandler'
goog.require 'goog.events.EventTarget'

class este.Base extends goog.events.EventTarget

  ###*
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: ->
    super()

  ###*
    @type {goog.events.EventHandler}
    @private
  ###
  handler_: null

  ###*
    @type {Array.<este.Base>}
  ###
  parents_: null

  ###*
    Alias for .listen.
    @param {goog.events.ListenableType} src Event source.
    @param {string|Array.<string>} type Event type to listen for or array of
      event types.
    @param {Function|Object=} fn Optional callback function to be used as
      the listener or an object with handleEvent function.
    @param {boolean=} capture Optional whether to use capture phase.
    @param {Object=} handler Object in whose scope to call the listener.
    @protected
  ###
  on: (src, type, fn, capture, handler) ->
    @getHandler().listen src, type, fn, capture, handler

  ###*
    Alias for .listenOnce.
    @param {goog.events.ListenableType} src Event source.
    @param {string|Array.<string>} type Event type to listen for or array of
      event types.
    @param {Function|Object=} fn Optional callback function to be used as
      the listener or an object with handleEvent function.
    @param {boolean=} capture Optional whether to use capture phase.
    @param {Object=} handler Object in whose scope to call the listener.
    @protected
  ###
  once: (src, type, fn, capture, handler) ->
    @getHandler().listenOnce src, type, fn, capture, handler

  ###*
    Alias for .unlisten.
    @param {goog.events.ListenableType} src Event source.
    @param {string|Array.<string>} type Event type to listen for or array of
      event types.
    @param {Function|Object=} fn Optional callback function to be used as
      the listener or an object with handleEvent function.
    @param {boolean=} capture Optional whether to use capture phase.
    @param {Object=} handler Object in whose scope to call the listener.
    @protected
  ###
  off: (src, type, fn, capture, handler) ->
    @getHandler().unlisten src, type, fn, capture, handler

  ###*
    Add parent for dispatch event.
    @param {este.Base} parent
    @protected
  ###
  addParent: (parent) ->
    goog.array.insert @getParents(), parent

  ###*
    Remove parent for dispatch event.
    @param {este.Base} parent
    @return {boolean} True if a parent was removed.
    @protected
  ###
  removeParent: (parent) ->
    goog.array.remove @getParents(), parent

  ###*
    Return dispatch event parents.
    @return {Array.<este.Base>}
    @protected
  ###
  getParents: ->
    @parents_ || @parents_ = []

  ###*
    @protected
  ###
  getHandler: ->
    @handler_ ?= new goog.events.EventHandler @

  ###*
    Dispatch event on instance itself and also on its parents. Useful when one
    model is placed in several collection. It enabled multi-parent events
    bubbling.
    @override
  ###
  dispatchEvent: (e) ->
    result = super e
    return result if !@parents_
    # clone array to safe iteration
    for parent in @getParents().slice 0
      parentResult = parent.dispatchEvent e
      result = false if parentResult == false
    result

  ###*
    @override
  ###
  disposeInternal: ->
    @handler_?.dispose()
    @parents_ = null
    super()
    return