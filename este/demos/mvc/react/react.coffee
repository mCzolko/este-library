###*
  @fileoverview este.demos.mvc.react.react.
###
goog.provide 'este.demos.mvc.react.react'

goog.require 'este.react'

este.demos.mvc.react.react = este.react.create (`/** @lends {React.ReactComponent.prototype} */`)

  render: ->
    @div [
      @form 'className': 'new-todo', [
        @input
          'name': 'title'
          'autofocus': true
          'placeholder': @props['placeholder']
        @button @props['addButtonLabel']
      ]
      @ul @props['todos'].map (todo) =>
        @li todo['title']
    ]