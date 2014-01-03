suite 'este.labs.app.SimplePagesContainer', ->

  SimplePagesContainer = este.labs.app.SimplePagesContainer

  container = null
  page = null
  containerEl = null
  data = null

  setup ->
    container = new SimplePagesContainer
    page =
      show: ->
      hide: ->
      getElement: ->
    containerEl =
      appendChild: ->
      removeChild: ->
    data = {}

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf container, SimplePagesContainer

  suite 'show', ->
    suite 'first page', ->
      test 'should call show on page with containerEl and data', (done) ->
        page.show = (p_container, p_data) ->
          assert.equal p_container, containerEl
          assert.equal p_data, data
          done()
        container.show page, containerEl, data

    suite 'next page', ->
      test 'should call hide on previous page', (done) ->
        container.show page, containerEl, data
        page.hide = ->
          done()
        container.show page, containerEl, data

      test 'should remove previous page element from containerEl', (done) ->
        container.show page, containerEl, data
        page.getElement = -> 'element'
        containerEl.removeChild = (element) ->
          assert.equal element, page.getElement()
          done()
        container.show page, containerEl, data

    suite 'yet rendered page', ->
      test 'should append page element into containerEl', (done) ->
        page.getElement = -> 'element'
        containerEl.appendChild = (element) ->
          assert.equal element, page.getElement()
          done()
        container.show page, containerEl, data