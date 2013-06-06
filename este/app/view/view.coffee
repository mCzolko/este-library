###*
  @fileoverview este.App sets createUrl and redirect methods automatically.
###
goog.provide 'este.app.View'

goog.require 'este.ui.View'
goog.require 'goog.dom.classlist'

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
    @type {goog.math.Coordinate}
  ###
  scroll: null

  ###*
    @override
  ###
  createDom: ->
    super()
    goog.dom.classlist.add @getElement(), 'e-app-view'
    goog.dom.classlist.add @getElement(), @className if @className
    return