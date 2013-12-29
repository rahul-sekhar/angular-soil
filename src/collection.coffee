angular.module('soil.collection', [])

  .factory('SoilCollection', ['$http', ($http) ->
    class SoilCollection
      constructor: (@_scope, @modelClass, @sourceUrl) ->
        @$members = []

        if @_scope
          @_setupListeners()

      $load: (data) ->
        data ||= []
        @$members = _.map data, (modelData) =>
          @_createModel(modelData)
        return this

      $get: ->
        return $http.get(@sourceUrl)
          .success (data) => @$load(data)

      $add: (data) ->
        newItem = @_createModel(data)
        @$members.push(newItem)
        return newItem

      $addToFront: (data) ->
        newItem = @_createModel(data)
        @$members.unshift(newItem)
        return newItem

      $addAt: (index, data) ->
        newItem = @_createModel(data)
        @$members.splice(index, 0, newItem)
        return newItem

      $removeById: (id) ->
        _.remove @$members, (item) ->
          item.id == id

      $remove: (itemToRemove) ->
        _.remove @$members, (item) ->
          itemToRemove == item

      $find: (id) ->
        _.find @$members, (member) ->
          member.id == id

      _setupListeners: ->
        @_scope.$on 'modelDeleted', (e, type, id) =>
          if type == @modelClass.prototype._modelType
            @$removeById(id)

      _createModel: (data) ->
        model = new @modelClass(@_scope, data)
        model.$setPostUrl @sourceUrl
        model._parent = @_parent if @_parent
        return model
  ])

  .factory('SoilGlobalCollection', ['SoilCollection', '$rootScope', (SoilCollection, $rootScope) ->
    class GlobalSoilCollection extends SoilCollection
      constructor: (modelClass, sourceUrl) ->
        super($rootScope, modelClass, sourceUrl)

        @_setupCreateListener()

      _setupCreateListener: ->
        @_scope.$on 'modelSaved', (e, model, data) =>
          if model._modelType == @modelClass.prototype._modelType
            # Check if the id of the saved model is present and only add it if it is not
            if !_.any(@$members, (member) -> member.id == model.id )
              @$add data
  ])