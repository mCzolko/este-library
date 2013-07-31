###*
  @fileoverview Wrapper for goog.json using native implementation where
  available. Use compiler define to strip code for IE6/7.
  @namespace este.json
###

goog.provide 'este.json'

goog.require 'goog.json'

###*
 @define {boolean} Whether native JSON is supported.
###
goog.define 'este.json.SUPPORTS_NATIVE_JSON', false

###*
  @param {*} object The object to serialize.
  @return {string} A JSON string representation of the input.
###
este.json.stringify = (object) ->
  if este.json.nativeJsonIsSupported()
    return goog.global['JSON'].stringify object
  goog.json.serialize object

###*
  @param {string} str The JSON string to parse.
  @return {Object} The object generated from the JSON string.
###
este.json.parse = (str) ->
  if este.json.nativeJsonIsSupported()
    return goog.global['JSON'].parse str
  goog.json.parse str

###*
  @return {boolean}
###
este.json.nativeJsonIsSupported = ->
  este.json.SUPPORTS_NATIVE_JSON || goog.global['JSON']

###*
  @param {*} a
  @param {*} b
  @return {boolean}
###
este.json.equal = (a, b) ->
  este.json.stringify(a) == este.json.stringify(b)