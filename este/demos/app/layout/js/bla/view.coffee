###*
  @fileoverview este.demos.app.layout.bla.View.
###
goog.provide 'este.demos.app.layout.bla.View'

goog.require 'este.app.View'
goog.require 'este.demos.app.layout.bla.templates'

class este.demos.app.layout.bla.View extends este.app.View

  ###*
    @constructor
    @extends {este.app.View}
  ###
  constructor: ->
    super()

  ###*
    @override
  ###
  enterDocument: ->
    super()
    @on 'div', 'click', @onDivClick
    return

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onDivClick: (e) ->
    alert '.este-content clicked'

  ###*
    @override
  ###
  update: ->
    @getElement().innerHTML = este.demos.app.layout.bla.templates.element()
    return