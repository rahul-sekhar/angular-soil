describe 'soil.model module', ->
  beforeEach module 'soil.model'

  describe 'soilModel', ->
    soilModel = httpBackend = instance = null

    beforeEach inject (_soilModel_, $httpBackend) ->
      httpBackend = $httpBackend
      soilModel = _soilModel_
      instance = new soilModel { field: 'val', field2: 'other val' }

    it 'contains the data passed to the constructor', ->
      expect(instance.field).toBe('val')
      expect(instance.field2).toBe('other val')

    describe '_base_url', ->
      it 'is the root by default', ->
        expect(instance._base_url).toBe('/')

    describe '#load', ->
      describe 'with data', ->
        beforeEach ->
          instance._private = 'private val'
          instance.load { field: 'new val', field5: 'another val' }

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
          instance.load()

        it 'is cleared, except for private fields', ->
          expect(instance.field).toBeUndefined()
          expect(instance.field2).toBeUndefined()
          expect(instance._private).toEqual('private val')

        it 'clears saved data', ->
          expect(instance._saved_data).toEqual {}

    describe '#url', ->
      beforeEach -> instance._base_url = '/model_path'

      describe 'without an id', ->
        it 'returns the base url', ->
          expect(instance.url()).toBe('/model_path')

      describe 'with an id', ->
        beforeEach -> instance.id = 56

        it 'returns the base url with the id', ->
          expect(instance.url()).toBe('/model_path/56')

      describe 'with a trailing slash and an id', ->
        beforeEach ->
          instance._base_url = '/model_path/'
          instance.id = 56

        it 'returns the base url with the id', ->
          expect(instance.url()).toBe('/model_path/56')

    describe '#refresh', ->
      describe 'without an id', ->
        it 'throws an error', ->
          expect(instance.refresh).toThrow('Cannot refresh model without an ID')

      describe 'with an id', ->
        request = null

        beforeEach ->
          instance.id = 5
          request = httpBackend.expectGET('/5')
          request.respond null
          spyOn(instance, 'load')
          instance.refresh()

        it 'sends a GET request', ->
          httpBackend.verifyNoOutstandingExpectation()

        describe 'on success', ->
          beforeEach ->
            request.respond 'some data'
            httpBackend.flush()

          it 'loads the response data', ->
            expect(instance.load).toHaveBeenCalledWith 'some data'

        describe 'on error', ->
          beforeEach ->
            request.respond 500
            httpBackend.flush()

          it 'does not load data', ->
            expect(instance.load).not.toHaveBeenCalled()

    describe '#updateField', ->
      describe 'without an id', ->
        it 'throws an error', ->
          expect(instance.updateField).toThrow('Cannot update model without an ID')

      describe 'with an id', ->
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