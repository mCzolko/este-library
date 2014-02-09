###*
  @fileoverview este.react.
  @namespace este.react
###
goog.provide 'este.react'
goog.provide 'este.react.create'
goog.provide 'este.react.render'
goog.provide 'este.react.unmount'

goog.require 'este.array'
goog.require 'este.thirdParty.react'
goog.require 'goog.asserts'
goog.require 'goog.object'

###*
  Creates React factory with mixined template sugar methods. It allows us to
  use "this.h3 'Foo'" instead of verbose "React.DOM.h3 null, 'Foo'".
  @param {Object} proto
  @return {function(*=, *=): React.ReactComponent}
###
este.react.create = (proto) ->
  este.react.syntaxSugarize proto
  factory = React.createClass (`/** @lends {React.ReactComponent.prototype} */`) proto
  este.react.improve factory

###*
  Render React component.
  @param {React.ReactComponent} component
  @param {Element} container
  @param {Function=} callback
  @return {React.ReactComponent} Component instance rendered in container.
###
este.react.render = (component, container, callback = ->) ->
  React.renderComponent component, container, callback

###*
 Render React component to string.
 @param {React.ReactComponent} component
 @param {function(S):?} callback
 @template S
###
este.react.renderToString = (component, callback) ->
 React.renderComponentToString component, callback

###*
  Remove a mounted React component from the DOM and clean up its event handlers
  and state.
  @param {Element} container
  @return {boolean}
###
este.react.unmount = (container) ->
  React.unmountComponentAtNode container

###*
  Copy React.DOM methods into React component prototype.
  @param {Object} proto
  @private
###
este.react.syntaxSugarize = (proto) ->
  for tag, factory of React.DOM
    continue if !goog.isFunction factory
    proto[tag] = este.react.improve factory
  return

###*
  This allows us to ommit props, and specify children as array to have
  idiomatic Coffee-like syntax. TODO: Add better type check.
  Examples:
    p 'Foo'
    p ['Foo']
    p 'className': 'foo', 'Foo'
    p 'className': 'foo', ['Foo']
  @param {Function} factory
  @return {function(*=, *=): React.ReactComponent}
  @private
###
este.react.improve = (factory) ->
  ###*
    @param {*=} arg1
    @param {*=} arg2
  ###
  (arg1, arg2) ->
    if !arguments.length
      return factory.call @

    props = arg1
    children = arg2
    if props?.constructor != Object
      props = null
      children = arg1

    if goog.isArray children
      goog.asserts.assertArray children
      children = goog.array.flatten children
      este.array.removeUndefined children

    factory.apply @, [props].concat children ? []