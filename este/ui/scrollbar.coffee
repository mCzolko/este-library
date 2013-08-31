###*
  @fileoverview OS X Mountain Lion style scrolling for web.

  Features:

  - designed with obsession for UX details
  - uses hidden native scrollbars to preserve native scroll momentum
  - very customizable
  - accessible: ARIA, keyboard
  - CSS3 animations
  - size of container can be dynamically adjusted and scrollbars will adapt
  - declarativeness, lazy instantiation on mouseenter
  - tested on: Chrome, Safari, Firefox, Internet Explorer 8+ (Mac, Win, iOS)

  TODO:

  - fix Mac Firefox on scroll overlay workaround.
  - fix IE jump when scrollbar is clicked or on mouseenter at first shown.
  - once IE<10 die, implement showTimeout and hideTimeout as CSS transition.

  @see /demos/ui/scrollbar.html
###
goog.provide 'este.ui.Scrollbar'
goog.provide 'este.ui.Scrollbar.lazyCreate'

goog.require 'este.dom'
goog.require 'este.events.Delegation'
goog.require 'este.ui.Component'
goog.require 'este.ui.InvisibleOverlay'
goog.require 'este.ui.userAgent'
goog.require 'goog.labs.userAgent.browser'
goog.require 'goog.labs.userAgent.platform'
goog.require 'goog.labs.userAgent.device'
goog.require 'goog.memoize'
goog.require 'goog.style'
goog.require 'goog.ui.Slider'

class este.ui.Scrollbar extends este.ui.Component

  ###*
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: ->
    super()

  ###*
    @enum {string}
  ###
  @ClassName:
    ELEMENT: 'este-scrollbar'
    CONTENT: 'este-scrollbar-content'
    SHOWN: 'este-scrollbar-shown'
    SHOWN_BG: 'este-scrollbar-shown-bg'

  ###*
    Just create <div class="whatever este-scrollbar">... element in DOM, and
    este.ui.Scrollbar will be created lazily on mouseenter.
  ###
  @lazyCreate: ->
    return if !goog.labs.userAgent.device.isDesktop()
    delegation = new este.events.Delegation document.documentElement, 'mouseover'
    delegation.targetFilter = (el) ->
      goog.dom.classlist.contains el, Scrollbar.ClassName.ELEMENT
    goog.events.listen delegation, 'mouseover', (e) ->
      return if e.target.hasAttribute 'e-ui-scrollbar'
      scrollbar = new este.ui.Scrollbar
      scrollbar.decorate e.target
      scrollbar.showScrollbarsTemporarily()

  ###*
    @return {number}
  ###
  @getNativeScrollbarWidth: goog.memoize goog.style.getScrollbarWidth

  ###*
    @type {number}
  ###
  hideTimeout: 750

  ###*
    @type {number}
  ###
  showTimeout: 75

  ###*
    @type {number}
  ###
  scrollTimeout: 250

  ###*
    Like Mac OS X.
    @type {boolean}
  ###
  showScrollbarsOnlyOnScroll: false

  ###*
    @type {?number}
    @protected
  ###
  hideTimer: null

  ###*
    @type {?number}
    @protected
  ###
  showTimer: null

  ###*
    @type {?number}
    @protected
  ###
  overlayScrollTimer: null

  ###*
    @type {?number}
    @protected
  ###
  contentScrollTimer: null

  ###*
    @type {Element}
    @protected
  ###
  content: null

  ###*
    Overlay temporarily shown on mousewheel over custom scrollbars.
    @type {Element}
    @protected
  ###
  overlay: null

  ###*
    @type {goog.ui.Slider}
    @protected
  ###
  verticalSlider: null

  ###*
    @type {goog.ui.Slider}
    @protected
  ###
  horizontalSlider: null

  ###*
    @type {boolean}
    @protected
  ###
  dragging: false

  ###*
    @type {number}
    @protected
  ###
  mouseClientX: 0

  ###*
    @type {number}
    @protected
  ###
  mouseClientY: 0

  ###*
    Show scrollbars temporarily.
  ###
  showScrollbarsTemporarily: ->
    return if !goog.labs.userAgent.device.isDesktop()
    return if @dragging
    @showScrollbars()
    @hideTimer = setTimeout goog.bind(@hideScrollbars, @), @hideTimeout

  ###*
    Update scrollbars position and size.
  ###
  update: ->
    return if !goog.labs.userAgent.device.isDesktop()
    @updateVerticalScrollBar()
    @updateHorizontalScrollBar()

  ###*
    @protected
  ###
  updateVerticalScrollBar: ->
    ratio = @content.clientHeight / @content.scrollHeight
    goog.style.setElementShown @verticalSlider.getElement(), ratio < 1
    return if ratio == 1

    goog.style.setHeight @verticalSlider.getValueThumb(),
      @content.clientHeight * ratio
    maximum = @content.scrollHeight - @content.clientHeight
    @verticalSlider.setMaximum maximum
    # Math.max because subpixeling can produce -1 value.
    @verticalSlider.setValue Math.max 0, maximum - @content.scrollTop

  ###*
    @protected
  ###
  updateHorizontalScrollBar: ->
    ratio = @content.clientWidth / @content.scrollWidth
    goog.style.setElementShown @horizontalSlider.getElement(), ratio < 1
    return if ratio == 1

    goog.style.setWidth @horizontalSlider.getValueThumb(),
      @content.clientWidth * ratio
    @horizontalSlider.setMaximum @content.scrollWidth - @content.clientWidth
    @horizontalSlider.setValue @content.scrollLeft

  ###*
    @override
  ###
  createDom: ->
    super()
    @setElementInternal @dom_.createDom 'div', Scrollbar.ClassName.ELEMENT,
      @dom_.createDom 'div', Scrollbar.ClassName.CONTENT
    @decorateInternal @getElement()
    return

  ###*
    @override
  ###
  decorateInternal: (element) ->
    super element
    element.setAttribute 'e-ui-scrollbar', true
    goog.dom.classlist.add @getElement(), Scrollbar.ClassName.ELEMENT
    @content = @getElementByClass Scrollbar.ClassName.CONTENT
    # Always set scrollbars to be visible to prevent scrollable content jumps.
    @content.style.overflow = 'scroll'
    return if !goog.labs.userAgent.device.isDesktop()
    @setContentRightAndBottomStyleToHideNativeScrollbars()
    @createSliders()
    return

  ###*
    @protected
  ###
  setContentRightAndBottomStyleToHideNativeScrollbars: ->
    offset = "-#{Scrollbar.getNativeScrollbarWidth()}px"
    @content.style.right = offset
    @content.style.bottom = offset

  ###*
    @protected
  ###
  createSliders: ->
    @verticalSlider = new goog.ui.Slider
    @verticalSlider.setOrientation goog.ui.Slider.Orientation.VERTICAL
    @verticalSlider.setMoveToPointEnabled true
    @verticalSlider.setHandleMouseWheel false
    @verticalSlider.setMinimum 0

    @horizontalSlider = new goog.ui.Slider
    @horizontalSlider.setOrientation goog.ui.Slider.Orientation.HORIZONTAL
    @horizontalSlider.setMoveToPointEnabled true
    @horizontalSlider.setHandleMouseWheel false
    @horizontalSlider.setMinimum 0

    @addChild @verticalSlider, true
    @addChild @horizontalSlider, true
    return

  ###*
    @override
  ###
  enterDocument: ->
    super()
    return if !goog.labs.userAgent.device.isDesktop()
    @update()
    @on @getElement(), ['mouseover', 'mouseout'], @onElementMouseOverOut
    @on @content, 'scroll', @onContentScroll
    @on @verticalSlider, 'change', @onVerticalSliderChange
    @on @horizontalSlider, 'change', @onHorizontalSliderChange
    @on @verticalSlider, goog.ui.SliderBase.EventType.DRAG_VALUE_START, @onDragStart
    @on @verticalSlider, goog.ui.SliderBase.EventType.DRAG_VALUE_END, @onDragEnd
    @on @horizontalSlider, goog.ui.SliderBase.EventType.DRAG_VALUE_START, @onDragStart
    @on @horizontalSlider, goog.ui.SliderBase.EventType.DRAG_VALUE_END, @onDragEnd
    @on '.goog-slider-vertical', 'mouseover', @onGoogSliderMouseEnter
    @on '.goog-slider-vertical', 'mouseout', @onGoogSliderMouseLeave
    @on '.goog-slider-horizontal', 'mouseover', @onGoogSliderMouseEnter
    @on '.goog-slider-horizontal', 'mouseout', @onGoogSliderMouseLeave

    # TODO: Try fix Firefox, it needs real mouse move.
    isMacFirefox =
      goog.labs.userAgent.platform.isMacintosh() &&
      goog.labs.userAgent.browser.isFirefox()
    isIeLess9 =
      goog.labs.userAgent.browser.isIE() &&
      !goog.labs.userAgent.browser.isVersionOrHigher 9
    overlayScrollTrickDoesNotWork =
      isMacFirefox || isIeLess9
    if !overlayScrollTrickDoesNotWork
      @on '.goog-slider-vertical', 'mousewheel', @onSliderMouseWheel
      @on '.goog-slider-horizontal', 'mousewheel', @onSliderMouseWheel
    return

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onElementMouseOverOut: (e) ->
    return if este.dom.isMouseHoverEventWithinElement e, @getElement()
    return if @overlay
    switch e.type
      when 'mouseover'
        return if @showScrollbarsOnlyOnScroll
        @showScrollbarsTemporarily()
      when 'mouseout'
        @hideScrollbars()
    return

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onContentScroll: (e) ->
    if !@isAnyScrollbarBackgroundShown()
      @showScrollbarsTemporarily()
    return if @dragging ||
      @verticalSlider.isAnimating() ||
      @horizontalSlider.isAnimating()

    @off @verticalSlider, 'change', @onVerticalSliderChange
    @off @horizontalSlider, 'change', @onHorizontalSliderChange
    clearTimeout @contentScrollTimer
    @contentScrollTimer = setTimeout =>
      @on @verticalSlider, 'change', @onVerticalSliderChange
      @on @horizontalSlider, 'change', @onHorizontalSliderChange
    , @scrollTimeout
    @update()

  ###*
    @protected
    @return {boolean}
  ###
  isAnyScrollbarBackgroundShown: ->
    @isVerticalScrollbarBackgroundShown() ||
    @isHorizontalScrollbarBackgroundShown()

  ###*
    @protected
    @return {boolean}
  ###
  isVerticalScrollbarBackgroundShown: ->
    goog.dom.classlist.contains @verticalSlider.getElement(),
      Scrollbar.ClassName.SHOWN_BG

  ###*
    @protected
    @return {boolean}
  ###
  isHorizontalScrollbarBackgroundShown: ->
    goog.dom.classlist.contains @horizontalSlider.getElement(),
      Scrollbar.ClassName.SHOWN_BG

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onGoogSliderMouseEnter: (e) ->
    return if @overlay
    clearTimeout @showTimer
    @showTimer = setTimeout =>
      @showScrollbars()
      target = (`/** @type {Element} */`) e.target
      @setScrollbarsClassesEnabled true,
        goog.dom.classlist.contains target, 'goog-slider-vertical'
        goog.dom.classlist.contains target, 'goog-slider-horizontal'
      @on '.goog-slider-vertical', 'mouseout', @onGoogSliderActiveMouseLeave
      @on '.goog-slider-horizontal', 'mouseout', @onGoogSliderActiveMouseLeave
    , @showTimeout

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onGoogSliderActiveMouseLeave: (e) ->
    return if @overlay
    @off '.goog-slider-vertical', 'mouseout', @onGoogSliderActiveMouseLeave
    @off '.goog-slider-horizontal', 'mouseout', @onGoogSliderActiveMouseLeave
    @hideScrollbars()

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onGoogSliderMouseLeave: (e) ->
    clearTimeout @showTimer

  ###*
    @param {goog.events.Event} e
    @protected
  ###
  onVerticalSliderChange: (e) ->
    scrollTop = @verticalSlider.getMaximum() - @verticalSlider.getValue()
    @content.scrollTop = scrollTop

  ###*
    @param {goog.events.Event} e
    @protected
  ###
  onHorizontalSliderChange: (e) ->
    @content.scrollLeft = @horizontalSlider.getValue()

  ###*
    @param {goog.events.Event} e
    @protected
  ###
  onDragStart: (e) ->
    @dragging = true
    @setMouseTrackingEnabled true

  ###*
    @param {goog.events.Event} e
    @protected
  ###
  onDragEnd: (e) ->
    @dragging = false
    @setMouseTrackingEnabled false
    @hideScrollbarsIfMouseIsOutOfThem()

  ###*
    @protected
  ###
  showScrollbars: ->
    return if @dragging
    clearTimeout @hideTimer
    @setScrollbarsClassesEnabled true,
      @isVerticalScrollbarBackgroundShown(),
      @isHorizontalScrollbarBackgroundShown()

  ###*
    @protected
  ###
  hideScrollbars: ->
    return if @dragging
    clearTimeout @hideTimer
    @setScrollbarsClassesEnabled false

  ###*
    @param {boolean} enable
    @param {boolean=} verticalBg
    @param {boolean=} horizontalBg
    @protected
  ###
  setScrollbarsClassesEnabled: (enable, verticalBg, horizontalBg) ->
    goog.dom.classlist.enable @verticalSlider.getElement(),
      Scrollbar.ClassName.SHOWN, enable
    goog.dom.classlist.enable @horizontalSlider.getElement(),
      Scrollbar.ClassName.SHOWN, enable
    goog.dom.classlist.enable @verticalSlider.getElement(),
      Scrollbar.ClassName.SHOWN_BG, verticalBg || false
    goog.dom.classlist.enable @horizontalSlider.getElement(),
      Scrollbar.ClassName.SHOWN_BG, horizontalBg || false

  ###*
    @param {boolean} enable
    @protected
  ###
  setMouseTrackingEnabled: (enable) ->
    if enable
      @on document, 'mousemove', @onDocumentMouseMove
    else
      @off document, 'mousemove', @onDocumentMouseMove

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onDocumentMouseMove: (e) ->
    @mouseClientX = e.clientX
    @mouseClientY = e.clientY

  ###*
    @protected
  ###
  hideScrollbarsIfMouseIsOutOfThem: ->
    el = @dom_.getDocument().elementFromPoint @mouseClientX, @mouseClientY
    isElementWithinScrollbars =
      goog.dom.contains(@verticalSlider.getElement(), el) ||
      goog.dom.contains(@horizontalSlider.getElement(), el)
    return if isElementWithinScrollbars
    @hideScrollbars()

  ###*
    This handler ensures native mousewheel scroll behavior even on custom
    scrollbars. It creates invisible overlay over scrollable content on first
    mousewheel event and hide it after scroll end.
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onSliderMouseWheel: (e) ->
    if !@overlay
      @createOverlay()
      @content.appendChild @overlay
      @setMouseTrackingEnabled true
      @on @content, 'scroll', @onContentScrollWhenOverlayIsShown
      @onContentScrollWhenOverlayIsShown()
    # Fixes horizontal scroll overlay (Mac Chrome, who else?).
    e.preventDefault()

  ###*
    @protected
  ###
  createOverlay: ->
    @overlay = @dom_.createDom 'div', style: "
      position: absolute;
      z-index: 2147483647;
      left: 0; top: 0;
      width: #{@content.scrollWidth}px;
      height: #{@content.scrollHeight}px;
      background-color: #000;
      opacity: 0;
    "

  ###*
    @param {goog.events.BrowserEvent=} e
    @protected
  ###
  onContentScrollWhenOverlayIsShown: (e) ->
    clearTimeout @overlayScrollTimer
    @overlayScrollTimer = setTimeout =>
      return if !@overlay
      @content.removeChild @overlay
      @overlay = null
      @setMouseTrackingEnabled false
      @off @content, 'scroll', @onContentScrollWhenOverlayIsShown
      @hideScrollbarsIfMouseIsOutOfThem()
    , @scrollTimeout