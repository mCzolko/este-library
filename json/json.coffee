###*
  @fileoverview Wrapper for goog.json using native implementation where
  available. Use compiler define to strip code for IE6/7.
###

goog.provide 'este.json'

goog.require 'goog.json'

###*
 @define {boolean} Whether native JSON is supported.
###
goog.define 'este.json.SUPPORTS_NATIVE_JSON', false

goog.scope ->
  `var _ = este.json`

  ###*
    @param {*} object The object to serialize.
    @return {string} A JSON string representation of the input.
  ###
  _.stringify = (object) ->
    if _.nativeJsonIsSupported()
      return goog.global['JSON'].stringify object
    goog.json.serialize object

  ###*
    @param {string} str The JSON string to parse.
    @return {Object} The object generated from the JSON string.
  ###
  _.parse = (str) ->
    if _.nativeJsonIsSupported()
      return goog.global['JSON'].parse str
    goog.json.parse str

  ###*
    @return {boolean}
  ###
  _.nativeJsonIsSupported = ->
    este.json.SUPPORTS_NATIVE_JSON || goog.global['JSON']

  ###*
    @param {*} a
    @param {*} b
    @return {boolean}
  ###
  _.equal = (a, b) ->
    _.stringify(a) == _.stringify(b)

  return