describe 'soil.association module', ->
  beforeEach module 'soil.association'
  beforeEach module 'soil.model.mock'
  beforeEach module 'soil.collection.mock'

  describe 'HasOneAssociation', ->
    instance = SoilModel = parent = scope = null
    beforeEach inject (HasOneAssociation, _SoilModel_, $rootScope) ->
      SoilModel = _SoilModel_
      instance = new HasOneAssociation('association', SoilModel)
      scope = $rootScope.$new()
      parent = new SoilModel(scope)

    # Modify data before loading it
    describe '#beforeLoad', ->
      data = null
      describe 'when the field is not present in the passed data', ->
        beforeEach ->
          data = { other_field: 'other val' }
          instance.beforeLoad(data, parent)

        it 'does nothing to the data', ->
          expect(data).toEqual { other_field: 'other val' }

      describe 'when null is passed', ->
        beforeEach ->
          data = null
          instance.beforeLoad(data, parent)

        it 'does nothing to the data', ->
          expect(data).toBeNull()

      describe 'when association data is passed', ->
        beforeEach ->
          data = { association: { field: 'val' }, other_field: 'other val' }
          instance.beforeLoad(data, parent)

        it 'creates a model instance', ->
          expect(data.association).toEqual(jasmine.any(SoilModel))

        it 'loads data into that instance', ->
          expect(data.association.$load).toHaveBeenCalledWith({ field: 'val' })

        it 'sets the instance scope', ->
          expect(data.association._scope).toBe(scope)

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')

      describe 'when an id is passed', ->
        beforeEach ->
          data = { association_id: 5, other_field: 'other val' }
          instance.beforeLoad(data, parent)

        it 'creates a model instance', ->
          expect(data.association).toEqual(jasmine.any(SoilModel))

        it 'gets the instance by id', ->
          expect(data.association.$get).toHaveBeenCalledWith(5)

        it 'removes the association id field', ->
          expect(data.association_id).toBeUndefined()

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')


    # Modify data before saving it
    describe '#beforeSave', ->
      data = null

      describe 'when the field is not present in the passed data', ->
        beforeEach ->
          data = { other_field: 'other val' }
          instance.beforeSave(data, parent)

        it 'does nothing to the data', ->
          expect(data).toEqual { other_field: 'other val' }

      describe 'when the field is present', ->
        beforeEach ->
          data = { association: { id: 7 }, other_field: 'other val' }
          instance.beforeSave(data, parent)

        it 'replaces the association with its id', ->
          expect(data.association_id).toEqual(7)
          expect(data.association).toBeUndefined()

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')

      describe 'when the field is present, with the saveData option set', ->
        beforeEach inject (HasOneAssociation) ->
          data = { association: { $dataToSave: -> 'model data' }, other_field: 'other val' }
          instance = new HasOneAssociation('association', SoilModel, { saveData: true })
          instance.beforeSave(data, parent)

        it 'replaces the association with its data', ->
          expect(data.association).toEqual('model data')

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')


  describe 'hasManyAssocation', ->
    instance = SoilModel = parent = scope = null
    beforeEach inject (HasManyAssociation, _SoilModel_, $rootScope) ->
      SoilModel = _SoilModel_
      instance = new HasManyAssociation('associations', 'association_ids', SoilModel)

      scope = $rootScope.$new()
      parent = new SoilModel(scope)
      parent.$setBaseUrl('/association_url')

    # Modify data before loading it
    describe '#beforeLoad', ->
      data = null

      itAddsACollection = ->
        it 'creates a collection', inject (SoilCollection) ->
          expect(data.associations).toEqual(jasmine.any(SoilCollection))

        it 'sets the model for the collection', ->
          expect(data.associations.modelClass).toEqual(SoilModel)

        it 'sets the collection scope', ->
          expect(data.associations._scope).toBe(scope)

      describe 'when the field is not present in the passed data', ->
        beforeEach ->
          data = { other_field: 'other val' }
          instance.beforeLoad(data, parent)

        itAddsACollection()

        it 'does not load data', ->
          expect(data.associations.$load).not.toHaveBeenCalled()

        it 'leaves the other data intact', ->
          expect(data.other_field).toEqual('other val')

      describe 'when an empty object is passed', ->
        beforeEach ->
          data = { }
          instance.beforeLoad(data, parent)

        itAddsACollection()

        it 'does not load data', ->
          expect(data.associations.$load).not.toHaveBeenCalled()

      describe 'when null is passed', ->
        beforeEach ->
          data = null
          instance.beforeLoad(data, parent)

        it 'does nothing to the data', ->
          expect(data).toBeNull()

      describe 'when association data is passed', ->
        beforeEach ->
          data = { associations: 'association data', other_field: 'other val', id: 6 }
          instance.beforeLoad(data, parent)

        itAddsACollection()

        it 'does not change the model base url', ->
          instance = new data.associations.modelClass()
          expect(instance._baseUrl).toEqual('/')

        it 'sets the url for the collection', ->
          expect(data.associations.sourceUrl).toEqual('/association_url/6/associations')

        it 'loads data into that instance', ->
          expect(data.associations.$load).toHaveBeenCalledWith('association data')

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')

      describe 'with the nestedUpdate option set', ->
        beforeEach inject (HasManyAssociation) ->
          instance = new HasManyAssociation('associations', 'association_ids', SoilModel, { nestedUpdate: true })
          data = { associations: 'association data', other_field: 'other val', id: 6 }
          instance.beforeLoad(data, parent)

        it 'sets the model base url to the collection url', ->
          instance = new data.associations.modelClass()
          expect(instance._baseUrl).toEqual('/association_url/6/associations')

        it 'loads data into the instance', ->
          expect(data.associations.$load).toHaveBeenCalledWith('association data')

      describe 'when the parent has an id', ->
        beforeEach ->
          parent.id = 4
          data = { associations: 'association data', other_field: 'other val' }
          instance.beforeLoad(data, parent)

        it 'sets the url for the collection', ->
          expect(data.associations.sourceUrl).toEqual('/association_url/4/associations')


    # Modify data before saving it
    describe '#beforeSave', ->
      data = null
      describe 'when the field is not present in the passed data', ->
        beforeEach ->
          data = { other_field: 'other val' }
          instance.beforeSave(data, parent)

        it 'does nothing to the data', ->
          expect(data).toEqual { other_field: 'other val' }

      describe 'when the field is present', ->
        beforeEach ->
          data = { associations: { $members: [{ id: 7 }, { id: 10 }, { id: 12 }] }, other_field: 'other val' }
          instance.beforeSave(data, parent)

        it 'replaces the association with its ids', ->
          expect(data.association_ids).toEqual([7, 10, 12])
          expect(data.associations).toBeUndefined()

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')

      describe 'when the field is present, with the saveData option set', ->
        beforeEach inject (HasManyAssociation) ->
          data = { associations: { $members: [
            { $dataToSave: -> 'model 1 data' },
            { $dataToSave: -> 'model 2 data' },
            { $dataToSave: -> 'model 3 data' }
          ] }, other_field: 'other val' }

          instance = new HasManyAssociation('associations', 'association_ids', SoilModel, { saveData: true })
          instance.beforeSave(data, parent)

        it 'replaces the association with its data', ->
          expect(data.associations).toEqual(['model 1 data', 'model 2 data', 'model 3 data'])

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')


