angular.module('soil.collection', [])

  .factory('SoilCollection', ['$http', ($http) ->
    class SoilCollection
      constructor: (@scope, @modelClass, @sourceUrl) ->
        @$members = []

        if @scope
          @_setupListeners()

      $load: (data) ->
        data ||= []
        @$members = _.map data, (modelData) =>
          new @modelClass(@scope, modelData)
        return this

      $get: ->
        return $http.get(@sourceUrl)
          .success (data) => @$load(data)

      $add: (data) ->
        newItem = new @modelClass(@scope, data)
        newItem.$setPostUrl @sourceUrl
        @$members.push(newItem)
        return newItem

      $addToFront: (data) ->
        newItem = new @modelClass(@scope, data)
        newItem.$setPostUrl @sourceUrl
        @$members.unshift(newItem)
        return newItem

      $removeById: (id) ->
        _.remove @$members, (item) ->
          item.id == id

      $remove: (itemToRemove) ->
        _.remove @$members, (item) ->
          itemToRemove == item

      _setupListeners: ->
        @scope.$on 'modelDeleted', (e, type, id) =>
          if type == @modelClass.prototype._modelType
            @$removeById(id)
  ])

  .factory('SoilGlobalCollection', ['SoilCollection', '$rootScope', (SoilCollection, $rootScope) ->
    class GlobalSoilCollection extends SoilCollection
      constructor: (modelClass, sourceUrl) ->
        super($rootScope, modelClass, sourceUrl)

        @_setupCreateListener()

      _setupCreateListener: ->
        @scope.$on 'modelSaved', (e, model, data) =>
          if model._modelType == @modelClass.prototype._modelType
            # Check if the id of the saved model is present and only add it if it is not
            if !_.any(@$members, (member) -> member.id == model.id )
              @$add data
  ])