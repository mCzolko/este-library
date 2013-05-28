###*
  @fileoverview este.demos.app.simple.error.Presenter.
###
goog.provide 'este.demos.app.simple.error.Presenter'

goog.require 'este.app.Presenter'

class este.demos.app.simple.error.Presenter extends este.app.Presenter

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
      result.setError null
    , 3000
    result