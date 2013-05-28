###*
  @fileoverview este.app.request.Queue.
###
goog.provide 'este.app.request.Queue'

goog.require 'goog.array'
goog.require 'goog.Disposable'

class este.app.request.Queue extends goog.Disposable

  ###*
    @constructor
    @extends {goog.Disposable}
  ###
  constructor: ->
    @pendings = []

  ###*
    @type {Array.<este.app.Request>}
    @protected
  ###
  pendings: null

  ###*
    @param {este.app.Request} request
  ###
  add: (request) ->
    @pendings.push request

  ###*
    @param {este.app.Request} request
  ###
  contains: (request) ->
    for pending in @pendings
      return true if pending.equal request
    false

  ###*
    @return {boolean}
  ###
  isEmpty: ->
    !@pendings.length

  ###*
    Clear pendings requests.
  ###
  clear: ->
    @pendings.length = 0

  ###*
    @override
  ###
  disposeInternal: ->
    @clear()
    super()