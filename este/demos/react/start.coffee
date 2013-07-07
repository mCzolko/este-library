###*
  @fileoverview Demo for Facebook React in Este.
###

goog.provide 'este.demos.react.start'

goog.require 'este.demos.react.todoApp'
goog.require 'este.react'

###*
  @param {string} selector
###
este.demos.react.start = (selector) ->

  todoApp = este.demos.react.todoApp()
  parentElement = document.querySelector selector
  este.react.render todoApp, parentElement

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.react.start', este.demos.react.start