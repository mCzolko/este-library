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

  _.hideAddressBar = ->
    # from jQuery Mobile jquery.mobile.init.js
    window.scrollTo 0, 1
    if goog.dom.getDocumentScroll().y == 1
      _.defaultHomeScroll = 0

    setTimeout ->
      window.scrollTo 0, 1
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
  ###
  _.iosVersion = parseFloat(
    ('' + (/CPU.*OS ([0-9_]{1,5})|(CPU like).*AppleWebKit.*Mobile/i.
      exec(navigator.userAgent) || [0,''])[1]).
        replace('undefined', '3_2').
        replace('_', '.').
        replace('_', '')) || false

  # emulate first feature http://taptaptap.com/blog/10-useful-iphone-tips-and-tricks/
  # function tapToTop(scrollableElement) {
  #   var currentOffset = scrollableElement.scrollTop

  #   // Animate to position 0 with a transform.
  #   scrollableElement.style.webkitTransition =
  #       '-webkit-transform 300ms ease-out';
  #   scrollableElement.addEventListener(
  #       'webkitTransitionEnd', onAnimationEnd, false);
  #   scrollableElement.style.webkitTransform =
  #       'translate3d(0, ' + (-currentOffset) +'px,0)';

  #   function onAnimationEnd() {
  #     // Animation is complete, swap transform with
  #     // change in scrollTop after removing transition.
  #     scrollableElement.style.webkitTransition = 'none';
  #     scrollableElement.style.webkitTransform =
  #         'translate3d(0,0,0)';
  #     scrollableElement.scrollTop = 0;
  #   }
  # }

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
    Based on jQuery Mobile fix for fixed headers. Refactored to fix all fixed
    positioned elements.
  ###
  _.hideFixedPositionedOnFocus = ->
    showTimer = undefined
    hideTimer = undefined
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