describe 'soil.collection module', ->
  beforeEach module 'soil.collection'
  beforeEach module 'soil.model.mock'
  beforeEach module 'testPromise'

  describe 'soilCollection', ->
    soilModel = soilCollection = instance = httpBackend = null

    beforeEach inject (_soilCollection_, $httpBackend, _soilModel_) ->
      httpBackend = $httpBackend
      soilModel = _soilModel_
      soilCollection = _soilCollection_
      instance = new soilCollection(soilModel, '/source_url')

    it 'sets members to undefined', ->
      expect(instance.members).toBeUndefined()

    describe '#loadAll', ->
      request = promise = null

      beforeEach inject (testPromise) ->
        request = httpBackend.expectGET('/source_url')
        request.respond null
        promise = testPromise(instance.loadAll())

      it 'sends a request to the source_url', ->
        httpBackend.verifyNoOutstandingExpectation()

      describe 'with an empty response', ->
        beforeEach ->
          request.respond []
          httpBackend.flush()

        it 'sets members to an empty array', ->
          expect(instance.members).toEqual []

        it 'resolves the promise', ->
          promise.expectSuccess()

      describe 'with a response', ->
        beforeEach ->
          request.respond [{id: 1, name: 'first'}, {id: 4, name: 'second'}]
          httpBackend.flush()

        it 'creates a model for each member', ->
          _.each instance.members, (member) ->
            expect(member instanceof soilModel).toBeTruthy()

        it 'sets members to the response', ->
          expect(_.map(instance.members, (member) -> member.id)).toEqual [1, 4]

        it 'resolves the promise', ->
          promise.expectSuccess()

      describe 'on failure', ->
        beforeEach ->
          request.respond 500
          httpBackend.flush()

        it 'leaves members as is', ->
          expect(instance.members).toBeUndefined

        it 'rejects the promise', ->
          promise.expectError()

    describe '#addItem', ->
      request = promise = null

      describe 'when not loaded', ->
        beforeEach ->
          instance.members = undefined
          instance.addItem { data: 'val' }

        it 'does not send a POST request', ->
          httpBackend.verifyNoOutstandingExpectation()

      describe 'when loaded', ->
        beforeEach inject (testPromise) ->
          request = httpBackend.expectPOST('/source_url', { data: 'val' })
          request.respond null
          instance.members = ['data1', 'data2']
          promise = testPromise(instance.addItem { data: 'val' })

        it 'sends a POST request', ->
          httpBackend.verifyNoOutstandingExpectation()

        describe 'on success', ->
          beforeEach ->
            request.respond { response_data: 'formatted val' }
            httpBackend.flush()

          newModel = ->
            _.last instance.members

          it 'adds a model to the collection', ->
            expect(instance.members.length).toEqual(3)

          it 'adds a model of the collections class', ->
            expect(newModel() instanceof soilModel).toBeTruthy()

          it 'loads response data into the added model', ->
            expect(newModel().response_data).toEqual('formatted val')
            expect(newModel()._savedData).toEqual { response_data: 'formatted val' }

          it 'resolves the promise', ->
            promise.expectSuccess()

        describe 'on failure', ->
          beforeEach ->
            request.respond 500
            httpBackend.flush()

          it 'does not add a model to the collection', ->
            expect(instance.members.length).toEqual(2)

          it 'rejects the promise', ->
            promise.expectError()