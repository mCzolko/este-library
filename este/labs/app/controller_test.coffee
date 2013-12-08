suite 'este.labs.app.Controller', ->

  Controller = este.labs.app.Controller

  controller = null

  setup ->
    controller = new Controller

  suite 'load', ->
    test 'should return resolved promise with params', (done) ->
      params = a: 1
      promise = controller.load params
      promise.then (p_params) ->
        assert.deepEqual p_params, params
        done()