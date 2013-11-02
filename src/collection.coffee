angular.module('soil.collection', [])

  .factory('soilCollection', ['$http', ($http) ->
    class soilCollection
      constructor: (@_modelClass, @_source_url) ->
        @members = undefined

      loadAll: ->
        $http.get(@_source_url).success (data) =>
          @members = data

      addItem: (data) ->
        return if @members == undefined

        $http.post(@_source_url, data).success (response_data) =>
          newModel = new @_modelClass(response_data)
          @members.push(newModel)
  ])