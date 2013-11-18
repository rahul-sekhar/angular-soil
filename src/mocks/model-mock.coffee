angular.module('soil.model.mock', ['soil.model', 'angular-mock-promise'])
  .config(['$provide', ($provide) ->
    $provide.decorator('soilModel', ['$delegate', 'createMockPromise', ($delegate, createMockPromise) ->
      class soilModelMock extends $delegate
        constructor: (arg) ->
          spyOn(@, 'load').andCallThrough()
          spyOn(@, 'get').andReturn(createMockPromise())
          spyOn(@, 'save').andReturn(createMockPromise())
          spyOn(@, 'delete').andReturn(createMockPromise())
          spyOn(@, 'updateField').andReturn(createMockPromise())
          super

    ])
  ])
