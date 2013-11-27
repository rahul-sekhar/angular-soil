angular.module('soil.association', ['soil.collection'])

  .factory('HasOneAssociation', [ ->
    class HasOneAssociation
      constructor: (@_field, @_modelClass, options = {}) ->
        @_options = _.defaults(options, {
          saveData: false
        })
        @_idField = @_field + '_id'

      beforeLoad: (data, parent) ->
        return if !data

        if (data[@_field])
          data[@_field] = new @_modelClass(parent._scope, data[@_field])
        else if (data[@_idField])
          data[@_field] = new @_modelClass(parent._scope, data[@_idField])
          delete data[@_idField]

      beforeSave: (data) ->
        if (data[@_field])
          if @_options.saveData
            data[@_field] = data[@_field].$dataToSave()
          else
            data[@_idField] = data[@_field].id
            delete data[@_field]
  ])

  .factory('HasManyAssociation', ['SoilCollection', (SoilCollection) ->
    class HasManyAssociation
      constructor: (@_field, @_idField, @_modelClass, options = {}) ->
        @_options = _.defaults(options, {
          saveData: false,
          nestedUpdate: false
        })

      beforeLoad: (data, parent) ->
        return if !data

        if (data[@_field])
          associationUrl = parent.$url(data.id || parent.id)  + '/' + @_field
          collection = new SoilCollection(parent._scope, @_modelClassFor(associationUrl), associationUrl)
          data[@_field] = collection.$load(data[@_field])
        else
          data[@_field] = new SoilCollection(parent._scope, @_modelClass)

      beforeSave: (data, parent) ->
        if (data[@_field])
          if @_options.saveData
            data[@_field] = _.map data[@_field].$members, (member) -> member.$dataToSave()
          else
            data[@_idField] = _.map data[@_field].$members, (member) -> member.id
            delete data[@_field]

      _modelClassFor: (url) ->
        if @_options.nestedUpdate
          class extendedModel extends @_modelClass
            _baseUrl: url
        else
          @_modelClass
  ])