angular.module('soil.collection.mock', ['soil.collection', 'angular-mock-promise'])
  .config(['$provide', ($provide) ->
    $provide.decorator('soilCollection', ['$delegate', 'createMockPromise', ($delegate, createMockPromise) ->
      class soilCollectionMock extends $delegate
        constructor: ->
          spyOn(this, 'load').andCallThrough()

          @getPromise = createMockPromise()
          spyOn(this, 'get').andReturn(@getPromise)

          @createPromise = createMockPromise()
          spyOn(this, 'create').andReturn(@createPromise)
          super

    ])
  ])