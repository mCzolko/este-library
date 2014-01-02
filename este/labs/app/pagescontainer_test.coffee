suite 'este.labs.app.PagesContainer', ->

  PagesContainer = este.labs.app.PagesContainer

  pagesContainer = null
  page = null
  container = null
  data = null

  setup ->
    pagesContainer = new PagesContainer
    page =
      show: ->
      hide: ->
      getElement: ->
    container =
      appendChild: ->
      removeChild: ->
    data = {}

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf pagesContainer, PagesContainer

  suite 'show', ->
    suite 'first page', ->
      test 'should call show on page with container and data', (done) ->
        page.show = (p_container, p_data) ->
          assert.equal p_container, container
          assert.equal p_data, data
          done()
        pagesContainer.show page, container, data

    suite 'next page', ->
      test 'should call hide on previous page', (done) ->
        pagesContainer.show page, container, data
        page.hide = ->
          done()
        pagesContainer.show page, container, data

      test 'should remove previous page element from container', (done) ->
        pagesContainer.show page, container, data
        page.getElement = -> 'element'
        container.removeChild = (element) ->
          assert.equal element, page.getElement()
          done()
        pagesContainer.show page, container, data

    suite 'yet rendered page', ->
      test 'should append page element into container', (done) ->
        page.getElement = -> 'element'
        container.appendChild = (element) ->
          assert.equal element, page.getElement()
          done()
        pagesContainer.show page, container, data