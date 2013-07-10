###*
  @fileoverview este.react.
###
goog.provide 'este.react'
goog.provide 'este.react.create'
goog.provide 'este.react.render'

goog.require 'este.array'
goog.require 'este.thirdParty.react'
goog.require 'goog.asserts'
goog.require 'goog.object'

goog.scope ->
  `var _ = este.react`

  ###*
    Creates React factory with mixined template sugar methods. It allows us to
    use "this.h3 'Foo'" instead of verbose "React.DOM.h3 null, 'Foo'".
    @param {Object} proto
    @return {function(*=, *=): React.ReactComponent}
  ###
  _.create = (proto) ->
    _.syntaxSugarize proto
    factory = React.createClass (`/** @lends {React.ReactComponent.prototype} */`) proto
    _.improve factory

  ###*
    Render React component.
    @param {React.ReactComponent} component
    @param {Element} container
    @return {React.ReactComponent} Component instance rendered in container.
  ###
  _.render = (component, container) ->
    React.renderComponent component, container

  ###*
    Copy React.DOM methods into React component prototype.
    @param {Object} proto
    @private
  ###
  _.syntaxSugarize = (proto) ->
    for tag, factory of React.DOM
      continue if !goog.isFunction factory
      proto[tag] = _.improve factory
    return

  ###*
    Allow to use this.h3 'Foo' instead of verbose React.DOM.h3 null, 'Foo'.
    Autobind methods.
    @param {Function} factory
    @return {function(*=, *=): React.ReactComponent}
    @private
  ###
  _.improve = (factory) ->
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

      if props
        goog.asserts.assertObject props
        props = _.bindHandlers props, @

      if goog.isArray children
        goog.asserts.assertArray children
        children = goog.array.flatten children
        este.array.removeUndefined children

      if children?
        factory.call @, props, children
      else
        factory.call @, props

  ###*
    @param {Object} props
    @param {*} context
    @private
  ###
  _.bindHandlers = (props, context) ->
    goog.object.map props, (value, key) ->
      if goog.isFunction value
        value = goog.bind value, context
      value

  return