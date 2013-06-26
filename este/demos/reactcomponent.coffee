###*
  @fileoverview Experimental demo for este.ui.ReactComponent.
###

goog.provide 'este.demos.reactcomponent.start'

goog.require 'este.dev.Monitor.create'
goog.require 'este.Model'
goog.require 'este.ui.ReactComponent'

este.demos.reactcomponent.start = ->

  # shows total registered listeners count in bottom right corner
  if goog.DEBUG
    este.dev.Monitor.create()

  model = new este.Model 'count': 0
  component = new este.demos.reactcomponent.CustomComponent model
  component.render document.querySelector '#component'

  setInterval ->
    count = model.get 'count'
    model.set 'count', ++count
  , 1000

  # TODO: wait for React api update
  # document.querySelector('#dispose').onclick = ->
  #   component.dispose()

class este.demos.reactcomponent.CustomComponent extends este.ui.ReactComponent

  ###*
    @constructor
    @extends {este.ui.ReactComponent}
  ###
  constructor: (model) ->
    super model

  ###*
    @override
  ###
  registerEvents: ->
    @on 'li', 'click', @onLiClick

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onLiClick: (e) ->
    alert e.target.innerHTML

  ###*
    @override
  ###
  template: ->
    @el 'div', [
      @el 'h1', 'This is React!'
      "Count: #{@model.get 'count'}"
      @el 'br'
      @el 'ul', do => @el 'li', i for i in [1, 2, 3, 4]
    ]