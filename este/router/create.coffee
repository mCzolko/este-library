###*
  @fileoverview Router factory.
  @see ../demos/router.html
###
goog.provide 'este.router.create'

goog.require 'este.events.GestureHandler'
goog.require 'este.History'
goog.require 'este.Router'

###*
  @param {Element=} element
  @param {boolean=} forceHash
  @param {string=} pathPrefix Should start and end with slash.
  @return {este.Router}
###
este.router.create = (element = document.body, forceHash, pathPrefix) ->
  history = new este.History forceHash, pathPrefix
  gestureHandler = new este.events.GestureHandler element
  new este.Router history, gestureHandler