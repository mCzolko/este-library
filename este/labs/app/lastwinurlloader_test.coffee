suite 'este.labs.app.LastWinUrlLoader', ->

  LastWinUrlLoader = este.labs.app.LastWinUrlLoader

  loader = null
  loadCalled = null

  setup ->
    loader = new LastWinUrlLoader
    loadCalled = {}

  load = (url, opt_delay) ->
    loader.load url, ->
      incrementLoadCall url
      new goog.Promise (fulfill, reject) ->
        if opt_delay?
          setTimeout (-> fulfill url), opt_delay
        else
          fulfill url

  loadFail = (url, opt_delay) ->
    loader.load url, ->
      incrementLoadCall url
      new goog.Promise (fulfill, reject) ->
        if opt_delay?
          setTimeout (-> reject url), opt_delay
        else
          reject url

  incrementLoadCall = (url) ->
    loadCalled[url] ?= 0
    loadCalled[url]++

  suite 'load url1', ->
    test 'should call load and return its promise', (done) ->
      load('url1').then (value) ->
        assert.equal value, 'url1'
        assert.equal loadCalled.url1, 1
        done()

  suite 'loadFail url1', ->
    test 'should reject url1 with reason as LastWinUrlLoader.Error', (done) ->
      loadFail('url1').then null, (error) ->
        assert.instanceOf error, este.labs.app.LastWinUrlLoader.Error
        assert.equal error.reason, 'url1'
        assert.isFalse error.isSilent, 'url1'
        assert.equal loadCalled.url1, 1
        done()

  suite 'load url1 then url2 before url1 is done', ->
    test 'should cancel url1 with abort message', (done) ->
      url1Reject = sinon.spy()
      load('url1', 20).then null, url1Reject
      load('url2', 10).then (value) ->
        assert.equal url1Reject.args[0][0].message, 'abort'
        done()

  suite 'loadFail url1 then url2 before url1 is done', ->
    test 'should reject url1 as silent LastWinUrlLoader.Error', (done) ->
      loadFail('url1', 20).then null, (error) ->
        assert.equal error.message, 'abort'
        done()
      load 'url2', 10

  suite 'load url1 then url2 after url1 is done', ->
    test 'should cancel url1 with abort message', (done) ->
      url1Reject = sinon.spy()
      load('url1', 10).then null, url1Reject
      load('url2', 20).then (value) ->
        assert.equal url1Reject.args[0][0].message, 'abort'
        done()

  suite 'loadFail url1 then url2 after url1 is done', ->
    test 'should reject url1 as silent LastWinUrlLoader.Error', (done) ->
      loadFail('url1', 10).then null, (error) ->
        assert.instanceOf error, este.labs.app.LastWinUrlLoader.Error
        assert.equal error.reason, 'url1'
        assert.isTrue error.isSilent, 'url1'
        done()
      load 'url2', 20

  suite 'load url1 and after finish load url2', ->
    test 'should resolve both url1 and url2', (done) ->
      url1Fulfill = sinon.spy()
      load('url1', 10).then url1Fulfill
      setTimeout ->
        load('url2', 10).then (value) ->
          assert.equal url1Fulfill.args[0], 'url1'
          assert.equal value, 'url2'
          done()
      , 20

  suite 'loadFail url1 and after finish load url2', ->
    test 'should resolve both url1 and url2', (done) ->
      url1Fulfill = sinon.spy()
      loadFail('url1', 10).then null, url1Fulfill
      setTimeout ->
        load('url2', 10).then (value) ->
          assert.isTrue url1Fulfill.called
          assert.equal url1Fulfill.args[0][0].reason, 'url1'
          assert.isFalse url1Fulfill.args[0][0].isSilent
          assert.equal value, 'url2'
          done()
      , 20

  suite 'load url1 twice before first is done', ->
    test 'should call load method just once', ->
      load 'url1', 20
      load 'url1', 1
      assert.equal loadCalled.url1, 1

    test 'should cancel second load with pending message', (done) ->
      url1Reject = sinon.spy()
      load('url1', 20).then (value) ->
        assert.equal url1Reject.args[0][0].message, 'pending'
        done()
      load('url1', 1).then null, url1Reject

  suite 'load url1 twice after first is done', ->
    test 'should call load method twice', (done) ->
      load 'url1', 10
      setTimeout ->
        load('url1').then (value) ->
          assert.equal loadCalled.url1, 2
          done()
      , 20

  suite 'load url1 then url2 then url3 before url1 and url2 are finished', ->
    test 'should resolve url3 and reject url1 and url2 as cancelled with abort', (done) ->
      url1Reject = sinon.spy()
      url2Reject = sinon.spy()
      load('url1').then null, url1Reject
      load('url2').then null, url2Reject
      load('url3').then (value) ->
        assert.equal url2Reject.args[0][0].message, 'abort'
        assert.equal url2Reject.args[0][0].message, 'abort'
        done()

  suite 'load url1 then loadFail url2 before url1 is done', ->
    test 'should cancel url1 with abort', (done) ->
      url1Reject = sinon.spy()
      load('url1', 20).then null, url1Reject
      loadFail('url2').then null, (error) ->
        assert.equal url1Reject.args[0][0].message, 'abort'
        done()

  suite 'timeout', ->
    test 'should cancel everything with timeout message', (done) ->
      loader.timeoutMs = 10
      url1Reject = sinon.spy()
      url2Reject = sinon.spy()
      url3Reject = sinon.spy()
      load('url1', 40).then null, url1Reject
      load('url2', 40).then null, url2Reject
      load('url3', 40).then null, url3Reject
      setTimeout ->
        assert.equal url1Reject.args[0][0].message, 'timeout'
        assert.equal url2Reject.args[0][0].message, 'timeout'
        assert.equal url3Reject.args[0][0].message, 'timeout'
        done()
      , 20

    test 'should be clearTimeouted after load is done', (done) ->
      loader.timeoutMs = 40
      load 'url1', 10
      setTimeout ->
        load('url1', 30).then (value) ->
          assert.equal value, 'url1'
          done()
      , 20