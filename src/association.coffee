angular.module('soil.association', ['soil.collection'])

  .factory('hasOneAssociation', [ ->
    class hasOneAssociation
      constructor: (@_field, @_modelClass, options = {}) ->
        @_options = _.defaults(options, {
          saveData: false
        })
        @_idField = @_field + '_id'

      beforeLoad: (data) ->
        if (data[@_field])
          data[@_field] = new @_modelClass(data[@_field])
        else if (data[@_idField])
          data[@_field] = new @_modelClass(data[@_idField])
          delete data[@_idField]

      beforeSave: (data) ->
        if (data[@_field])
          if @_options.saveData
            data[@_field] = data[@_field].dataToSave()
          else
            data[@_idField] = data[@_field].id
            delete data[@_field]
  ])

  .factory('hasManyAssociation', ['soilCollection', (soilCollection) ->
    class hasManyAssociation
      constructor: (@_field, @_idField, @_modelClass, options = {}) ->
        @_options = _.defaults(options, {
          saveData: false
        })

      beforeLoad: (data, parent) ->
        if (data[@_field])
          parentUrl = parent.url(data.id || parent.id)
          collection = new soilCollection(@_modelClass, parentUrl + '/' + @_field)
          data[@_field] = collection.load(data[@_field])

      beforeSave: (data) ->
        if (data[@_field])
          if @_options.saveData
            data[@_field] = _.map data[@_field].members, (member) -> member.dataToSave()
          else
            data[@_idField] = _.map data[@_field].members, (member) -> member.id
            delete data[@_field]
  ])