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
  @return {React.ReactComponent} Component instance rendered in container.
###
este.react.render = (component, container) ->
  React.renderComponent component, container

###*
 Render React component to string.
 @param {React.ReactComponent} component
 @param {function(S):?} callback
 @template S
###
este.react.renderToString = (component, callback) ->
 React.renderComponentToString component, callback

###*
  Unmount component at node
  @param {Element} container
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
  Allow to use this.h3 'Foo' instead of verbose React.DOM.h3 null, 'Foo'.
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
    if props.constructor != Object
      children = props
      props = null

    if goog.isArray children
      goog.asserts.assertArray children
      children = goog.array.flatten children
      este.array.removeUndefined children

    if children?
      factory.call @, props, children
    else
      factory.call @, props
