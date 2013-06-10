suite 'este.events.EventHandler', ->

  EventHandler = este.events.EventHandler

  handler = null
  el = null

  setup ->
    handler = new EventHandler
    el = document.createElement 'div'

  teardown ->
    # TODO: removeAll
    EventHandler.handlers = {}

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf handler, EventHandler

  suite 'EventHandler.getHandlerClass', ->
    test 'should return null for non element', ->
      assert.isNull EventHandler.getHandlerClass {}, 'foo'

    test 'should return GestureHandler class for tap', ->
      handlerClass = EventHandler.getHandlerClass el, 'tap'
      assert.equal handlerClass, este.events.GestureHandler

    test 'should return SubmitHandler class for submit', ->
      handlerClass = EventHandler.getHandlerClass el, 'submit'
      assert.equal handlerClass, este.events.SubmitHandler

    test 'should return FocusHandler class for focusin', ->
      handlerClass = EventHandler.getHandlerClass el, 'focusin'
      assert.equal handlerClass, goog.events.FocusHandler

    test 'should return FocusHandler class for focusout', ->
      handlerClass = EventHandler.getHandlerClass el, 'focusout'
      assert.equal handlerClass, goog.events.FocusHandler

    test 'should return InputHandler class for input', ->
      handlerClass = EventHandler.getHandlerClass el, 'input'
      assert.equal handlerClass, goog.events.InputHandler

    test 'should return KeyHandler class for key', ->
      handlerClass = EventHandler.getHandlerClass el, 'key'
      assert.equal handlerClass, goog.events.KeyHandler

    test 'should return MouseWheelHandler class for mousewheel', ->
      handlerClass = EventHandler.getHandlerClass el, 'mousewheel'
      assert.equal handlerClass, goog.events.MouseWheelHandler

  suite 'listen', ->
    test 'should return instance for one type', ->
      result = handler.listen el, 'focusin', ->
      assert.equal result, handler

    test 'should return instance for more types', ->
      result = handler.listen el, ['focusin', 'focusout'], ->
      assert.equal result, handler

    suite 'focusin and focusout on the same element', ->
      test 'should create only one FocusHandler instance', ->
        handler.listen el, 'focusin', ->
        handler.listen el, 'focusout', ->
        count = goog.object.getCount este.events.EventHandler.handlers
        assert.equal count, 1
        instance = goog.object.getAnyValue este.events.EventHandler.handlers
        assert.instanceOf instance, goog.events.FocusHandler

    suite 'focusin and focusout on the same element with type as array', ->
      test 'should create only one FocusHandler instance', ->
        handler.listen el, ['focusin', 'focusout'], ->
        count = goog.object.getCount este.events.EventHandler.handlers
        assert.equal count, 1
        instance = goog.object.getAnyValue este.events.EventHandler.handlers
        assert.instanceOf instance, goog.events.FocusHandler

    suite 'focusin and focusout on different elements', ->
      test 'should create two FocusHandler instances', ->
        handler.listen el, 'focusin', ->
        handler.listen document.createElement('div'), 'focusout', ->
        count = goog.object.getCount este.events.EventHandler.handlers
        assert.equal count, 2

  suite 'unlisten focusin, focusout', ->
    test 'should dispose FocusHander', (done) ->
      onIn = ->
      onOut = ->
      handler.listen el, 'focusin', onIn
      handler.listen el, 'focusout', onOut
      focusHandler = goog.object.getAnyValue este.events.EventHandler.handlers
      focusHandler.dispose = ->
        count = goog.object.getCount este.events.EventHandler.handlers
        assert.equal count, 0
        done()
      handler.unlisten el, 'focusin', onIn
      handler.unlisten el, 'focusout', onOut