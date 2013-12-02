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
    @type {string}
  ###
  route: '/'

  ###*
    @type {function(Object): React.ReactComponent}
    @protected
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
    @protected
  ###
  reactComponent: null

  ###*
    @type {Element}
    @protected
  ###
  reactElement: null

  ###*
    @type {Object.<string, Function>}
    @protected
  ###
  handlers: null

  ###*
    @type {boolean}
    @private
  ###
  wasRendered_: false

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

  ###*
    @return {boolean}
  ###
  wasRendered: ->
    @wasRendered_

  ###*
    @return {Element}
  ###
  getElement: ->
    @reactElement || null

  ###*
    @param {Object} params
  ###
  load: (params) ->
    goog.labs.Promise.resolve params

  ###*
    @param {Element} container
    @param {Object} data
  ###
  show: (container, data) ->
    if !@wasRendered_
      @render container, data
      @wasRendered_ = true
      return
    @reactComponent.setProps data

  ###*
    @param {Object} data
  ###
  hide: (data) ->

  ###*
    @param {Element} container
    @param {Object=} data
    @protected
  ###
  render: (container, data) ->
    @reactComponent = @reactClass @getDataMixedWithHandlers data
    este.react.render @reactComponent, container
    @reactElement = @reactComponent.getDOMNode()

  ###*
    @param {Object=} data
    @protected
  ###
  getDataMixedWithHandlers: (data) ->
    mixed = {}
    goog.object.extend mixed, data || {}, @handlers || {}
    mixed