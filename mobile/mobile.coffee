goog.provide 'este.mobile'

goog.require 'goog.dom'
goog.require 'goog.events.FocusHandler'
goog.require 'goog.style'
goog.require 'goog.userAgent'
goog.require 'goog.userAgent.platform'
goog.require 'goog.userAgent.product.isVersion'

goog.scope ->
  `var _ = este.mobile`

  ###*
    @type {number}
  ###
  _.defaultHomeScroll = 1

  # See songary @media screen orientations, hardcoded sizes should ensure that
  # address bar can be always hidden.
  _.hideAddressBar = ->
    # from jQuery Mobile jquery.mobile.init.js
    window.scrollTo 0, 1
    if goog.dom.getDocumentScroll().y == 1
      _.defaultHomeScroll = 0
    setTimeout ->
      window.scrollTo 0, _.defaultHomeScroll
    , 0

  if goog.userAgent.MOBILE
    _.tapEvent = 'touchstart'
  else
    _.tapEvent = 'mousedown'

  ###*
    https://gist.github.com/2829457
    Outputs a float representing the iOS version if user is using an iOS browser i.e. iPhone, iPad
    Possible values include:
      3 - v3.0
      4.0 - v4.0
      4.14 - v4.1.4
      false - Not iOS
    NOTE: Wait for new Closure labs userAgent.
  ###
  _.iosVersion = parseFloat(
    ('' + (/CPU.*OS ([0-9_]{1,5})|(CPU like).*AppleWebKit.*Mobile/i.
      exec(navigator.userAgent) || [0,''])[1]).
        replace('undefined', '3_2').
        replace('_', '.').
        replace('_', '')) || false

  ###*
    Adds basic iPhone home icon link to the head
    @param {string} url
  ###
  _.addiPhoneAppIcon = (url) ->
    link = document.createElement 'link'
    link.rel = 'apple-touch-icon'
    link.href = url
    document.head.appendChild link

  ###*
    Hide all fixed positioned elements on focus, because fixed positioned
    elements are not updated, when mobile is in edit mode, e.g. keyboard is
    shown. Based on jQuery Mobile code, except it is more general, since all
    fixed positioned elements are hidden.
  ###
  _.hideFixedPositionedOnFocus = ->
    showTimer = null
    hideTimer = null
    isVisible = true
    handler = new goog.events.FocusHandler document.body

    toggleFixedDisplay = (shown) ->
      for el in document.body.getElementsByTagName '*'
        continue if goog.style.getComputedPosition(el) != 'fixed'
        goog.style.setElementShown el, shown
      return

    goog.events.listen handler, ['focusin', 'focusout'], (e) ->
      return if e.target.tagName not in ['INPUT', 'TEXTAREA', 'SELECT']
      if e.type == 'focusout' && !isVisible
        isVisible = true
        clearTimeout hideTimer
        showTimer = setTimeout ->
          toggleFixedDisplay true
        , 0
      else if e.type == 'focusin' && !!isVisible
        clearTimeout showTimer
        isVisible = false
        hideTimer = setTimeout ->
          toggleFixedDisplay false
        , 0
      return

  return