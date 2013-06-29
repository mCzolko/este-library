###*
  @fileoverview Custom component based on React.
###
goog.provide 'este.demos.ui.reactcomponent.CustomComponent'

goog.require 'este.ui.ReactComponent'

class este.demos.ui.reactcomponent.CustomComponent extends este.ui.ReactComponent

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