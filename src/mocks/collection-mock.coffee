angular.module('soil.collection.mock', ['soil.collection', 'angular-mock-promise'])
  .config(['$provide', ($provide) ->
    $provide.decorator('soilCollection', ['$delegate', 'createMockPromise', ($delegate, createMockPromise) ->
      class soilCollectionMock extends $delegate

        get: jasmine.createSpy('get').andReturn(createMockPromise())
    ])
  ])