angular.module('soil.model.mock', ['soil.model', 'angular-mock-promise'])
  .config(['$provide', ($provide) ->
    $provide.decorator('soilModel', ['$delegate', 'createMockPromise', ($delegate, createMockPromise) ->
      class soilModelMock extends $delegate
        constructor: ->
          super

        getById: jasmine.createSpy('getById').andReturn(createMockPromise())

        updateField: jasmine.createSpy('updateField').andReturn(createMockPromise())

        save: jasmine.createSpy('save').andReturn(createMockPromise())

        delete: jasmine.createSpy('delete').andReturn(createMockPromise())
    ])
  ])
