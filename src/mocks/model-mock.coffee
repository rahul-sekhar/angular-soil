angular.module('soil.model.mock', ['soil.model', 'angular-mock-promise'])
  .config(['$provide', ($provide) ->
    $provide.decorator('SoilModel', ['$delegate', 'createMockPromise', ($delegate, createMockPromise) ->
      class SoilModelMock extends $delegate
        constructor: (arg) ->
          spyOn(this, 'load').andCallThrough()
          spyOn(this, 'revert').andCallThrough()

          @getPromise = createMockPromise()
          spyOn(this, 'get').andReturn(@getPromise)

          @savePromise = createMockPromise()
          spyOn(this, 'save').andReturn(@savePromise)

          @deletePromise = createMockPromise()
          spyOn(this, 'delete').andReturn(@deletePromise)

          @updatePromise = createMockPromise()
          spyOn(this, 'updateField').andReturn(@updatePromise)
          super

    ])
  ])
