angular.module('soil.model', [])

  .factory('SoilModel', ['$http', '$rootScope', ($http, $rootScope) ->
    class SoilModel
      _baseUrl: '/'
      _fieldsToSave: []
      _fieldsToSaveOnCreate: []
      _associations: []
      _modelType: 'model'

      constructor: (@_scope, arg) ->
        @$saved = {}
        if angular.isObject(arg)
          @$load(arg)
        else if arg
          @$get(arg)

        if @_scope
          @_setupListeners()

      $setBaseUrl: (newUrl) ->
        @_baseUrl = newUrl

      $setPostUrl: (newUrl) ->
        @_postUrl = newUrl

      $url: (id = @id) ->
        if id
          @_withSlash(@_baseUrl) + id
        else
          @_postUrl || @_baseUrl

      $load: (data) ->
        @_clearFields()
        @_setSavedData(data)
        _.assign this, @_modifyDataBeforeLoad(data)
        return this

      $get: (id) ->
        return $http.get(@$url(id)).success (responseData) =>
          @$load(responseData)

      $save: ->
        sendRequest = if @id then $http.put else $http.post
        return sendRequest(@$url(), @$dataToSave())
          .success (responseData) =>
            @$load(responseData)
            $rootScope.$broadcast('modelSaved', this, responseData)

      $delete: ->
        @_checkIfLoaded()
        return $http.delete(@$url())
          .success =>
            $rootScope.$broadcast('modelDeleted', @_modelType, @id)
            @$load(null)

      $revert: ->
        savedData = @$saved
        @_clearFields()
        @_setSavedData(savedData)
        _.assign this, @_modifyDataBeforeLoad(savedData)
        return this


      $updateField: (field) ->
        @_checkIfLoaded()
        data = {}
        data[field] = @[field]
        data = @_modifyDataBeforeSave(data)

        return $http.put(@$url(), data)
          .success (responseData) =>
            @_loadField(field, responseData)
            $rootScope.$broadcast('modelFieldUpdated', this, field, responseData)

          .error =>
            @$revertField(field)

      $revertField: (field) ->
        restoreData = @_modifyDataBeforeLoad(@$saved)
        @[field] = restoreData[field]

      $dataToSave: ->
        fields = @_fieldsToSave
        unless @id
          fields = fields.concat @_fieldsToSaveOnCreate

        data = {}
        _.each fields, (field) =>
          data[field] = if @[field] == undefined then null else @[field]
          return

        return @_modifyDataBeforeSave(data)

      _loadField: (field, data) ->
        @$saved = _.cloneDeep(data)
        fieldData = _.pick(data, field)
        fieldData = @_modifyDataBeforeLoad(fieldData)
        @[field] = fieldData[field]

      _checkIfLoaded: ->
        throw 'Operation not permitted on an unloaded model' unless @id

      _clearFields: () ->
        # Do not remove private fields (fields beginning with an underscore), or functions
        _.forOwn this, (value, key, obj) ->
          delete obj[key] unless _.first(key) == '_' or angular.isFunction(value)
          return

      _withSlash: (url) ->
        url.replace /\/?$/, '/'

      _fieldsToSave: []

      _modifyDataBeforeLoad: (loadData) ->
        data = _.clone(loadData)
        _.each @_associations, (association) =>
          association.beforeLoad(data, this)
          return
        return data

      _modifyDataBeforeSave: (saveData) ->
        data = _.clone(saveData)
        _.each @_associations, (association) =>
          association.beforeSave(data, this)
          return
        return data

      _setSavedData: (data) ->
        @$saved = if data then _.cloneDeep(data) else {}

      _setupListeners: ->
        @_scope.$on 'modelSaved', (e, model, data) =>
          if @id && model._modelType == @_modelType && model.id == @id
            @$load(data)

        @_scope.$on 'modelFieldUpdated', (e, model, field, data) =>
          if @id && model._modelType == @_modelType && model.id == @id
            @_loadField(field, data)
  ])