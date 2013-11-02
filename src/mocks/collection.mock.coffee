angular.module('soil.collection.mock', [])

  .factory('soilCollection', ['$http', ($http) ->
    class soilCollection
      constructor: (@_source_url) ->
        @members = undefined

      loadAll: jasmine.createSpy()
  ])