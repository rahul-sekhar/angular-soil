angular.module('soil.collection.mock', ['soil.collection', 'angular-mock-promise'])
  .config(['$provide', ($provide) ->
    $provide.decorator('soilCollection', ['$delegate', 'createMockPromise', ($delegate, createMockPromise) ->
      class soilCollectionMock extends $delegate
        constructor: ->
          @load = jasmine.createSpy('load').andReturn(this)
          @get = jasmine.createSpy('get').andReturn(createMockPromise())
          super

    ])
  ])