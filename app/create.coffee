###*
  @fileoverview Default factory for este.App.
###
goog.provide 'este.app.create'

goog.require 'este.App'
goog.require 'este.app.screen.create'
goog.require 'este.router.create'

###*
  @param {string|Element} element
  @param {boolean|{
    forceHash: (boolean|undefined),
    scrollingOnHistory: (boolean|undefined)
  }=} arg
  @return {este.App}
###
este.app.create = (element, arg = false) ->
  options =
    forceHash: true
    scrollingOnHistory: true

  if typeof arg == 'object'
    goog.mixin options, arg
  else
    options.forceHash = arg

  element = goog.dom.getElement element
  router = este.router.create element, options.forceHash
  screen = este.app.screen.create options.scrollingOnHistory
  screen.decorate element
  new este.App router, screen