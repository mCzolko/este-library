###*
  @fileoverview Rest JSON storage.
  @see /demos/storage/rest.html
###
goog.provide 'este.storage.Rest'

goog.require 'este.json'
goog.require 'este.storage.Base'
goog.require 'goog.labs.net.xhr'
goog.require 'goog.object'
goog.require 'goog.string'
goog.require 'goog.uri.utils'

class este.storage.Rest extends este.storage.Base

  ###*
    @param {string} namespace
    @param {string|number=} version
    @param {Object=} queryParams
    @constructor
    @extends {este.storage.Base}
  ###
  constructor: (namespace, version, queryParams) ->
    super namespace, version
    @namespace = namespace.replace ':version', @version
    @queryParams = queryParams ? null

  ###*
    @type {Object}
    @protected
  ###
  queryParams: null

  ###*
    @protected
  ###
  xhrOptions:
    headers:
      'Content-Type': 'application/json;charset=utf-8'

  ###*
    @override
  ###
  addInternal: (model, url) ->
    restUrl = @getRestUrl url
    data = model.toJson true
    data = este.json.stringify data
    result = goog.labs.net.xhr.postJson restUrl, data, @xhrOptions
    goog.result.transform result, (json) ->
      model.set json
      model


  ###*
    @override
  ###
  loadInternal: (model, url) ->
    id = model.getId()
    restUrl = @getRestUrl url, id
    result = goog.labs.net.xhr.getJson restUrl, @xhrOptions
    goog.result.transform result, (json) ->
      model.set json
      model

  ###*
    @override
    @suppress {accessControls} Workaround for addJsonParsingCallbacks_.
  ###
  saveInternal: (model, url) ->
    id = model.getId()
    restUrl = @getRestUrl url, id
    data = model.toJson true
    data = este.json.stringify data
    result = goog.labs.net.xhr.send 'PUT', restUrl, data, @xhrOptions
    jsonResult = goog.labs.net.xhr.addJsonParsingCallbacks_ result, @xhrOptions
    goog.result.transform jsonResult, (json) ->
      model.set json
      model

  ###*
    @override
  ###
  removeInternal: (model, url) ->
    id = model.getId()
    restUrl = @getRestUrl url, id
    result = goog.labs.net.xhr.send 'DELETE', restUrl, null, @xhrOptions
    goog.result.transform result, -> model

  ###*
    @override
  ###
  queryInternal: (collection, url, params) ->
    restUrl = @getRestUrl url
    if params
      restUrl = goog.uri.utils.appendParamsFromMap restUrl, params
    result = goog.labs.net.xhr.getJson restUrl, @xhrOptions
    goog.result.transform result, (json) ->
      collection.reset json
      collection

  ###*
    @param {string} url
    @param {string=} id
    @protected
  ###
  getRestUrl: (url, id) ->
    restUrl = goog.uri.utils.appendPath @namespace, url
    if id
      restUrl = goog.uri.utils.appendPath restUrl, id
    if @queryParams
      restUrl = goog.uri.utils.appendParamsFromMap restUrl, @queryParams
    restUrl

  ###*
    @param {goog.result.Result} result
    @return {XMLHttpRequest}
  ###
  getXhrFromResult: (result) ->
    loop
      results = result.getParentResults()
      return null if !results || !results.length
      result = results[0]
      value = result.getValue()
      return value if value instanceof XMLHttpRequest