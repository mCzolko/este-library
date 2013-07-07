###*
  @fileoverview Demo for Facebook React in Este.
###

goog.provide 'este.demos.react.start'

goog.require 'este.demos.react.todoApp'
goog.require 'este.react'

este.demos.react.start = ->

  todoApp = este.demos.react.todoApp()
  parentElement = document.querySelector '#component'
  este.react.render todoApp, parentElement

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.react.start', este.demos.react.start