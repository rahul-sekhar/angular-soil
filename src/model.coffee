angular.module('soil.model', [])

  .factory('soilModel', ['$http', ($http) ->
    class soilModel
      constructor: (dataOrId) ->
        if angular.isObject(dataOrId)
          @_load(dataOrId)
        else if dataOrId
          @_getById(dataOrId)

      _base_url: '/'

      isLoaded: -> !!@id

      url: (id = @id) ->
        if id
          @_with_slash(@_base_url) + id
        else
          @_base_url

      updateField: (field) ->
        if @id
          data = {}
          data[field] = @[field]

          $http.put(@url(), data)
            .success (response_data) =>
              @[field] = response_data[field]
              @_saved_data = response_data

            .error =>
              @[field] = @_saved_data[field]
        else
          throw 'Cannot update model without an ID'

      _load: (data) ->
        # Clear old fields
        _.forOwn this, (value, key, obj) ->
          delete obj[key] unless _.first(key) == '_'

        # Assign new fields
        _.assign this, data

        # Set saved data
        @_saved_data = data || {}

      _getById: (id) ->
        $http.get(@url(id)).success (response_data) =>
          @_load(response_data)

      _with_slash: (url) ->
        url.replace /\/?$/, '/'
  ])