angular.module('soil.model', [])

  .factory('SoilModel', ['$http', '$rootScope', ($http, $rootScope) ->
    class SoilModel
      _baseUrl: '/'
      _fieldsToSave: []
      _fieldsToSaveOnCreate: []
      _associations: []
      _modelType: 'model'

      _initializeFields: ->

      constructor: (@_scope, arg) ->
        @_dataLoadedCallback = ->
        @$saved = {}
        if angular.isObject(arg)
          @$load arg
        else if arg
          @$get arg
        else
          @$load {}

        if @_scope
          @_setupListeners()

      $onDataLoaded: (@_dataLoadedCallback) ->

      $setBaseUrl: (newUrl) ->
        @_baseUrl = newUrl

      $setPostUrl: (newUrl) ->
        @_postUrl = newUrl

      $url: (id) ->
        id ||= @slug || @id
        if id
          @_withSlash(@_baseUrl) + id
        else
          @_postUrl || @_baseUrl

      $load: (data) ->
        @_clearFields()
        @_setSavedData(data)
        _.assign this, @_modifyDataBeforeLoad(data)
        @_dataLoadedCallback()
        return this

      $get: (id) ->
        return $http.get(@$url(id)).then (response) =>
          @$load(response.data)

      $save: (url, loadData=true) ->
        sendRequest = if @id then $http.put else $http.post
        url ||= @$url()
        return sendRequest(url, @$dataToSave())
          .success (responseData) =>
            if loadData
              @$load(responseData)
            $rootScope.$broadcast('modelSaved', this, responseData)

          .error =>
            $rootScope.$broadcast('modelCreateFailed', this) unless @id

          # Resolve the promise with the instance
          .then => this

      $delete: ->
        if @id
          return $http.delete(@$url())
            .success =>
              $rootScope.$broadcast('modelDeleted', @_modelType, @id)
              @$load(null)
        else
          $rootScope.$broadcast('modelCreateFailed', this)

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

          # Resolve the promise with the instance
          .then => this

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

      $setScope: (scope) ->
        throw 'Scope has already been set' if (@_scope)
        @_scope = scope
        @_setupListeners()
        _.each @_associations, (association) =>
          association.setScope(scope, this)
          return

      _loadField: (field, data) ->
        @$saved = _.cloneDeep(data)
        fieldData = _.pick(data, field)
        fieldData = @_modifyDataBeforeLoad(fieldData)
        @[field] = fieldData[field]
        @_dataLoadedCallback()

      _checkIfLoaded: ->
        throw 'Operation not permitted on an unloaded model' unless @id

      _clearFields: () ->
        # Do not remove private fields (fields beginning with an underscore), or functions
        _.forOwn this, (value, key, obj) ->
          delete obj[key] unless _.first(key) == '_' or angular.isFunction(value)
          return

        # Run function to initialize fields
        @_initializeFields()

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
          if @id && model != this && model._modelType == @_modelType && model.id == @id
            @$load(data)

        @_scope.$on 'modelFieldUpdated', (e, model, field, data) =>
          if @id && model != this && model._modelType == @_modelType && model.id == @id
            @_loadField(field, data)
  ])