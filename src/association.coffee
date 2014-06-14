angular.module('soil.association', ['soil.collection'])

  .factory('HasOneAssociation', ['$injector', ($injector) ->
    class HasOneAssociation
      constructor: (@_field, modelClass, options = {}) ->
        @_options = _.defaults(options, {
          saveData: false
        })
        @_modelClass = $injector.get(modelClass)
        @_idField = @_field + '_id'

      beforeLoad: (data, parent) ->
        return if !data

        if (data[@_field])
          data[@_field] = @_createModelInstance(parent, data[@_field])
        else if (data[@_idField])
          data[@_field] = @_createModelInstance(parent, data[@_idField])
          delete data[@_idField]

      beforeSave: (data) ->
        if (data[@_field])
          if @_options.saveData
            id = data[@_field].id
            data[@_field] = data[@_field].$dataToSave()
            data[@_field].id = id
          else
            data[@_idField] = data[@_field].id
            delete data[@_field]

        else if data[@_field] != undefined
          unless @_options.saveData
            data[@_idField] = null
            delete data[@_field]

      setScope: (scope, parent) ->
        if parent[@_field]
          parent[@_field].$setScope scope

      _createModelInstance: (parent, data) ->
        model = new @_modelClass(parent._scope, data)
        model._parent = parent
        return model

  ])

  .factory('HasManyAssociation', ['SoilCollection', '$injector', (SoilCollection, $injector) ->
    class HasManyAssociation
      constructor: (@_field, @_idField, modelClass, options = {}) ->
        @_options = _.defaults(options, {
          saveData: false,
          nestedUpdate: false
        })
        @_modelClass = $injector.get(modelClass)

      beforeLoad: (data, parent) ->
        return if !data
        associationUrl = parent.$url(data.slug || data.id || parent.slug || parent.id)  + '/' + @_field

        if (data[@_field])
          collection = @_createCollection(parent, @_modelClassFor(associationUrl), associationUrl)
          data[@_field] = collection.$load(data[@_field])
        else
          data[@_field] = @_createCollection(parent, @_modelClass, associationUrl)

      beforeSave: (data, parent) ->
        if (data[@_field])
          if @_options.saveData
            data[@_field] = _.map data[@_field].$members, (member) ->
              _.merge { id: member.id }, member.$dataToSave()
          else
            data[@_idField] = _.map data[@_field].$members, (member) -> member.id
            delete data[@_field]

      setScope: (scope, parent) ->
        if parent[@_field]
          parent[@_field].$setScope scope

      _modelClassFor: (url) ->
        if @_options.nestedUpdate
          class extendedModel extends @_modelClass
            _baseUrl: url
        else
          @_modelClass

      _createCollection: (parent, modelClass, url) ->
        collection = new SoilCollection(parent._scope, modelClass, url)
        collection._parent = parent
        return collection
  ])