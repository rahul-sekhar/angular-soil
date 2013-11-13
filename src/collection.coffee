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

      add: (data) ->
        @members.push(new @modelClass(data))

      addToFront: (data) ->
        @members.unshift(new @modelClass(data))

      create: (data, options = {}) ->
        options = _.defaults(options, { addToFront: false })
        return $http.post(@_sourceUrl, data).success (responseData) =>
          if options.addToFront
            @addToFront(responseData)
          else
            @add(responseData)

      removeById: (id) ->
        _.remove @members, (item) ->
          item.id == id

      remove: (itemToRemove) ->
        _.remove @members, (item) ->
          itemToRemove == item

      loaded: ->
        return !(@members == undefined)
  ])