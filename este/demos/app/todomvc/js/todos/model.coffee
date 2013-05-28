###*
  @fileoverview Model representing one todo.
###
goog.provide 'este.demos.app.todomvc.todos.Model'

goog.require 'este.Model'

class este.demos.app.todomvc.todos.Model extends este.Model

  ###*
    @param {Object=} json
    @constructor
    @extends {este.Model}
  ###
  constructor: (json) ->
    super json

  ###*
    @override
  ###
  url: '/todos'

  ###*
    @override
  ###
  defaults:
    'title': ''
    'completed': false
    'editing': false

  ###*
    @override
  ###
  schema:
    'title':
      'set': este.model.setters.trim
      'validators': [
        este.validators.required()
      ]

  toggleCompleted: ->
    @set 'completed', !@get 'completed'