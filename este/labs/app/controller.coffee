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
    React Class used for controller rendering.
    @type {function(Object): React.ReactComponent}
  ###
  reactClass: este.react.create (`/** @lends {React.ReactComponent.prototype} */`)
    render: ->
      @pre goog.DEBUG && """
        Base controller reactClass output.
        Add your own React component.
        Example:

        class app.home.Controller extends este.labs.app.Controller

          ###*
            @constructor
            @extends {este.labs.app.Controller}
          ###
          constructor: ->

          ###*
            @override
          ###
          reactClass: app.home.react.Home
      """

  ###*
    Handlers for React component. Will be mixed with data for first shown.
    Should be defined in child constructor.
    @type {Object.<string, Function>}
  ###
  handlers: null

  ###*
    # TODO: Try const annotation.
    @type {React.ReactComponent}
  ###
  react: null

  ###*
    Manually stored React element because getDOMNode does not work, if
    React component is not in document.
    # TODO: Try const annotation.
    @type {Element}
  ###
  reactElement: null

  ###*
    Load data for React and return them as Promise.
    TODO: Check return generics annotation.
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