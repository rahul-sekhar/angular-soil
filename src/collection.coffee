angular.module('soil.collection', [])

  .factory('SoilCollection', ['$http', '$q', ($http, $q) ->
    class SoilCollection
      constructor: (@_scope, @modelClass, @sourceUrl) ->
        @$members = []

        @_initialLoad = $q.defer()
        @$afterInitialLoad = @_initialLoad.promise

        if @_scope
          @_setupListeners()

      $load: (data) ->
        if !angular.isArray(data) && angular.isObject(data)
          @data = data.data
          data = data.items

        data ||= []
        @$members = _.map data, (modelData) =>
          @_createModel(modelData)
        return this

      $get: ->
        return $http.get(@sourceUrl)
          .success (data) =>
            @$load(data)
            @_initialLoad.resolve()

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

      $setScope: (scope) ->
        throw 'Scope has already been set' if (@_scope)
        @_scope = scope
        @_setupListeners()
        _.each @$members, (member) =>
          member.$setScope(scope)
          return

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

        @_setupCreateListeners()
        @$afterInitialLoad.then => @_loaded = true
        @$get()

      _setupCreateListeners: ->
        @_scope.$on 'modelSaved', (e, model, data) =>
          if model._modelType == @modelClass.prototype._modelType
            # Check if the id of the saved model is present and only add it if it is not
            if !_.any(@$members, (member) -> member.id == model.id )
              @$add data

        @_scope.$on 'modelCreateFailed', (e, model) =>
          if model._modelType == @modelClass.prototype._modelType
            @$remove model
  ])