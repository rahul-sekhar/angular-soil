angular.module('soil.model', [])

  .factory('soilModel', ['$http', ($http) ->
    class soilModel
      constructor: (dataOrId) ->
        if angular.isObject(dataOrId)
          @_load(dataOrId)

      _baseUrl: '/'

      _urlSuffix: ''

      getById: (id) ->
        return $http.get(@url(id)).success (responseData) =>
          @_load(responseData)

      isInitialized: -> !!@id

      url: (id = @id) ->
        if id
          @_withSlash(@_baseUrl) + id + @_urlSuffix
        else
          @_baseUrl + @_urlSuffix

      updateField: (field) ->
        if @isInitialized()
          data = {}
          data[field] = @[field]

          return $http.put(@url(), data)
            .success (responseData) =>
              @[field] = responseData[field]
              @savedData = responseData

            .error =>
              @[field] = @savedData[field]
        else
          throw 'Cannot update model without an ID'

      save: ->
        if @isInitialized()
          return $http.put(@url(), @_dataToSave())
            .success (responseData) =>
              @_load(responseData)
        else
          throw 'Cannot save model without an ID'

      delete: ->
        if @isInitialized()
          return $http.delete(@url())
            .success => @_load(null)

        else
          throw 'Cannot delete model without an ID'

      _load: (data) ->
        @_clearFields()
        _.assign this, data
        @savedData = data || {}

      _clearFields: () ->
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