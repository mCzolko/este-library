suite 'este.app.request.Queue', ->

  Queue = este.app.request.Queue

  queue = null
  request = null

  setup ->
    queue = new Queue
    request = mockRequest()

  mockRequest = ->
    equal: (req) -> @ == req

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf queue, Queue

  suite 'isEmpty', ->
    test 'should work', ->
      assert.isTrue queue.isEmpty()
      queue.add request
      assert.isFalse queue.isEmpty()

  suite 'clear', ->
    test 'should clear queue', ->
      queue.add request
      queue.clear()
      assert.isTrue queue.isEmpty()

  suite 'dispose', ->
    test 'should clear queue', ->
      queue.add request
      queue.dispose()
      assert.isTrue queue.isEmpty()