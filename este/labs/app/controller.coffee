###*
  @fileoverview este.labs.app.Controller.
###
goog.provide 'este.labs.app.Controller'

goog.require 'este.labs.app.Route'
goog.require 'goog.labs.Promise'
goog.require 'este.react'

class este.labs.app.Controller

  ###*
    @constructor
  ###
  constructor: ->

  ###*
    @type {string}
  ###
  route: '/'

  ###*
    @type {function(): React.ReactComponent}
  ###
  reactClass: este.react.create (`/** @lends {React.ReactComponent.prototype} */`)
    render: ->
      @pre goog.DEBUG && """
        Warning: Missing React component.

        ###*
          @constructor
          @extends {este.labs.app.Controller}
        ###
        constructor: ->
          @route = '/'

          # Define your React component here.
          @reactClass = app.home.react.Index"""

  ###*
    @type {React.ReactComponent}
  ###
  react: null

  ###*
    @type {Object.<string, Function>}
  ###
  handlers: null

  ###*
    @param {Object} params
  ###
  load: (params) ->
    goog.labs.Promise.resolve params

  ###*
    @param {(Object|Array)} params
    @return {string}
  ###
  createUrl: (params) ->
    new este.labs.app.Route(@route).createUrl params

  ###*
    @param {(Object|Array)} params
    @return {string}
  ###
  redirect: (params) ->
    # new este.labs.app.Route(@route).createUrl params