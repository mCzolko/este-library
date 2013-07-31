###*
  @fileoverview Getters for este.Model
  @namespace este.model.getters
###
goog.provide 'este.model.getters'

goog.require 'goog.string'

###*
  @param {string} value
  @return {number}
###
este.model.getters.parseInt = (value) ->
  parseInt value, 10