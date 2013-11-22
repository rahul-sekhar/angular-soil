angular.module('soil.collection', [])

  .factory('SoilCollection', ['$http', ($http) ->
    class SoilCollection
      constructor: (@modelClass, @sourceUrl) ->
        @members = []

      load: (data) ->
        data ||= []
        @members = _.map data, (modelData) =>
          new @modelClass(modelData)
        return this

      get: ->
        return $http.get(@sourceUrl)
          .success (data) => @load(data)

      add: (data) ->
        newItem = new @modelClass(data)
        newItem._postUrl = @sourceUrl
        @members.push(newItem)
        return newItem

      addToFront: (data) ->
        newItem = new @modelClass(data)
        newItem._postUrl = @sourceUrl
        @members.unshift(newItem)
        return newItem

      removeById: (id) ->
        _.remove @members, (item) ->
          item.id == id

      remove: (itemToRemove) ->
        _.remove @members, (item) ->
          itemToRemove == item
  ])