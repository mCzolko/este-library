###*
  @fileoverview Interface for URL loading strategy. It describes what should
  happen when user load next URL. Should be loaded sync, async, or should be
  loaded only the last requsted URL?
###
goog.provide 'este.labs.app.UrlLoader'

###*
  @interface
###
este.labs.app.UrlLoader = ->

###*
  @param {string} url
  @param {function(): !goog.Promise} load
  @return {!goog.Promise}
###
este.labs.app.UrlLoader::load