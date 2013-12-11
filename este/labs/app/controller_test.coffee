suite 'este.labs.app.Controller', ->

  Controller = este.labs.app.Controller

  controller = null

  setup ->
    controller = new Controller

  suite 'reactClass', ->
    test 'should render default template', ->
      react = controller.reactClass()
      # TODO: Test methods, but now rendering because data-react-checksum.

  suite 'load', ->
    test 'should return resolved promise with params', (done) ->
      params = a: 1
      promise = controller.load params
      promise.then (p_params) ->
        assert.deepEqual p_params, params
        done()