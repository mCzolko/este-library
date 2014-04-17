###*
  @fileoverview For urls matching, parsing, and creating.
###

goog.provide 'este.Route'

class este.Route

  ###*
    @param {string} path Express-style path string such as /user/:name
    @constructor
    @final
  ###
  constructor: (@path) ->
    @keys = []
    @createRegExp_()

  ###*
    @type {Array.<Object>}
    @private
  ###
  keys: null

  ###*
    @type {RegExp}
    @private
  ###
  regexp: null

  ###*
    @param {string} url
    @return {boolean}
  ###
  match: (url) ->
    !!@getMatches_ url

  ###*
    @param {string} url
    @return {Object}
  ###
  getParams: (url) ->
    params = null
    matches = @getMatches_ url
    return params if !matches

    for match, i in matches
      continue if !i
      key = @keys[i - 1]
      value = if typeof(match) == 'string'
        @decodeMatch_ match
      else
        match
      if key
        params ?= {}
        params[key.name] = value
      else
        params ?= []
        params.push value
    params

  ###*
    @param {(Object|Array)} params
    @return {string}
  ###
  createUrl: (params) ->
    url = if Array.isArray params
      index = 0
      @path.replace /\*/g, -> params[index++]
    else
      path = @path
      for key, value of params
        value = '' if value == undefined
        regex = new RegExp "\\:#{key}\\??"
        path = path.replace regex, value
      path.replace /\:[^\/]*/g, ''

    @ensureUrlHasNoTrailingSlashOrDot_ url

  ###*
    @param {string} url
    @return {Array.<string>}
    @private
  ###
  getMatches_: (url) ->
    index = url.indexOf '?'
    pathname = if index > -1 then url.slice(0, index) else url
    @regexp.exec pathname

  ###*
    @param {string} str
    @return {string}
    @private
  ###
  decodeMatch_: (str) ->
    try
      return decodeURIComponent str
    catch e
    str

  ###*
    Remove trailing slash and dot from url.
    @private
  ###
  ensureUrlHasNoTrailingSlashOrDot_: (url) ->
    return url if url.length < 2
    url.replace /[.\/]+$/g, ''

  ###*
    @private
  ###
  createRegExp_: ->
    path = @path
      .concat '/?'
      .replace /([\/\.])/g, '\\$1'
      .replace /(\\\/)?(\\\.)?:(\w+)(\(.*?\))?(\*)?(\?)?/g, @replacer_.bind @
      .replace /\*/g, '(.*)'
    @regexp = new RegExp "^#{path}$", 'i'

  ###*
    @private
  ###
  replacer_: (match, slash, format, key, capture, star, optional) ->
    slash = slash || ''
    format = format || ''
    capture = capture || '([^/' + format + ']+?)'
    optional = optional || ''

    @keys.push name: key, optional: !!optional

    (if optional then '' else slash) +
    '(?:' +
    format + (if optional then slash else '') + capture +
    (if star then '((?:[\\/' + format + '].+?)?)' else '') +
    ')' +
    optional