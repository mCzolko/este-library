###*
  @fileoverview Collection representing list of todos models.
###
goog.provide 'este.demos.mvc.closureTemplates.Collection'

goog.require 'este.demos.mvc.closureTemplates.Model'
goog.require 'este.Collection'

class este.demos.mvc.closureTemplates.Collection extends este.Collection

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
  model: este.demos.mvc.closureTemplates.Model