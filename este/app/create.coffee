###*
  @fileoverview Default factory for este.App.
###
goog.provide 'este.app.create'

goog.require 'este.App'
goog.require 'este.app.screen.create'
goog.require 'este.router.create'

###*
  @param {string|Element} element
  @param {{
    forceHash: (boolean|undefined),
    scrollingOnHistory: (boolean|undefined)
  }=} opt_options
  @return {este.App}
###
este.app.create = (element, opt_options) ->
  options =
    forceHash: true
    scrollingOnHistory: true
  goog.mixin options, opt_options if opt_options

  element = goog.dom.getElement element
  router = este.router.create element, options.forceHash
  screen = este.app.screen.create options.scrollingOnHistory
  screen.decorate element
  new este.App router, screen