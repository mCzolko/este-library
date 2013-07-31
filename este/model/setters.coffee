###*
  @fileoverview Setters for este.Model
  @namespace este.model.setters
###
goog.provide 'este.model.setters'

goog.require 'goog.string'

###*
  @param {string} value
  @return {string}
###
este.model.setters.trim = (value) ->
  goog.string.trim value