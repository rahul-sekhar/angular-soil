angular.module('soil.model.mock', ['soil.model', 'angular-mock-promise'])
  .config(['$provide', ($provide) ->
    $provide.decorator('SoilModel', ['$delegate', 'createMockPromise', ($delegate, createMockPromise) ->
      class SoilModelMock extends $delegate
        constructor: (arg) ->
          spyOn(this, '$load').and.callThrough()
          spyOn(this, '$revert').and.callThrough()

          @_getPromise = createMockPromise()
          spyOn(this, '$get').and.returnValue(@_getPromise)

          @_savePromise = createMockPromise()
          spyOn(this, '$save').and.returnValue(@_savePromise)

          @_deletePromise = createMockPromise()
          spyOn(this, '$delete').and.returnValue(@_deletePromise)

          @_updatePromise = createMockPromise()
          spyOn(this, '$updateField').and.returnValue(@_updatePromise)
          super

    ])
  ])
