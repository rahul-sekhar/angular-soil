angular.module('soil.model', [])

  .factory('soilModel', ['$http', ($http) ->
    class soilModel
      _baseUrl: '/'

      constructor: (arg) ->
        if angular.isNumber(arg)
          @get(arg)
        else if angular.isObject(arg)
          @load(arg)

      setBaseUrl: (newUrl) ->
        @_baseUrl = newUrl

      url: (id = @id) ->
        if id
          @_withSlash(@_baseUrl) + id
        else
          @_baseUrl

      load: (data) ->
        @_clearFields()
        _.assign this, data
        @savedData = data || {}

      get: (id) ->
        return $http.get(@url(id)).success (responseData) =>
          @load(responseData)

      loaded: -> !!@id

      save: ->
        if @id
          return $http.put(@url(), @_dataToSave())
            .success (responseData) => @load(responseData)
        else
          return $http.post(@url(), @_dataToSave())
            .success (responseData) => @load(responseData)

      delete: ->
        @_checkIfLoaded()
        return $http.delete(@url())
          .success => @load(null)

      updateField: (field) ->
        @_checkIfLoaded()
        data = {}
        data[field] = @[field]

        return $http.put(@url(), data)
          .success (responseData) =>
            @[field] = responseData[field]
            @savedData = responseData
          .error =>
            @[field] = @savedData[field]


      _checkIfLoaded: ->
        throw 'Operation not permitted on an unloaded model' unless @loaded()

      _clearFields: () ->
        # Do not remove private fields (fields beginning with an underscore)
        _.forOwn this, (value, key, obj) ->
          delete obj[key] unless _.first(key) == '_'

      _withSlash: (url) ->
        url.replace /\/?$/, '/'

      _fieldsToSave: []

      _dataToSave: ->
        data = {}
        _.each @_fieldsToSave, (field) =>
          data[field] = if @[field] == undefined then null else @[field]
        return data
  ])