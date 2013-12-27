suite 'este.labs.app.PagesContainer', ->

  PagesContainer = este.labs.app.PagesContainer

  container = null
  containerElement = null
  reactRender = null
  controller = null
  data = null

  setup ->
    containerElement = arrangeContainerElement()
    reactRender = ->
    container = arrangeContainer()
    controller = arrangeController()
    data = [1, 2]

  arrangeContainerElement = ->
    appendChild: ->
    removeChild: ->

  arrangeContainer = ->
    container = new PagesContainer containerElement, reactRender

  arrangeController = ->
    reactClass: -> arrangeReact()
    onShow: ->
    onHide: ->

  arrangeReact = ->
    toString: -> 'react'
    getDOMNode: -> 'node'
    setProps: ->

  suite 'show', ->
    suite 'not yet rendered controller', ->
      test 'should create React instance with passed data', ->
        controller.reactClass = (p_data) ->
          assert.deepEqual p_data, data
          arrangeReact()
        container.show controller, data
        assert.equal controller.react.toString(), 'react'

      test 'should mix controller handlers', ->
        controller.handlers = foo: -> @
        controller.reactClass = (p_data) ->
          assert.notEqual p_data, data
          assert.isFunction p_data.foo
          # Should not modify data.
          assert.isUndefined data.foo
          # Should set context to controller.
          assert.equal p_data.foo(), controller
        container.show controller, data

      test 'should render React instance', (done) ->
        reactRender = (component, parent, onComplete) ->
          assert.equal component.toString(), 'react'
          assert.equal parent, containerElement
          onShowCalled = false
          controller.onShow = -> onShowCalled = true
          onComplete()
          assert.equal controller.reactElement, 'node'
          assert.isTrue onShowCalled
          done()
        container = arrangeContainer()
        container.show controller, data

    suite 'next controller', ->
      test 'should remove previous controller react element', (done) ->
        controller.reactElement = 1
        container.show controller, data
        nextController = arrangeController()
        containerElement.removeChild = (element) ->
          assert.equal element, 1
          done()
        container.show nextController

      test 'should call onHide on previous controller', (done) ->
        controller.onHide = -> done()
        container.show controller, data
        nextController = arrangeController()
        container.show nextController

      test 'should append controller react element if react is truthy', (done) ->
        container.show controller, data
        nextController = arrangeController()
        nextController.react = arrangeReact()
        nextController.reactElement = 'foo'
        containerElement.appendChild = (element) ->
          assert.equal element, 'foo'
          done()
        container.show nextController

    suite 'the same controller twice', ->
      test 'should not remove previous controller react element', ->
        container.show controller, data
        removeChildCalled = false
        containerElement.removeChild = -> removeChildCalled = true
        container.show controller, data
        assert.isFalse removeChildCalled

      test 'should not call onHide on previous controller', ->
        container.show controller, data
        onHideCalled = false
        controller.onHide = -> onHideCalled = true
        container.show controller
        assert.isFalse onHideCalled

    suite 'yet rendered controller', ->
      test 'should call setProps with data and onShow', ->
        container.show controller, data
        container.show arrangeController(), data
        onShowCalled = false
        controller.onShow = -> onShowCalled = true
        controller.react =
          setProps: (p_data, onComplete) ->
            assert.equal p_data, data
            onComplete()
        container.show controller, data
        assert.isTrue onShowCalled

      test 'should not call onShow on same controller', ->
        container.show controller, data
        onShowCalled = false
        controller.onShow = -> onShowCalled = true
        controller.react =
          setProps: (p_data, onComplete) ->
            assert.equal p_data, data
            onComplete()
        container.show controller, data
        assert.isFalse onShowCalled