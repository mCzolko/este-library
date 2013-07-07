###*
  @fileoverview Collection representing list of todos models.
###
goog.provide 'este.demos.mvc.react.Collection'

goog.require 'este.demos.mvc.react.Model'
goog.require 'este.Collection'

class este.demos.mvc.react.Collection extends este.Collection

  ###*
    @param {Array=} array We can fulfil collection with plain array of JSONs.
    @constructor
    @extends {este.Collection}
  ###
  constructor: (array) ->
    super array

  ###*
    @override
  ###
  model: este.demos.mvc.react.Model