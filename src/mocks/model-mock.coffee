angular.module('soil.model.mock', ['soil.model', 'angular-mock-promise'])
  .config(['$provide', ($provide) ->
    $provide.decorator('soilModel', ['$delegate', 'createMockPromise', ($delegate, createMockPromise) ->
      class soilModelMock extends $delegate
        constructor: (arg) ->
          spyOn(@, 'load').andCallThrough()

          @getPromise = createMockPromise()
          spyOn(@, 'get').andReturn(@getPromise)

          @savePromise = createMockPromise()
          spyOn(@, 'save').andReturn(@savePromise)

          @deletePromise = createMockPromise()
          spyOn(@, 'delete').andReturn(@deletePromise)

          @updatePromise = createMockPromise()
          spyOn(@, 'updateField').andReturn(@updatePromise)
          super

    ])
  ])
