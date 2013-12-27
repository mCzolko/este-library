###*
  @fileoverview Base controller.
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
    Handlers for React component. Will be mixed with data for first shown.
    Has to be defined in constructor.
    @type {Object.<string, Function>}
  ###
  handlers: null

  ###*
    @type {function(Object): React.ReactComponent}
  ###
  reactClass: este.react.create (`/** @lends {React.ReactComponent.prototype} */`)
    render: ->
      @pre goog.DEBUG && """
        Hello from este.labs.app.Controller. This class should be subclassed.

        Example:

        class app.home.Controller extends este.labs.app.Controller

          ###*
            @constructor
            @extends {este.labs.app.Controller}
          ###
          constructor: ->
            # Example handlers for React, will be used for setProps.
            @handlers =
              onAutoCompleteUpdate: @onAutoCompleteUpdate

          ###*
            Custom React class.
            @override
          ###
          reactClass: app.home.react.Home

          ###*
            Custom data load. Remember to return promise.
            @override
          ###
          load: (params) ->
      """

  ###*
    @type {React.ReactComponent}
  ###
  react: null

  ###*
    @type {Element}
  ###
  reactElement: null

  ###*
    Load data for React and return them as Promise.
    @param {Object} params
    @return {!goog.labs.Promise.<TYPE>}
    @template TYPE
  ###
  load: (params) ->
    goog.labs.Promise.resolve params

  ###*
    Put show specific logic here. For example focus something.
  ###
  onShow: ->

  ###*
    Put hide specific logic here. For example disposing something.
  ###
  onHide: ->