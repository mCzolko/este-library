###*
  @fileoverview este.demos.dom.merge.react.
###
goog.provide 'este.demos.dom.merge.react'

goog.require 'este.react'

este.demos.dom.merge.react = este.react.create (`/** @lends {React.ReactComponent.prototype} */`)

  getInitialState: ->
    'name': @props['name']
    'description': @props['description']

  render: ->
    @form 'onKeyUp': @onFormKeyUp, [
      @label [
        'name', @br()
        @input
          'name': 'name'
          'placeholder': 'Joe'
          'value': @state['name']
        @span '*' if !@state['name']
      ]
      @label [
        'description', @br()
        @textarea
          'name': 'description'
          'style':
            'fontSize': "#{@state['description'].length}px"
        , @state['description']
      ]
    ]

  onFormKeyUp: (e) ->
    state = {}
    state[e.target.name] = e.target.value
    @setState state