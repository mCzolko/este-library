###*
  @fileoverview Factory for este.demos.mvc.closureTemplates.Component.
###
goog.provide 'este.demos.mvc.closureTemplates.create'

goog.require 'este.demos.mvc.closureTemplates.Collection'
goog.require 'este.demos.mvc.closureTemplates.Component'

###*
  @param {string} selector
  @return {este.demos.mvc.closureTemplates.Component}
###
este.demos.mvc.closureTemplates.create = (selector) ->
  # Let's make todos model collection.
  todos = new este.demos.mvc.closureTemplates.Collection
  # Inject it into todos view.
  component = new este.demos.mvc.closureTemplates.Component todos
  # Get an element for UI component then render.
  element = document.querySelector selector
  component.render element
  # Return rendered component.
  component