angular.module('soil.collection.mock', ['soil.collection'])
  .config(['$provide', ($provide) ->
    $provide.decorator('soilCollection', ['$delegate', ($delegate) ->
      class soilCollectionMock extends $delegate
        constructor: ->
          super
          spyOn(this, 'loadAll').andCallFake =>
            @members = []

        addItem: jasmine.createSpy()
    ])
  ])