###*
  @fileoverview este.demos.app.simple.products.list.Presenter.
###
goog.provide 'este.demos.app.simple.products.list.Presenter'

goog.require 'este.app.Presenter'
goog.require 'este.demos.app.simple.products.Collection'
goog.require 'este.demos.app.simple.products.list.View'

class este.demos.app.simple.products.list.Presenter extends este.app.Presenter

  ###*
    @constructor
    @extends {este.app.Presenter}
  ###
  constructor: ->
    super()
    seedJsonData = [
      'id': 0
      'name': 'Product A'
      'description': 'A description...'
    ,
      'id': 1
      'name': 'Product B'
      'description': 'B description...'
    ,
      'id': 2
      'name': 'Product C'
      'description': 'C description...'
    ]
    @products = new este.demos.app.simple.products.Collection seedJsonData
    @view = new este.demos.app.simple.products.list.View @products

  ###*
    @override
  ###
  load: (params) ->
    # async simulation
    result = new goog.result.SimpleResult
    setTimeout ->
      result.setValue null
    , 1000
    result

  ###*
    @override
  ###
  disposeInternal: ->
    super()
    @products.dispose()
    return
