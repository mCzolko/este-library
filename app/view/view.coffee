###*
  @fileoverview este.App sets createUrl and redirect methods automatically.
###
goog.provide 'este.app.View'

goog.require 'este.ui.View'

class este.app.View extends este.ui.View

  ###*
    @constructor
    @extends {este.ui.View}
  ###
  constructor: ->
    super()

  ###*
    @type {Function}
  ###
  createUrl: null

  ###*
    @type {Function}
  ###
  redirect: null