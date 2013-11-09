angular.module('testPromise', [])

  .factory('testPromise', ['$rootScope', ($rootScope) ->
    class testPromise
      constructor: (promise) ->
        @successFn = jasmine.createSpy('promise success').andCallFake =>
          @successFnCalled = true
          @args = arguments
          @arg = arguments[0]

        @errorFn = jasmine.createSpy('promise error').andCallFake =>
          @errorFnCalled = true
          @args = arguments
          @arg = arguments[0]

        promise.then @successFn, @errorFn

      expectSuccess: ->
        expect(@successFn).toHaveBeenCalled()
        expect(@errorFn).not.toHaveBeenCalled()

      expectError: ->
        expect(@errorFn).toHaveBeenCalled()
        expect(@successFn).not.toHaveBeenCalled()


    return (promise) ->
      new testPromise(promise)
  ])

  .factory('mockPromise', ['$rootScope', '$q', ($rootScope, $q) ->
    deferred = $q.defer()
    promise = deferred.promise

    promise.resolve = ->
      deferred.resolve.apply(undefined, arguments)
      $rootScope.$apply()

    promise.reject = ->
      deferred.reject.apply(undefined, arguments)
      $rootScope.$apply()
  ])
