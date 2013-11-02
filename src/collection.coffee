angular.module('soil.collection', [])

  .factory('soilCollection', ['$http', ($http) ->
    class soilCollection
      constructor: (@_source_url) ->
        @members = undefined

      loadAll: ->
        $http.get(@_source_url).success (data) =>
          @members = data
  ])