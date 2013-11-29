describe 'soil.model module', ->
  beforeEach module 'soil.model'
  beforeEach module 'angular-mock-promise'

  describe 'SoilModel', ->
    SoilModel = httpBackend = instance = rootScope = null
    beforeEach inject (_SoilModel_, $httpBackend, $rootScope) ->
      dataLoadedCallback = jasmine.createSpy('data loaded')
      rootScope = $rootScope
      httpBackend = $httpBackend
      SoilModel = _SoilModel_
      instance = new SoilModel

    # Construction
    describe 'constructor', ->
      mockSoilModel = null
      beforeEach ->
        class mockSoilModel extends SoilModel
          $load: jasmine.createSpy('$load')
          $get: jasmine.createSpy('$get')

      describe 'when passed nothing', ->
        beforeEach -> instance = new mockSoilModel(null)

        it 'loads a blank object', ->
          expect(instance.$load).toHaveBeenCalledWith({})
          expect(instance.$get).not.toHaveBeenCalled()

      describe 'when passed an integer', ->
        beforeEach -> instance = new mockSoilModel(null, 15)

        it 'gets data from the server', ->
          expect(instance.$get).toHaveBeenCalledWith(15)
          expect(instance.$load).not.toHaveBeenCalled()

      describe 'when passed a string', ->
        beforeEach -> instance = new mockSoilModel(null, '15')

        it 'gets data from the server', ->
          expect(instance.$get).toHaveBeenCalledWith('15')
          expect(instance.$load).not.toHaveBeenCalled()

      describe 'when passed an object', ->
        beforeEach -> instance = new mockSoilModel(null, { data: 'val' })

        it 'loads the object', ->
          expect(instance.$load).toHaveBeenCalledWith({ data: 'val' })
          expect(instance.$get).not.toHaveBeenCalled()

      describe 'when passed a scope', ->
        scope = null
        beforeEach ->
          scope = rootScope.$new()
          instance = new mockSoilModel(scope)

        it 'saves the scope', ->
          expect(instance._scope).toBe(scope)

    # Default data
    describe '_baseUrl', ->
      it 'is the root by default', ->
        expect(instance._baseUrl).toBe('/')

    describe '_fieldsToSave', ->
      it 'is set to an empty array', ->
        expect(instance._fieldsToSave).toEqual([])

    describe '_fieldsToSaveOnCreate', ->
      it 'is set to an empty array', ->
        expect(instance._fieldsToSaveOnCreate).toEqual([])

    describe '_associations', ->
      it 'is set to an empty array', ->
        expect(instance._associations).toEqual([])

    describe '_modelType', ->
      it 'is set to a default type', ->
        expect(instance._modelType).toEqual('model')

    describe '$saved', ->
      it 'is set to an empty object', ->
        expect(instance.$saved).toEqual({})

    # Set the base url
    describe '#$setBaseUrl', ->
      it 'can be used to set _baseUrl', ->
        instance.$setBaseUrl('/new_path')
        expect(instance._baseUrl).toBe('/new_path')

    # Set a post url
    describe '#$setPostUrl', ->
      it 'can be used to set _postUrl', ->
        instance.$setPostUrl('/new_path')
        expect(instance._postUrl).toBe('/new_path')


    # Load data into the model
    describe '#$load', ->
      result = dataLoadedCallback = null
      describe 'with data', ->
        beforeEach ->
          instance.url = -> '/some_path'
          instance._associations = [{ beforeLoad: (data, parent) -> data.field5 += ' changed by association. url: ' + parent.url() }]
          instance._private = 'private val'
          instance.someFunction = -> 'Some return value'
          dataLoadedCallback = jasmine.createSpy('data loaded')
          instance.$onDataLoaded dataLoadedCallback
          result = instance.$load { field: 'new val', field5: 'another val' }

        it 'contains the passed data, modified by associations', ->
          expect(instance.field).toBe('new val')
          expect(instance.field5).toBe('another val changed by association. url: /some_path')

        it 'clears old fields', ->
          expect(instance.field2).toBeUndefined()

        it 'does not clear private fields', ->
          expect(instance._private).toEqual('private val')

        it 'does not clear functions', ->
          expect(instance.someFunction).toBeTruthy()

        it 'sets saved data, unmodified by associations', ->
          expect(instance.$saved).toEqual { field: 'new val', field5: 'another val' }

        it 'returns the instance', ->
          expect(result).toBe(instance)

        it 'calls the data loaded callback', ->
          expect(dataLoadedCallback).toHaveBeenCalled()

      describe 'with null passed', ->
        beforeEach ->
          instance._private = 'private val'
          result = instance.$load(null)

        it 'is cleared, except for private fields', ->
          expect(instance.field).toBeUndefined()
          expect(instance.field2).toBeUndefined()
          expect(instance._private).toEqual('private val')

        it 'clears saved data', ->
          expect(instance.$saved).toEqual {}

        it 'returns the instance', ->
          expect(result).toBe(instance)

        it 'calls the data loaded callback', ->
          expect(dataLoadedCallback).toHaveBeenCalled()

    # Get, by passing an ID
    describe '#$get', ->
      response = promise = null
      beforeEach inject (promiseExpectation) ->
        response = httpBackend.expectGET('/6')
        response.respond null
        spyOn(instance, '$load')
        promise = promiseExpectation(instance.$get(6))

      it 'sends a GET request', ->
        httpBackend.verifyNoOutstandingExpectation()

      describe 'on success', ->
        beforeEach ->
          response.respond 'some data'
          httpBackend.flush()

        it 'loads the data', ->
          expect(instance.$load).toHaveBeenCalledWith('some data')

        it 'resolves the promise', ->
          promise.expectToBeResolved()

      describe 'on failure', ->
        beforeEach ->
          response.respond 500
          httpBackend.flush()

        it 'does not load anything', ->
          expect(instance.$load).not.toHaveBeenCalled()

        it 'rejects the promise', ->
          promise.expectToBeRejected()


    # Get model URL
    describe '#$url', ->
      beforeEach -> instance.$setBaseUrl('/model_path')

      describe 'without an id', ->
        it 'returns the base url', ->
          expect(instance.$url()).toBe('/model_path')

      describe 'with an id', ->
        beforeEach -> instance.id = 56

        it 'returns the base url with the id', ->
          expect(instance.$url()).toBe('/model_path/56')

      describe 'with a trailing slash and an id', ->
        beforeEach ->
          instance.$setBaseUrl('/model_path/')
          instance.id = 56

        it 'returns the base url with the id', ->
          expect(instance.$url()).toBe('/model_path/56')

      describe 'when passed an id as an integer', ->
        it 'returns the model url for that id', ->
          expect(instance.$url(12)).toBe('/model_path/12')

      describe 'with postUrl set', ->
        beforeEach -> instance.$setPostUrl('/model_source')

        describe 'without an id', ->
          it 'returns the source url', ->
            expect(instance.$url()).toBe('/model_source')

        describe 'with an id', ->
          beforeEach -> instance.id = 56

          it 'returns the base url with the id', ->
            expect(instance.$url()).toBe('/model_path/56')


    # Get data to be saved
    describe '#$dataToSave', ->
      beforeEach ->
        instance.$url = -> '/some_path'
        instance._associations = [{ beforeSave: (data, parent) ->
          data.field3 += ' association. url: ' + parent.$url()
          if data.field5
            data.field5 += ' assoc'
        }]
        instance._fieldsToSave = ['field', 'field3', 'field4']
        instance._fieldsToSaveOnCreate = ['field5', 'field6']
        instance.field = 'new val'
        instance.field2 = 'other new val'
        instance.field3 = 'third new val'
        instance.field5 = 'create val'
        instance.field6 = 'other create val'

      describe 'on create', ->
        it 'selects fields to save and fields to create and applies associations', ->
          expect(instance.$dataToSave()).toEqual({
            field: 'new val',
            field3: 'third new val association. url: /some_path',
            field4: null,
            field5: 'create val assoc',
            field6: 'other create val'
          })

      describe 'on update', ->
        beforeEach -> instance.id = 21

        it 'selects fields to save and applies associations', ->
          expect(instance.$dataToSave()).toEqual({
            field: 'new val',
            field3: 'third new val association. url: /some_path',
            field4: null
          })


    # Save the model
    describe '#$save', ->
      request = promise = saveSpy = null
      beforeEach ->
        instance.$setBaseUrl('/model_path')
        spyOn(instance, '$dataToSave').andReturn('save data')
        spyOn(instance, '$load')

        saveSpy = jasmine.createSpy('rootScope save watcher')
        rootScope.$on('modelSaved', saveSpy)

      runSaveTests = ->
        it 'sends a request', ->
          httpBackend.verifyNoOutstandingExpectation()

        describe 'on success', ->
          beforeEach ->
            request.respond { field: 'formatted new val', field4: 'side effect' }
            httpBackend.flush()

          it 'loads the response data', ->
            expect(instance.$load).toHaveBeenCalledWith { field: 'formatted new val', field4: 'side effect' }

          it 'resolves the promise', ->
            promise.expectToBeResolved()

          it 'broadcasts an event', ->
            expect(saveSpy).toHaveBeenCalled()

          it 'sends itself in the event', ->
            expect(saveSpy.mostRecentCall.args[1]).toBe(instance)

          it 'sends the response data in the event', ->
            expect(saveSpy.mostRecentCall.args[2]).toEqual({ field: 'formatted new val', field4: 'side effect' })

        describe 'on failure', ->
          beforeEach ->
            request.respond 500
            httpBackend.flush()

          it 'does not load the response data', ->
            expect(instance.$load).not.toHaveBeenCalled()

          it 'rejects the promise', ->
            promise.expectToBeRejected()

          it 'does not broadcast an event', ->
            expect(saveSpy).not.toHaveBeenCalled()

      describe 'without an id', ->
        beforeEach inject (promiseExpectation) ->
          request = httpBackend.expectPOST('/model_path', 'save data')
          request.respond null
          promise = promiseExpectation(instance.$save())

        runSaveTests()

      describe 'with an id', ->
        beforeEach inject (promiseExpectation) ->
          instance.id = 5
          request = httpBackend.expectPUT('/model_path/5', 'save data')
          request.respond null
          promise = promiseExpectation(instance.$save())

        runSaveTests()

    # Delete the model
    describe '#$delete', ->
      describe 'without an id', ->
        it 'throws an error', ->
          expect(-> instance.$delete()).toThrow()

      describe 'with an id', ->
        request = promise = deleteSpy = null
        beforeEach inject (promiseExpectation) ->
          instance.id = 5
          instance._modelType = 'a particular model'
          request = httpBackend.expectDELETE('/5')
          request.respond null
          spyOn(instance, '$load')
          promise = promiseExpectation(instance.$delete())

          deleteSpy = jasmine.createSpy('rootScope delete watcher')
          rootScope.$on('modelDeleted', deleteSpy)

        it 'sends a DELETE request', ->
          httpBackend.verifyNoOutstandingExpectation()

        describe 'on success', ->
          beforeEach ->
            request.respond 'OK'
            httpBackend.flush()

          it 'clears all model data', ->
            expect(instance.$load).toHaveBeenCalledWith(null)

          it 'resolves the promise', ->
            promise.expectToBeResolved()

          it 'broadcasts an event', ->
            expect(deleteSpy).toHaveBeenCalled()

          it 'sends its type in the event', ->
            expect(deleteSpy.mostRecentCall.args[1]).toEqual('a particular model')

          it 'sends its id in the event', ->
            expect(deleteSpy.mostRecentCall.args[2]).toEqual(5)

        describe 'on failure', ->
          beforeEach ->
            request.respond 500
            httpBackend.flush()

          it 'does not clear model data', ->
            expect(instance.$load).not.toHaveBeenCalled()

          it 'rejects the promise', ->
            promise.expectToBeRejected()

          it 'does not broadcast an event', ->
            expect(deleteSpy).not.toHaveBeenCalled()


    # Load a single field from data
    describe '#_loadField', ->
      dataLoadedCallback = null
      beforeEach ->
        instance.$load { id: 5, field: 'val', field2: 'other val' }
        instance._associations = [{
          beforeLoad: (data) -> data.field += ' association load'
        }]
        dataLoadedCallback = jasmine.createSpy('data loaded')
        instance.$onDataLoaded dataLoadedCallback
        instance._loadField('field', { field: 'formatted updated val', other_field: 'other val' })

      it 'sets the field to the response, modified by the association', ->
        expect(instance.field).toEqual('formatted updated val association load')

      it 'does not set other fields from the response', ->
        expect(instance.other_field).toBeUndefined()

      it 'replaces saved data with the response, unmodified by the association', ->
        expect(instance.$saved).toEqual { field: 'formatted updated val', other_field: 'other val' }

      it 'calls the data loaded callback', ->
        expect(dataLoadedCallback).toHaveBeenCalled()

    # Update a single field
    describe '#$updateField', ->
      describe 'without an id', ->
        it 'throws an error', ->
          expect(-> instance.$updateField()).toThrow()

      describe 'with an id', ->
        request = promise = updateSpy = null
        beforeEach inject (promiseExpectation) ->
          updateSpy = jasmine.createSpy('rootScope update watcher')
          rootScope.$on('modelFieldUpdated', updateSpy)

          instance.$load { id: 5, field: 'val', field2: 'other val' }
          instance._associations = [{
            beforeSave: (data) -> data.field += ' association',
          }]
          instance.field = 'updated val'
          request = httpBackend.expectPUT('/5', { field: 'updated val association' })
          request.respond null

          spyOn(instance, '_loadField')
          spyOn(instance, '$revertField')

          promise = promiseExpectation(instance.$updateField('field'))

        it 'sends a PUT request', ->
          httpBackend.verifyNoOutstandingExpectation()

        describe 'on success', ->
          beforeEach ->
            request.respond 'response data'
            httpBackend.flush()

          it 'loads the field', ->
            expect(instance._loadField).toHaveBeenCalledWith('field', 'response data')

          it 'resolves the promise', ->
            promise.expectToBeResolved()

          it 'broadcasts an event', ->
            expect(updateSpy).toHaveBeenCalled()

          it 'sends itself in the event', ->
            expect(updateSpy.mostRecentCall.args[1]).toBe(instance)

          it 'sends the field in the event', ->
            expect(updateSpy.mostRecentCall.args[2]).toEqual('field')

          it 'sends the response data in the event', ->
            expect(updateSpy.mostRecentCall.args[3]).toEqual('response data')

        describe 'on failure', ->
          beforeEach ->
            request.respond 500
            httpBackend.flush()

          it 'reverts the field', ->
            expect(instance.$revertField).toHaveBeenCalledWith('field')

          it 'rejects the promise', ->
            promise.expectToBeRejected()

          it 'does not broadcast an event', ->
            expect(updateSpy).not.toHaveBeenCalled()


    # Revert a field
    describe '#$revertField', ->
      beforeEach ->
        instance.$load { field: 'val', field2: 'other val' }
        instance._associations = [{
          beforeSave: (data) -> data.field += ' association',
          beforeLoad: (data) -> data.field += ' association load'
        }]
        instance.field = 'updated val'
        instance.$revertField('field')

      it 'reverts the field to the old value with associations applied', ->
        expect(instance.field).toEqual('val association load')


    # Revert all fields
    describe '#$revert', ->
      result = null
      beforeEach ->
        instance.$load { field: 'val', field2: 'other val', field3: 'third val' }
        instance._associations = [{
          beforeSave: (data) -> data.field += ' association',
          beforeLoad: (data) -> data.field += ' association load'
        }]
        instance.field = 'updated val'
        instance.field3 = 'some val'
        instance.field4 = 'new val'
        result = instance.$revert()

      it 'reverts each field to its old value with associations applied', ->
        expect(instance.field).toEqual('val association load')
        expect(instance.field2).toEqual('other val')
        expect(instance.field3).toEqual('third val')
        expect(instance.field4).toBeUndefined()

      it 'leaves saved data as is', ->
        expect(instance.$saved).toEqual { field: 'val', field2: 'other val', field3: 'third val' }

      it 'returns the instance', ->
        expect(result).toBe(instance)

    # Event listeners
    describe 'event listeners', ->
      scope = null
      beforeEach ->
        scope = rootScope.$new()
        instance = new SoilModel(scope, { id: 6 })
        instance._modelType = 'specific model'

      describe 'on a modelSaved event', ->
        beforeEach -> spyOn(instance, '$load')

        describe 'if the event model has a different type', ->
          beforeEach ->
            other = new SoilModel(null, { id: 6 })
            other._modelType = 'other model'
            rootScope.$broadcast('modelSaved', other, 'data')

          it 'does not load data', ->
            expect(instance.$load).not.toHaveBeenCalled()

        describe 'if the event model has a different id', ->
          beforeEach ->
            other = new SoilModel(null, { id: 5 })
            other._modelType = 'specific model'
            rootScope.$broadcast('modelSaved', other, 'data')

          it 'does not load data', ->
            expect(instance.$load).not.toHaveBeenCalled()

        describe 'if both models have no ids', ->
          beforeEach ->
            instance.id = undefined
            other = new SoilModel(null)
            other._modelType = 'specific model'
            rootScope.$broadcast('modelSaved', other, 'data')

          it 'does not load data', ->
            expect(instance.$load).not.toHaveBeenCalled()

        describe 'if the event model has the same type and id', ->
          beforeEach ->
            other = new SoilModel(null, { id: 6 })
            other._modelType = 'specific model'
            rootScope.$broadcast('modelSaved', other, 'data')

          it 'does not load data', ->
            expect(instance.$load).toHaveBeenCalledWith('data')

      describe 'on a modelFieldUpdated event', ->
        beforeEach -> spyOn(instance, '_loadField')

        describe 'if the event model has a different type', ->
          beforeEach ->
            other = new SoilModel(null, { id: 6 })
            other._modelType = 'other model'
            rootScope.$broadcast('modelFieldUpdated', other, 'field', 'data')

          it 'does not load data', ->
            expect(instance._loadField).not.toHaveBeenCalled()

        describe 'if the event model has a different id', ->
          beforeEach ->
            other = new SoilModel(null, { id: 5 })
            other._modelType = 'specific model'
            rootScope.$broadcast('modelFieldUpdated', other, 'field', 'data')

          it 'does not load data', ->
            expect(instance._loadField).not.toHaveBeenCalled()

        describe 'if both models have no ids', ->
          beforeEach ->
            instance.id = undefined
            other = new SoilModel(null)
            other._modelType = 'specific model'
            rootScope.$broadcast('modelFieldUpdated', other, 'field', 'data')

          it 'does not load data', ->
            expect(instance._loadField).not.toHaveBeenCalled()

        describe 'if the event model has the same type and id', ->
          beforeEach ->
            other = new SoilModel(null, { id: 6 })
            other._modelType = 'specific model'
            rootScope.$broadcast('modelFieldUpdated', other, 'field', 'data')

          it 'does not load data', ->
            expect(instance._loadField).toHaveBeenCalledWith('field', 'data')
