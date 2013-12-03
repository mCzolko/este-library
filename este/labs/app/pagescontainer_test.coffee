suite 'este.labs.app.PagesContainer', ->

  PagesContainer = este.labs.app.PagesContainer

  container = null
  data = null
  containerEl = null
  controllerA = null
  controllerB = null

  setup ->
    data = {}
    containerEl =
      appendChild: ->
      removeChild: ->
    container = new PagesContainer containerEl

  arrangeController = ->
    wasRendered: ->
      @rendered
    show: ->
      @rendered = true
    hide: ->

  arrangeControllersAandB = ->
    controllerA = arrangeController()
    controllerA.getElement = -> 1
    controllerB = arrangeController()

  suite 'show', ->
    suite 'of not yet rendered controller', ->
      test 'should call controller show', (done) ->
        controller = arrangeController()
        controller.show = (el, p_data) ->
          assert.equal el, containerEl
          assert.equal p_data, data
          done()
        container.show controller, data

    suite 'of yet rendered controller', ->
      test 'should add controller element to container', (done) ->
        arrangeControllersAandB()
        controllerB.getElement = -> 2
        container.show controllerA, data
        container.show controllerB, data
        containerEl.appendChild = (node) ->
          assert.equal node, 1
          done()
        container.show controllerA, data

    suite 'of two different controllers', ->
      test 'should remove previous controller element', (done) ->
        arrangeControllersAandB()
        container.show controllerA, data
        containerEl.removeChild = (node) ->
          assert.equal node, 1
          done()
        container.show controllerB, data

      test 'should call hide on previous controller', (done) ->
        arrangeControllersAandB()
        container.show controllerA, data
        controllerA.hide = ->
          done()
        container.show controllerB, data

    suite 'repeated on the same controllers', ->
      test 'should not add nor remove controller element', ->
        controllerA = arrangeController()
        controllerA.getElement = ->
        container.show controllerA, data
        domChanged = false
        containerEl.appendChild = -> domChanged = true
        containerEl.removeChild = -> domChanged = true
        container.show controllerA, data
        assert.isFalse domChanged