###*
  @fileoverview este.App sets createUrl and redirect methods automatically.
###
goog.provide 'este.app.View'

goog.require 'este.ui.View'
goog.require 'goog.dom.classes'

class este.app.View extends este.ui.View

  ###*
    @constructor
    @extends {este.ui.View}
  ###
  constructor: ->
    super()

  ###*
    @type {string}
  ###
  className: ''

  ###*
    @type {Function}
  ###
  createUrl: null

  ###*
    @type {Function}
  ###
  redirect: null

  ###*
    @override
  ###
  createDom: ->
    super()
    if @className
      goog.dom.classes.add @getElement(), @className
    return