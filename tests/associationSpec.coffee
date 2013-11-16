describe 'soil.association module', ->
  beforeEach module 'soil.association'
  beforeEach module 'soil.model.mock'
  beforeEach module 'soil.collection.mock'

  describe 'hasOneAssociation', ->
    instance = soilModel = null
    beforeEach inject (hasOneAssociation, _soilModel_) ->
      soilModel = _soilModel_
      instance = new hasOneAssociation('association', soilModel)

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
          expect(data.association).toEqual(jasmine.any(soilModel))

        it 'loads data into that instance', ->
          expect(data.association.load).toHaveBeenCalledWith({ field: 'val' })

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')

      describe 'when an id is passed', ->
        beforeEach ->
          data = { association_id: 5, other_field: 'other val' }
          instance.beforeLoad(data)

        it 'creates a model instance', ->
          expect(data.association).toEqual(jasmine.any(soilModel))

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
        beforeEach inject (hasOneAssociation) ->
          data = { association: { dataToSave: -> 'model data' }, other_field: 'other val' }
          instance = new hasOneAssociation('association', soilModel, { saveData: true })
          instance.beforeSave(data)

        it 'replaces the association with its data', ->
          expect(data.association).toEqual('model data')

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')


  describe 'hasManyAssocation', ->
    instance = soilModel = parent = null
    beforeEach inject (hasManyAssociation, _soilModel_) ->
      soilModel = _soilModel_
      instance = new hasManyAssociation('associations', 'association_ids', soilModel)
      parent = { url: -> '/association_url' }

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
          data = { associations: 'association data', other_field: 'other val' }
          instance.beforeLoad(data, parent)

        it 'creates a collection', inject (soilCollection) ->
          expect(data.associations).toEqual(jasmine.any(soilCollection))

        it 'sets the model for the collection', ->
          expect(data.associations.modelClass).toEqual(soilModel)

        it 'sets the url for the collection', ->
          expect(data.associations._sourceUrl).toEqual('/association_url/associations')

        it 'loads data into that instance', ->
          expect(data.associations.load).toHaveBeenCalledWith('association data')

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
          data = { associations: { members: [{ id: 7 }, { id: 10 }, { id: 12 }] }, other_field: 'other val' }
          instance.beforeSave(data)

        it 'replaces the association with its ids', ->
          expect(data.association_ids).toEqual([7, 10, 12])
          expect(data.associations).toBeUndefined()

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')

      describe 'when the field is present, with the saveData option set', ->
        beforeEach inject (hasManyAssociation) ->
          data = { associations: { members: [
            { dataToSave: -> 'model 1 data' },
            { dataToSave: -> 'model 2 data' },
            { dataToSave: -> 'model 3 data' }
          ] }, other_field: 'other val' }

          instance = new hasManyAssociation('associations', 'association_ids', soilModel, { saveData: true })
          instance.beforeSave(data)

        it 'replaces the association with its data', ->
          expect(data.associations).toEqual(['model 1 data', 'model 2 data', 'model 3 data'])

        it 'leaves the other field intact', ->
          expect(data.other_field).toEqual('other val')


