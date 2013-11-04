describe 'soil.model module', ->
  beforeEach module 'soil.model'

  describe 'soilModel', ->
    soilModel = httpBackend = instance = null

    beforeEach inject (_soilModel_, $httpBackend) ->
      httpBackend = $httpBackend
      soilModel = _soilModel_
      instance = new soilModel { field: 'val', field2: 'other val' }

    # Construction
    describe 'construction', ->
      mockSoilModel = null

      beforeEach ->
        class mockSoilModel extends soilModel
          _getById: jasmine.createSpy('_getById')
          _load: jasmine.createSpy('_load')

      describe 'when constructed with an object', ->
        beforeEach -> instance = new mockSoilModel( { field: 'data' })

        it 'loads the data', ->
          expect(instance._load).toHaveBeenCalledWith({ field: 'data' })

      describe 'when constructed with an integer', ->
        beforeEach -> instance = new mockSoilModel(12)

        it 'gets data by ID', ->
          expect(instance._getById).toHaveBeenCalledWith(12)

      describe 'when constructed with a string', ->
        beforeEach -> instance = new mockSoilModel('12')

        it 'gets data by ID', ->
          expect(instance._getById).toHaveBeenCalledWith('12')

      describe 'when constructed with no arguments', ->
        beforeEach -> instance = new mockSoilModel

        it 'does nothing', ->
          expect(instance._load).not.toHaveBeenCalled()
          expect(instance._getById).not.toHaveBeenCalled()

    describe '_base_url', ->
      it 'is the root by default', ->
        expect(instance._base_url).toBe('/')


    # Load from ID
    describe '#_getById', ->
      response = null

      beforeEach ->
        response = httpBackend.expectGET('/6')
        response.respond null
        instance._getById(6)
        spyOn(instance, '_load')

      it 'sends a GET request', ->
        httpBackend.verifyNoOutstandingExpectation()

      describe 'on success', ->
        beforeEach ->
          response.respond 'some data'
          httpBackend.flush()

        it 'loads the data', ->
          expect(instance._load).toHaveBeenCalledWith('some data')

      describe 'on error', ->
        beforeEach ->
          response.respond 500
          httpBackend.flush()

        it 'does not load anything', ->
          expect(instance._load).not.toHaveBeenCalled()


    # Check if model is loaded

    describe '#isLoaded', ->
      describe 'without id set', ->
        it 'is false', ->
          expect(instance.isLoaded()).toBeFalsy()

      describe 'with an id set', ->
        beforeEach -> instance.id = 7

        it 'is true', ->
          expect(instance.isLoaded()).toBeTruthy()


    # Load data into model

    describe '#_load', ->
      describe 'with data', ->
        beforeEach ->
          instance._private = 'private val'
          instance._load { field: 'new val', field5: 'another val' }

        it 'contains the passed data', ->
          expect(instance.field).toBe('new val')
          expect(instance.field5).toBe('another val')

        it 'clears old fields', ->
          expect(instance.field2).toBeUndefined()

        it 'does not clear private fields', ->
          expect(instance._private).toEqual('private val')

        it 'sets saved data', ->
          expect(instance._saved_data).toEqual { field: 'new val', field5: 'another val' }

      describe 'with no data', ->
        beforeEach ->
          instance._private = 'private val'
          instance._load()

        it 'is cleared, except for private fields', ->
          expect(instance.field).toBeUndefined()
          expect(instance.field2).toBeUndefined()
          expect(instance._private).toEqual('private val')

        it 'clears saved data', ->
          expect(instance._saved_data).toEqual {}


    # Get model URL

    describe '#url', ->
      beforeEach -> instance._base_url = '/model_path'

      describe 'when not loaded', ->
        it 'returns the base url', ->
          expect(instance.url()).toBe('/model_path')

      describe 'when loaded', ->
        beforeEach -> instance.id = 56

        it 'returns the base url with the id', ->
          expect(instance.url()).toBe('/model_path/56')

      describe 'with a trailing slash and an id', ->
        beforeEach ->
          instance._base_url = '/model_path/'
          instance.id = 56

        it 'returns the base url with the id', ->
          expect(instance.url()).toBe('/model_path/56')

      describe 'when passed an id as an integer', ->
        it 'returns the model url for that id', ->
          expect(instance.url(12)).toBe('/model_path/12')

    # Update a single field

    describe '#updateField', ->
      describe 'when not loaded', ->
        it 'throws an error', ->
          expect(instance.updateField).toThrow('Cannot update model without an ID')

      describe 'when loaded', ->
        request = null

        beforeEach ->
          instance.id = 5
          instance.field = 'updated val'
          request = httpBackend.expectPUT('/5', { field: 'updated val' })
          request.respond null
          instance.updateField('field')

        it 'sends a PUT request', ->
          httpBackend.verifyNoOutstandingExpectation()

        describe 'on success', ->
          beforeEach ->
            request.respond { field: 'formatted updated val', other_field: 'other val' }
            httpBackend.flush()

          it 'sets the field to the response', ->
            expect(instance.field).toEqual('formatted updated val')

          it 'does not set other fields from the response', ->
            expect(instance.other_field).toBeUndefined()

          it 'replaces saved data with the response', ->
            expect(instance._saved_data).toEqual { field: 'formatted updated val', other_field: 'other val' }

        describe 'on error', ->
          beforeEach ->
            request.respond 500
            httpBackend.flush()

          it 'restores the field to the old saved data', ->
            expect(instance.field).toEqual('val')