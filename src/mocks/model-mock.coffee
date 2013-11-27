angular.module('soil.model.mock', ['soil.model', 'angular-mock-promise'])
  .config(['$provide', ($provide) ->
    $provide.decorator('SoilModel', ['$delegate', 'createMockPromise', ($delegate, createMockPromise) ->
      class SoilModelMock extends $delegate
        constructor: (arg) ->
          spyOn(this, '$load').andCallThrough()
          spyOn(this, '$revert').andCallThrough()

          @_getPromise = createMockPromise()
          spyOn(this, '$get').andReturn(@_getPromise)

          @_savePromise = createMockPromise()
          spyOn(this, '$save').andReturn(@_savePromise)

          @_deletePromise = createMockPromise()
          spyOn(this, '$delete').andReturn(@_deletePromise)

          @_updatePromise = createMockPromise()
          spyOn(this, '$updateField').andReturn(@_updatePromise)
          super

    ])
  ])
