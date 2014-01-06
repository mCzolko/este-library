###*
  @fileoverview Algorithm for pending navigation pattern. It maps browser
  behavior, don't show unloaded page and allow user to load another page
  before first page load is resolved.
  @see https://medium.com/joys-of-javascript/4353246f4480
###
goog.provide 'este.labs.app.LastWinUrlLoader'

goog.require 'este.labs.app.UrlLoader'
goog.require 'goog.async.nextTick'
goog.require 'goog.labs.Promise'
goog.require 'goog.object'

class este.labs.app.LastWinUrlLoader

  ###*
    @constructor
    @implements {este.labs.app.UrlLoader}
  ###
  constructor: ->
    @emptyPendings()

  ###*
    @enum {string}
  ###
  @CancelResolution:
    ABORT: 'abort'
    PENDING: 'pending'
    TIMEOUT: 'timeout'

  ###*
    @type {number}
  ###
  timeoutMs: 15 * 1000

  ###*
    @type {?string}
    @protected
  ###
  lastLoadedUrl: null

  ###*
    @type {Object}
    @protected
  ###
  pendings: null

  ###*
    @type {?number}
    @protected
  ###
  timeoutTimer: null

  ###*
    @override
  ###
  load: (url, load) ->
    @lastLoadedUrl = url
    if @pendings[url]
      return @createRejectedWithPendingPromise()
    if goog.object.isEmpty @pendings
      @timeoutTimer = setTimeout (=> @onTimeout()), @timeoutMs
    @pendings[url] = new goog.labs.Promise (resolve, reject) =>
      load().then(
        @onFulfill.bind @, url, resolve, reject
        @onReject.bind @, url, resolve, reject
      )
      return

  ###*
    @param {string} url
    @param {Function} resolve
    @param {Function} reject
    @param {*} value
    @protected
  ###
  onFulfill: (url, resolve, reject, value) ->
    @resetPendingsIfUrlWasLastLoaded url
    urlIsLastLoaded = url == @lastLoadedUrl
    goog.async.nextTick =>
      if urlIsLastLoaded
        resolve value
      else
        reject @createCancellationError LastWinUrlLoader.CancelResolution.ABORT

  ###*
    @param {string} url
    @param {Function} reject
    @param {*} reason
    @protected
  ###
  onReject: (url, resolve, reject, reason) ->
    @resetPendingsIfUrlWasLastLoaded url
    error = new este.labs.app.LastWinUrlLoader.Error reason
    error.isSilent = url != @lastLoadedUrl
    goog.async.nextTick -> reject error

  ###*
    @protected
  ###
  createRejectedWithPendingPromise: ->
    error = @createCancellationError LastWinUrlLoader.CancelResolution.PENDING
    goog.labs.Promise.reject error

  ###*
    @param {string} url
    @protected
  ###
  resetPendingsIfUrlWasLastLoaded: (url) ->
    return if url != @lastLoadedUrl
    @resetPendings url

  ###*
    @param {?string} url
    @param {string=} resolution
    @protected
  ###
  resetPendings: (url, resolution) ->
    @cancelPendingPromises url, resolution
    @emptyPendings()
    clearTimeout @timeoutTimer

  ###*
    @param {?string} url
    @param {string=} resolution
    @protected
  ###
  cancelPendingPromises: (url, resolution) ->
    for promiseUrl, promise of @pendings
      continue if promiseUrl == url
      promise.cancel resolution ? LastWinUrlLoader.CancelResolution.ABORT
    return

  ###*
    @protected
  ###
  emptyPendings: ->
    @pendings = Object.create null

  ###*
    @param {string} resolution
    @protected
  ###
  createCancellationError: (resolution) ->
    new goog.labs.Promise.CancellationError resolution

  ###*
    @protected
  ###
  onTimeout: ->
    @resetPendings null, LastWinUrlLoader.CancelResolution.TIMEOUT

class este.labs.app.LastWinUrlLoader.Error

  ###*
    @param {*} reason
    @constructor
    @final
  ###
  constructor: (@reason) ->

  ###*
    @type {*}
  ###
  reason: null

  ###*
    @type {boolean}
  ###
  isSilent: false