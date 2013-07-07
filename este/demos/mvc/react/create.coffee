###*
  @fileoverview Factory for este.demos.mvc.react.Component.
###
goog.provide 'este.demos.mvc.react.create'

goog.require 'este.demos.mvc.react.Collection'
goog.require 'este.demos.mvc.react.Component'

###*
  @param {string} selector
  @return {este.demos.mvc.react.Component}
###
este.demos.mvc.react.create = (selector) ->
  # Let's make todos model collection.
  todos = new este.demos.mvc.react.Collection
  # Inject it into todos view.
  component = new este.demos.mvc.react.Component todos
  # Get an element for UI component then render.
  element = document.querySelector selector
  component.render element
  # Return rendered component.
  component