###*
  @fileoverview este.app.screen.Base.
###
goog.provide 'este.app.screen.Base'

goog.require 'este.ui.Component'

class este.app.screen.Base extends este.ui.Component

  ###*
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: ->
    super()

  ###*
    @param {este.app.View} view
  ###
  show: goog.abstractMethod

  ###*
    @param {este.app.View} view
  ###
  hide: goog.abstractMethod