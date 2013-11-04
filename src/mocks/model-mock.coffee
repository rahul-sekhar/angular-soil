angular.module('soil.model.mock', ['soil.model'])
  .config(['$provide', ($provide) ->
    $provide.decorator('soilModel', ['$delegate', ($delegate) ->
      class soilModelMock extends $delegate
        constructor: ->
          super

        _getFromId: jasmine.createSpy()

        updateField: jasmine.createSpy()
    ])
  ])
