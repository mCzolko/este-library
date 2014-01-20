###*
  @fileoverview este.labs.app.ReactPage.
###
goog.provide 'este.labs.app.ReactPage'

goog.require 'este.labs.app.Page'
goog.require 'este.react'
goog.require 'goog.asserts'
goog.require 'goog.labs.Promise'
goog.require 'goog.object'

class este.labs.app.ReactPage

  ###*
    @constructor
    @implements {este.labs.app.Page}
  ###
  constructor: ->

  ###*
    Should be overridden in child constructor.
    @type {function(Object): React.ReactComponent}
    @protected
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
    Can be overridden in child constructor.
    @type {Object}
    @protected
  ###
  pageProps: null

  ###*
    @type {React.ReactComponent}
    @protected
  ###
  react: null

  ###*
    @type {Element}
    @protected
  ###
  reactElement: null

  ###*
    @override
  ###
  load: (params) ->
    goog.labs.Promise.resolve params

  ###*
    @override
  ###
  show: (container, data) ->
    data ?= {}
    goog.asserts.assertObject data

    # TODO: Check if React callback is really async.
    if @react
      @react.setProps data, => @onShow()
      return

    props = {}
    goog.object.extend props, data
    if @pageProps
      for key, value of @pageProps
        props[key] = if goog.isFunction value then value.bind @ else value
    @react = @reactClass props
    este.react.render @react, container, =>
      @reactElement = @react.getDOMNode()
      @onShow()
    return

  ###*
    @protected
  ###
  onShow: ->

  ###*
    @override
  ###
  hide: ->
    @onHide()

  ###*
    @protected
  ###
  onHide: ->

  ###*
    @override
  ###
  getElement: ->
    @reactElement