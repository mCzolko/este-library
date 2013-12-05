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
    TODO: Check return generics annotation.
    This method can be overridden.
    @param {Object} params
    @return {!goog.labs.Promise.<TYPE>}
    @template TYPE
  ###
  load: (params) ->
    goog.labs.Promise.resolve params

  ###*
    This method can be overridden.
    @param {Element} container
    @param {Object} data
  ###
  show: (container, data) ->
    if !@wasRendered_
      @render container, data, => @onShow()
      @wasRendered_ = true
      return
    @reactComponent.setProps data, => @onShow()

  ###*
    This method can be overridden.
  ###
  hide: ->
    @onHide()

  ###*
    This method can be overridden.
    @protected
  ###
  onShow: ->

  ###*
    This method can be overridden.
    @protected
  ###
  onHide: ->

  ###*
    @param {Element} container
    @param {Object} data
    @param {Function} callback
    @protected
  ###
  render: (container, data, callback) ->
    dataMixedWithHandlers = @getDataMixedWithHandlers data
    @reactComponent = @reactClass dataMixedWithHandlers
    este.react.render @reactComponent, container, callback
    @reactElement = @reactComponent.getDOMNode()

  ###*
    @param {Object=} data
    @protected
  ###
  getDataMixedWithHandlers: (data) ->
    mixed = {}
    goog.object.extend mixed, data || {}, @handlers || {}
    mixed