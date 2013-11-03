angular.module('soil.model', [])

  .factory('soilModel', ['$http', ($http) ->
    class soilModel
      constructor: (data) ->
        @load(data)

      _base_url: '/'

      load: (data) ->
        # Clear old fields
        _.forOwn this, (value, key, obj) ->
          delete obj[key] unless _.first(key) == '_'

        # Assign new fields
        _.assign this, data

      url: ->
        if @id
          @_with_slash(@_base_url) + @id
        else
          @_base_url

      refresh: ->
        if @id
          $http.get(@url()).success (data) =>
            @load(data)
        else
          throw 'Cannot refresh model without an ID'

      _with_slash: (url) ->
        url.replace /\/?$/, '/'
  ])