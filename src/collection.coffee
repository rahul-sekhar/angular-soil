angular.module('soil.collection', [])

  .factory('soilCollection', ['$http', ($http) ->
    class soilCollection
      constructor: (@_modelClass) ->
        @members = undefined

      load: (data) ->
        data ||= []
        @members = _.map data, (modelData) =>
          new @_modelClass(modelData)

      get: (url) ->
        return $http.get(url)
          .success (data) => @load(data)

      add: (item) ->
        @members.push(item)

      addToFront: (item) ->
        @members.unshift(item)

      removeById: (id) ->
        _.remove @members, (item) ->
          item.id == id

      remove: (itemToRemove) ->
        _.remove @members, (item) ->
          itemToRemove == item
  ])