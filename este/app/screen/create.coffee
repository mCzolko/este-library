###*
  @fileoverview Factory to create right este app screen for concrete device.
###
goog.provide 'este.app.screen.create'

goog.require 'este.app.screen.OneView'

###*
  @param {boolean} scrollingOnHistory
  @return {este.app.screen.Base}
###
este.app.screen.create = (scrollingOnHistory) ->
  new este.app.screen.OneView scrollingOnHistory