angular.module('soil.model', [])

  .factory('soilModel', ['$http', ($http) ->
    class soilModel
      constructor: (dataOrId) ->
        if angular.isObject(dataOrId)
          @_load(dataOrId)

      _base_url: '/'

      getById: (id) ->
        return $http.get(@url(id)).success (responseData) =>
          @_load(responseData)

      isLoaded: -> 
        # dump(@id)
        !!@id

      url: (id = @id) ->
        if id
          @_withSlash(@_base_url) + id
        else
          @_base_url

      updateField: (field) ->
        if @isLoaded()
          data = {}
          data[field] = @[field]

          return $http.put(@url(), data)
            .success (responseData) =>
              @[field] = responseData[field]
              @_savedData = responseData

            .error =>
              @[field] = @_savedData[field]
        else
          throw 'Cannot update model without an ID'

      save: (field) ->
        if @isLoaded()
          
          return $http.put(@url(), @_dataToSave())
            .success (responseData) =>
              @_load(responseData)
        else
          throw 'Cannot save model without an ID'

      _load: (data) ->
        # Clear old fields
        _.forOwn this, (value, key, obj) ->
          delete obj[key] unless _.first(key) == '_'

        # Assign new fields
        _.assign this, data

        # Set saved data
        @_savedData = data || {}

      _withSlash: (url) ->
        url.replace /\/?$/, '/'

      _fieldsToSave: []

      _dataToSave: ->
        data = {}
        _.each @_fieldsToSave, (field) =>
          data[field] = if @[field] == undefined then null else @[field]
        return data
  ])