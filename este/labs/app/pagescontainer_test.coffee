suite 'este.labs.app.PagesContainer', ->

  PagesContainer = este.labs.app.PagesContainer

  container = null
  data = null
  containerEl = null

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

  suite 'show', ->
    test 'should call controller show with containerEl and data', (done) ->
      controller = arrangeController()
      controller.show = (el, p_data) ->
        assert.equal el, containerEl
        assert.equal p_data, data
        done()

      container.show controller, data

    test 'should remove previous controller element from container', (done) ->
      controllerA = arrangeController()
      controllerA.getElement = -> 1
      controllerB = arrangeController()

      container.show controllerA, data
      containerEl.removeChild = (node) ->
        assert.equal node, 1
        done()
      container.show controllerB, data

    test 'should add yet rendered controller element to container', (done) ->
      controllerA = arrangeController()
      controllerA.getElement = -> 1
      controllerB = arrangeController()
      controllerB.getElement = -> 2

      container.show controllerA, data
      container.show controllerB, data
      containerEl.appendChild = (node) ->
        assert.equal node, 1
        done()
      container.show controllerA, data

    test 'should not add nor remove same controller element', ->
      controllerA = arrangeController()
      controllerA.getElement = ->
      container.show controllerA, data
      domChanged = false
      containerEl.appendChild = -> domChanged = true
      containerEl.removeChild = -> domChanged = true
      container.show controllerA, data
      assert.isFalse domChanged