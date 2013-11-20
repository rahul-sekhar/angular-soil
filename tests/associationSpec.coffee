describe 'soil.association module', ->
  beforeEach module 'soil.association'
  beforeEach module 'soil.model.mock'
  beforeEach module 'soil.collection.mock'

  describe 'HasOneAssociation', ->
    instance = SoilModel = null
    beforeEach inject (HasOneAssociation, _SoilModel_) ->
      SoilModel = _SoilModel_
      instance = new HasOneAssociation('association', SoilModel)

    # Modify data before loading it
    describe '#beforeLoad', ->
      data = null

      describe 'when the field is not present in the passed data', ->
        beforeEach ->
          data = { other_field: 'other val' }
          instance.beforeLoad(data)

        it 'does nothing to the data', ->
          expect(data).toEqual { other_field: 'other val' }

      describe 'when association data is passed', ->
        beforeEach ->
          data = { association: { field: 'val' }, other_field: 'other val' }
          instance.beforeLoad(data)

        it 'creates a model instance', ->
          expect(data.association).toEqual(jasmine.any(SoilModel))

        it 'loads data into that instance', ->
          expect(data.association.load).toHaveBeenCalledWith({ field: 'val' })

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')

      describe 'when an id is passed', ->
        beforeEach ->
          data = { association_id: 5, other_field: 'other val' }
          instance.beforeLoad(data)

        it 'creates a model instance', ->
          expect(data.association).toEqual(jasmine.any(SoilModel))

        it 'gets the instance by id', ->
          expect(data.association.get).toHaveBeenCalledWith(5)

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
          instance.beforeSave(data)

        it 'does nothing to the data', ->
          expect(data).toEqual { other_field: 'other val' }

      describe 'when the field is present', ->
        beforeEach ->
          data = { association: { id: 7 }, other_field: 'other val' }
          instance.beforeSave(data)

        it 'replaces the association with its id', ->
          expect(data.association_id).toEqual(7)
          expect(data.association).toBeUndefined()

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')

      describe 'when the field is present, with the saveData option set', ->
        beforeEach inject (HasOneAssociation) ->
          data = { association: { dataToSave: -> 'model data' }, other_field: 'other val' }
          instance = new HasOneAssociation('association', SoilModel, { saveData: true })
          instance.beforeSave(data)

        it 'replaces the association with its data', ->
          expect(data.association).toEqual('model data')

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')


  describe 'hasManyAssocation', ->
    instance = SoilModel = parent = null
    beforeEach inject (HasManyAssociation, _SoilModel_) ->
      SoilModel = _SoilModel_
      instance = new HasManyAssociation('associations', 'association_ids', SoilModel)
      parent = { url: (id) -> '/association_url/' + id }

    # Modify data before loading it
    describe '#beforeLoad', ->
      data = null
      describe 'when the field is not present in the passed data', ->
        beforeEach ->
          data = { other_field: 'other val' }
          instance.beforeLoad(data, parent)

        it 'does nothing to the data', ->
          expect(data).toEqual { other_field: 'other val' }

      describe 'when association data is passed', ->
        beforeEach ->
          data = { associations: 'association data', other_field: 'other val', id: 6 }
          instance.beforeLoad(data, parent)

        it 'creates a collection', inject (SoilCollection) ->
          expect(data.associations).toEqual(jasmine.any(SoilCollection))

        it 'sets the model for the collection', ->
          expect(data.associations.modelClass).toEqual(SoilModel)

        it 'sets the url for the collection', ->
          expect(data.associations._sourceUrl).toEqual('/association_url/6/associations')

        it 'loads data into that instance', ->
          expect(data.associations.load).toHaveBeenCalledWith('association data')

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')

      describe 'when the parent has an id', ->
        beforeEach ->
          parent.id = 4
          data = { associations: 'association data', other_field: 'other val' }
          instance.beforeLoad(data, parent)

        it 'sets the url for the collection', ->
          expect(data.associations._sourceUrl).toEqual('/association_url/4/associations')


    # Modify data before saving it
    describe '#beforeSave', ->
      data = null
      describe 'when the field is not present in the passed data', ->
        beforeEach ->
          data = { other_field: 'other val' }
          instance.beforeSave(data)

        it 'does nothing to the data', ->
          expect(data).toEqual { other_field: 'other val' }

      describe 'when the field is present', ->
        beforeEach ->
          data = { associations: { members: [{ id: 7 }, { id: 10 }, { id: 12 }] }, other_field: 'other val' }
          instance.beforeSave(data)

        it 'replaces the association with its ids', ->
          expect(data.association_ids).toEqual([7, 10, 12])
          expect(data.associations).toBeUndefined()

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')

      describe 'when the field is present, with the saveData option set', ->
        beforeEach inject (HasManyAssociation) ->
          data = { associations: { members: [
            { dataToSave: -> 'model 1 data' },
            { dataToSave: -> 'model 2 data' },
            { dataToSave: -> 'model 3 data' }
          ] }, other_field: 'other val' }

          instance = new HasManyAssociation('associations', 'association_ids', SoilModel, { saveData: true })
          instance.beforeSave(data)

        it 'replaces the association with its data', ->
          expect(data.associations).toEqual(['model 1 data', 'model 2 data', 'model 3 data'])

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')


