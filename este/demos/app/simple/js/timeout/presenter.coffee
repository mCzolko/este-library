###*
  @fileoverview este.demos.app.simple.timeout.Presenter.
###
goog.provide 'este.demos.app.simple.timeout.Presenter'

goog.require 'este.app.Presenter'

class este.demos.app.simple.timeout.Presenter extends este.app.Presenter

  ###*
    @constructor
    @extends {este.app.Presenter}
  ###
  constructor: ->
    super()

  ###*
    @override
  ###
  load: (params) ->
    # async simulation
    result = new goog.result.SimpleResult
    setTimeout ->
      result.setValue null
    , 12000
    result