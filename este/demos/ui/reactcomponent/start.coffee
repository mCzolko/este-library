###*
  @fileoverview Demo for este.ui.ReactComponent.
###

goog.provide 'este.demos.ui.reactcomponent.start'

goog.require 'este.demos.ui.reactcomponent.CustomComponent'
goog.require 'este.dev.Monitor.create'
goog.require 'este.Model'

este.demos.ui.reactcomponent.start = ->

  # shows total registered listeners count in bottom right corner
  if goog.DEBUG
    este.dev.Monitor.create()

  model = new este.Model 'count': 0
  component = new este.demos.ui.reactcomponent.CustomComponent model
  component.render document.querySelector '#component'

  setInterval ->
    count = model.get 'count'
    model.set 'count', ++count
  , 1000

  # TODO: wait for React api update
  # document.querySelector('#dispose').onclick = ->
  #   component.dispose()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.ui.reactcomponent.start', este.demos.ui.reactcomponent.start