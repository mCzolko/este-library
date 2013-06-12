###*
  @fileoverview este.App sets createUrl and redirect methods automatically.
###
goog.provide 'este.app.View'

goog.require 'este.ui.Component'
goog.require 'goog.dom.classlist'

class este.app.View extends este.ui.Component

  ###*
    @constructor
    @extends {este.ui.Component}
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
    View has to remember its scroll position.
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