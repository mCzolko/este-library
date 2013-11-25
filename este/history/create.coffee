###*
  @fileoverview Factory for concrete Closure history implementation with
  TokenTransformer fix for Html5History.
###

goog.provide 'este.history.create'

goog.require 'este.history.TokenTransformer'
goog.require 'goog.History'
goog.require 'goog.history.Html5History'
goog.require 'goog.labs.userAgent.platform'

###*
  @return {(goog.History|goog.history.Html5History)}
###
este.history.create = ->
  if este.history.isHtml5Supported()
    transformer = new este.history.TokenTransformer()
    new goog.history.Html5History undefined, transformer
  else
    new goog.History

###*
  http://caniuse.com/#search=pushstate
  @return {boolean}
###
este.history.isHtml5Supported = ->
  platform = goog.labs.userAgent.platform
  if platform.isIos()
    platform.isVersionOrHigher 5
  else if platform.isAndroid()
    platform.isVersionOrHigher 4.2
  else
    goog.history.Html5History.isSupported()