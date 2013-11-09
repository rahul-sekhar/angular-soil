angular.module('soil.collection.mock', ['soil.collection', 'angular-mock-promise'])
  .config(['$provide', ($provide) ->
    $provide.decorator('soilCollection', ['$delegate', 'createMockPromise', ($delegate, createMockPromise) ->
      class soilCollectionMock extends $delegate
        constructor: ->
          super
          spyOn(this, 'loadAll').andCallFake =>
            @members = []

        addItem: jasmine.createSpy('addItem').andReturn(createMockPromise())
    ])
  ])