angular.module('soil.collection', [])

  .factory('soilCollection', ['$http', ($http) ->
    class soilCollection
      constructor: (@modelClass, @_sourceUrl, options = {}) ->
        @_options = _.defaults(options, {
          getData: false
        })
        @members = undefined
        if @_options.getData
          @get()

      load: (data) ->
        data ||= []
        @members = _.map data, (modelData) =>
          new @modelClass(modelData)
        return this

      get: ->
        return $http.get(@_sourceUrl)
          .success (data) => @load(data)

      add: (item) ->
        @members.push(item)

      addToFront: (item) ->
        @members.unshift(item)

      create: (data, options = {}) ->
        options = _.defaults(options, { addToFront: false })
        return $http.post(@_sourceUrl, data).success (responseData) =>
          newModel = new @modelClass(responseData)
          if options.addToFront
            @addToFront(newModel)
          else
            @add(newModel)

      removeById: (id) ->
        _.remove @members, (item) ->
          item.id == id

      remove: (itemToRemove) ->
        _.remove @members, (item) ->
          itemToRemove == item

      loaded: ->
        return !(@members == undefined)
  ])