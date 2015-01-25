angular.module('soil.collection.mock', ['soil.collection', 'angular-mock-promise'])
  .config(['$provide', ($provide) ->
    $provide.decorator('SoilCollection', ['$delegate', 'createMockPromise', ($delegate, createMockPromise) ->
      class SoilCollectionMock extends $delegate
        constructor: ->
          spyOn(this, '$load').and.callThrough()

          @_getPromise = createMockPromise()
          spyOn(this, '$get').and.returnValue(@_getPromise)

          super
    ])
  ])