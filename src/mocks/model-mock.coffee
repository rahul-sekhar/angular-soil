angular.module('soil.model.mock', ['soil.model'])
  .config(['$provide', ($provide) ->
    $provide.decorator('soilModel', ['$delegate', ($delegate) ->
      class soilModelMock extends $delegate
        constructor: ->
          super

        refresh: jasmine.createSpy()

        updateField: jasmine.createSpy()
    ])
  ])