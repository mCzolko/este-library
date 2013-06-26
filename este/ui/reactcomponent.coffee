###*
  @fileoverview este.ui.ReactComponent.
  EXPERIMENTAL STUFF

  TODO: add compile define for es5-shim for IE<9
###
goog.provide 'este.ui.ReactComponent'

goog.require 'este.ui.Component'
goog.require 'este.ui.react'
goog.require 'goog.object'

class este.ui.ReactComponent extends este.ui.Component

  ###*
    @param {este.Model=} model
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: (@model = null) ->
    super()

  ###*
    @type {este.Model}
    @protected
  ###
  model: null

  ###*
    @type {Object}
    @protected
  ###
  react: null

  ###*
    @override
  ###
  createDom: ->
    super()
    @model ?= new este.Model
    reactClass = window['React']['createClass']
      'getInitialState': => @model.toJson()
      'render': goog.bind @template, @
    @react = reactClass()

  ###*
    @protected
  ###
  template: ->
    @el 'div'

  ###*
    React.DOM syntax sugar. Functions are auto binded. Props can be ommited.
    @param {string} tagName
    @param {*=} props
    @param {*=} children
    @return {Object} React Component.
    @protected
  ###
  el: (tagName, props, children) ->
    propsIsChildren =
      arguments.length == 2 &&
      typeof props in ['string', 'number', 'boolean'] ||
      goog.isArrayLike props
    if propsIsChildren
      children = props
      props = null
    if goog.isObject props
      props = goog.object.map props, (value, key) =>
        return value if !goog.isFunction value
        goog.bind value, @
    window['React']['DOM'][tagName] props, children

  ###*
    @override
  ###
  canDecorate: (element) ->
    false

  ###*
    @override
  ###
  enterDocument: ->
    super
    @renderReact()
    @on @model, 'update', @updateReactState
    return

  ###*
    @protected
  ###
  renderReact: ->
    window['React']['renderComponent'] @react, @getElement()

  ###*
    @protected
  ###
  updateReactState: ->
    @react['setState'] @model.toJson()