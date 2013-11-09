angular.module('soil.collection', [])

  .factory('soilCollection', ['$http', ($http) ->
    class soilCollection
      constructor: (@_modelClass, @_sourceUrl) ->
        unless _.isFunction(@_modelClass)
          throw 'Expected a model class as the first argument when instantiating soilCollection'

        @members = undefined

      loadAll: ->
        return $http.get(@_sourceUrl).success (items) =>
          @members = _.map(items, (item) => new @_modelClass(item))

      addItem: (data) ->
        return if @members == undefined

        return $http.post(@_sourceUrl, data).success (response_data) =>
          newModel = new @_modelClass(response_data)
          @members.push(newModel)
  ])