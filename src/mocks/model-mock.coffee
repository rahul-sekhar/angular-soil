angular.module('soil.model.mock', ['soil.model', 'angular-mock-promise'])
  .config(['$provide', ($provide) ->
    $provide.decorator('soilModel', ['$delegate', 'createMockPromise', ($delegate, createMockPromise) ->
      class soilModelMock extends $delegate
        constructor: ->
          spyOn(this, 'load').andCallThrough()
          spyOn(this, 'get').andReturn(createMockPromise())
          spyOn(this, 'save').andReturn(createMockPromise())
          spyOn(this, 'delete').andReturn(createMockPromise())
          spyOn(this, 'updateField').andReturn(createMockPromise())
          super

    ])
  ])
