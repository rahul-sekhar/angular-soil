describe 'soil.model module', ->
  beforeEach module 'soil.model'
  beforeEach module 'angular-mock-promise'

  describe 'soilModel', ->
    soilModel = httpBackend = instance = null
    beforeEach inject (_soilModel_, $httpBackend) ->
      httpBackend = $httpBackend
      soilModel = _soilModel_
      instance = new soilModel

    # Construction
    describe 'constructor', ->
      mockSoilModel = null
      beforeEach ->
        class mockSoilModel extends soilModel
          load: jasmine.createSpy('load')
          get: jasmine.createSpy('get')

      describe 'when passed nothing', ->
        beforeEach -> instance = new mockSoilModel

        it 'does not load or get data', ->
          expect(instance.load).not.toHaveBeenCalled()
          expect(instance.get).not.toHaveBeenCalled()

      describe 'when passed an integer', ->
        beforeEach -> instance = new mockSoilModel(15)

        it 'gets data from the server', ->
          expect(instance.get).toHaveBeenCalledWith(15)
          expect(instance.load).not.toHaveBeenCalled()

      describe 'when passed a string', ->
        beforeEach -> instance = new mockSoilModel('15')

        it 'gets data from the server', ->
          expect(instance.get).toHaveBeenCalledWith('15')
          expect(instance.load).not.toHaveBeenCalled()

      describe 'when passed an object', ->
        beforeEach -> instance = new mockSoilModel({ data: 'val' })

        it 'loads the object', ->
          expect(instance.load).toHaveBeenCalledWith({ data: 'val' })
          expect(instance.get).not.toHaveBeenCalled()

    # Default data
    describe '_baseUrl', ->
      it 'is the root by default', ->
        expect(instance._baseUrl).toBe('/')

    describe '_fieldsToSave', ->
      it 'is set to an empty array', ->
        expect(instance._fieldsToSave).toEqual([])

    describe '_associations', ->
      it 'is set to an empty array', ->
        expect(instance._associations).toEqual([])

    # Set the base url
    describe '#setBaseUrl', ->
      it 'can be used to set _baseUrl', ->
        instance.setBaseUrl('/new_path')
        expect(instance._baseUrl).toBe('/new_path')


    # Load data into the model
    describe '#load', ->
      result = null
      describe 'with data', ->
        beforeEach ->
          instance._associations = [{ beforeLoad: (data) -> data.field5 += ' changed by association' }]
          instance._private = 'private val'
          result = instance.load { field: 'new val', field5: 'another val' }

        it 'contains the passed data, modified by associations', ->
          expect(instance.field).toBe('new val')
          expect(instance.field5).toBe('another val changed by association')

        it 'clears old fields', ->
          expect(instance.field2).toBeUndefined()

        it 'does not clear private fields', ->
          expect(instance._private).toEqual('private val')

        it 'sets saved data, unmodified by associations', ->
          expect(instance.savedData).toEqual { field: 'new val', field5: 'another val' }

        it 'returns the instance', ->
          expect(result).toBe(instance)

      describe 'with null passed', ->
        beforeEach ->
          instance._private = 'private val'
          result = instance.load(null)

        it 'is cleared, except for private fields', ->
          expect(instance.field).toBeUndefined()
          expect(instance.field2).toBeUndefined()
          expect(instance._private).toEqual('private val')

        it 'clears saved data', ->
          expect(instance.savedData).toEqual {}

        it 'returns the instance', ->
          expect(result).toBe(instance)

    # Get, by passing an ID
    describe '#get', ->
      response = promise = null
      beforeEach inject (promiseExpectation) ->
        response = httpBackend.expectGET('/6')
        response.respond null
        spyOn(instance, 'load')
        promise = promiseExpectation(instance.get(6))

      it 'sends a GET request', ->
        httpBackend.verifyNoOutstandingExpectation()

      describe 'on success', ->
        beforeEach ->
          response.respond 'some data'
          httpBackend.flush()

        it 'loads the data', ->
          expect(instance.load).toHaveBeenCalledWith('some data')

        it 'resolves the promise', ->
          promise.expectToBeResolved()

      describe 'on failure', ->
        beforeEach ->
          response.respond 500
          httpBackend.flush()

        it 'does not load anything', ->
          expect(instance.load).not.toHaveBeenCalled()

        it 'rejects the promise', ->
          promise.expectToBeRejected()


    # Get model URL
    describe '#url', ->
      beforeEach -> instance.setBaseUrl('/model_path')

      describe 'without an id', ->
        it 'returns the base url', ->
          expect(instance.url()).toBe('/model_path')

      describe 'with an id', ->
        beforeEach -> instance.id = 56

        it 'returns the base url with the id', ->
          expect(instance.url()).toBe('/model_path/56')

      describe 'with a trailing slash and an id', ->
        beforeEach ->
          instance.setBaseUrl('/model_path/')
          instance.id = 56

        it 'returns the base url with the id', ->
          expect(instance.url()).toBe('/model_path/56')

      describe 'when passed an id as an integer', ->
        it 'returns the model url for that id', ->
          expect(instance.url(12)).toBe('/model_path/12')


    # Check if model is loaded
    describe '#loaded', ->
      describe 'without id set', ->
        it 'is false', ->
          expect(instance.loaded()).toBeFalsy()

      describe 'with an id set', ->
        beforeEach -> instance.id = 7

        it 'is true', ->
          expect(instance.loaded()).toBeTruthy()


    # Get data to be saved
    describe '#dataToSave', ->
      beforeEach ->
        instance._associations = [{ beforeSave: (data) ->
          data.field3 = data.field3 += ' association'
        }]
        instance._fieldsToSave = ['field', 'field3', 'field4']
        instance.field = 'new val'
        instance.field2 = 'other new val'
        instance.field3 = 'third new val'

      it 'selects fields to save and applies associations', ->
        expect(instance.dataToSave()).toEqual({ field: 'new val', field3: 'third new val association', field4: null })

    # Save the model
    describe '#save', ->
      request = promise = null
      beforeEach ->
        instance.setBaseUrl('/model_path')
        spyOn(instance, 'dataToSave').andReturn('save data')
        spyOn(instance, 'load')

      describe 'without an id', ->
        request = promise = null
        beforeEach inject (promiseExpectation) ->
          request = httpBackend.expectPOST('/model_path', 'save data')
          request.respond null
          promise = promiseExpectation(instance.save())

        it 'sends a POST request', ->
          httpBackend.verifyNoOutstandingExpectation()

        describe 'on success', ->
          beforeEach ->
            request.respond { field: 'formatted new val', field4: 'side effect' }
            httpBackend.flush()

          it 'loads the response data', ->
            expect(instance.load).toHaveBeenCalledWith { field: 'formatted new val', field4: 'side effect' }

          it 'resolves the promise', ->
            promise.expectToBeResolved()

        describe 'on failure', ->
          beforeEach ->
            request.respond 500
            httpBackend.flush()

          it 'does not load the response data', ->
            expect(instance.load).not.toHaveBeenCalled()

          it 'rejects the promise', ->
            promise.expectToBeRejected()

      describe 'with an id', ->
        beforeEach inject (promiseExpectation) ->
          instance.id = 5
          request = httpBackend.expectPUT('/model_path/5', 'save data')
          request.respond null
          promise = promiseExpectation(instance.save())

        it 'sends a PUT request', ->
          httpBackend.verifyNoOutstandingExpectation()

        describe 'on success', ->
          beforeEach ->
            request.respond { field: 'formatted new val', field4: 'side effect' }
            httpBackend.flush()

          it 'loads the response data', ->
            expect(instance.load).toHaveBeenCalledWith { field: 'formatted new val', field4: 'side effect' }

          it 'resolves the promise', ->
            promise.expectToBeResolved()

        describe 'on failure', ->
          beforeEach ->
            request.respond 500
            httpBackend.flush()

          it 'does not load the response data', ->
            expect(instance.load).not.toHaveBeenCalled()

          it 'rejects the promise', ->
            promise.expectToBeRejected()


    # Delete the model
    describe '#delete', ->
      describe 'without an id', ->
        it 'throws an error', ->
          expect(-> instance.delete()).toThrow()

      describe 'with an id', ->
        request = promise = null
        beforeEach inject (promiseExpectation) ->
          instance.id = 5
          request = httpBackend.expectDELETE('/5')
          request.respond null
          spyOn(instance, 'load')
          promise = promiseExpectation(instance.delete())

        it 'sends a DELETE request', ->
          httpBackend.verifyNoOutstandingExpectation()

        describe 'on success', ->
          beforeEach ->
            request.respond 'OK'
            httpBackend.flush()

          it 'clears all model data', ->
            expect(instance.load).toHaveBeenCalledWith(null)

          it 'resolves the promise', ->
            promise.expectToBeResolved()

        describe 'on failure', ->
          beforeEach ->
            request.respond 500
            httpBackend.flush()

          it 'does not clear model data', ->
            expect(instance.load).not.toHaveBeenCalled()

          it 'rejects the promise', ->
            promise.expectToBeRejected()


    # Update a single field
    describe '#updateField', ->
      describe 'without an id', ->
        it 'throws an error', ->
          expect(-> instance.updateField()).toThrow()

      describe 'with an id', ->
        request = promise = null
        beforeEach inject (promiseExpectation) ->
          instance.load { id: 5, field: 'val', field2: 'other val' }
          instance._associations = [{
            beforeSave: (data) -> data.field += ' association',
            beforeLoad: (data) -> data.field += ' association load'
          }]
          instance.field = 'updated val'
          request = httpBackend.expectPUT('/5', { field: 'updated val association' })
          request.respond null
          promise = promiseExpectation(instance.updateField('field'))

        it 'sends a PUT request', ->
          httpBackend.verifyNoOutstandingExpectation()

        describe 'on success', ->
          beforeEach ->
            request.respond { field: 'formatted updated val', other_field: 'other val' }
            httpBackend.flush()

          it 'sets the field to the response, modified by the association', ->
            expect(instance.field).toEqual('formatted updated val association load')

          it 'does not set other fields from the response', ->
            expect(instance.other_field).toBeUndefined()

          it 'replaces saved data with the response, unmodified by the association', ->
            expect(instance.savedData).toEqual { field: 'formatted updated val', other_field: 'other val' }

          it 'resolves the promise', ->
            promise.expectToBeResolved()

        describe 'on failure', ->
          beforeEach ->
            request.respond 500
            httpBackend.flush()

          it 'restores the field to the old saved data, modified by the association', ->
            expect(instance.field).toEqual('val association load')

          it 'rejects the promise', ->
            promise.expectToBeRejected()




