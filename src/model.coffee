angular.module('soil.model', [])

  .factory('SoilModel', ['$http', ($http) ->
    class SoilModel
      _baseUrl: '/'
      _fieldsToSave: []
      _fieldsToSaveOnCreate: []
      _associations: []

      constructor: (arg) ->
        @$saved = {}
        if angular.isObject(arg)
          @$load(arg)
        else if arg
          @$get(arg)

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
        if @id
          return $http.put(@$url(), @$dataToSave())
            .success (responseData) => @$load(responseData)
        else
          return $http.post(@$url(), @$dataToSave())
            .success (responseData) => @$load(responseData)

      $delete: ->
        @_checkIfLoaded()
        return $http.delete(@$url())
          .success => @$load(null)

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
            @$saved = _.cloneDeep(responseData)
            fieldData = _.pick(responseData, field)
            fieldData = @_modifyDataBeforeLoad(fieldData)
            @[field] = fieldData[field]

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

        return @_modifyDataBeforeSave(data)

      _checkIfLoaded: ->
        throw 'Operation not permitted on an unloaded model' unless @id

      _clearFields: () ->
        # Do not remove private fields (fields beginning with an underscore), or functions
        _.forOwn this, (value, key, obj) ->
          delete obj[key] unless _.first(key) == '_' or angular.isFunction(value)

      _withSlash: (url) ->
        url.replace /\/?$/, '/'

      _fieldsToSave: []

      _modifyDataBeforeLoad: (loadData) ->
        data = _.clone(loadData)
        _.each @_associations, (association) => association.beforeLoad(data, @)
        return data

      _modifyDataBeforeSave: (saveData) ->
        data = _.clone(saveData)
        _.each @_associations, (association) => association.beforeSave(data, @)
        return data

      _setSavedData: (data) ->
        @$saved = if data then _.cloneDeep(data) else {}
  ])