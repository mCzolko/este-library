###*
  @fileoverview Array utils.
###

goog.provide 'este.array'

goog.require 'goog.array'

goog.scope ->
  `var _ = este.array`

  ###*
    Removes all values that satisfies the given condition.
    @param {goog.array.ArrayLike} arr
    @param {Function} f The function to call for every element. This function
    takes 3 arguments (the element, the index and the array) and should
    return a boolean.
    @param {Object=} obj An optional "this" context for the function.
    @return {boolean} True if an element was removed.
  ###
  _.removeAllIf = (arr, f, obj) ->
    idx = arr.length
    removed = false
    while idx--
      continue if !f.call obj, arr[idx], idx, arr
      arr.splice idx, 1
      removed = true
    removed

  ###*
    Removes undefined values from array.
    @param {goog.array.ArrayLike} arr
  ###
  _.removeUndefined = (arr) ->
    _.removeAllIf arr, (item) -> item == undefined

  return