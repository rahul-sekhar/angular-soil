describe 'soil.collection module', ->
  beforeEach module 'soil.collection'
  beforeEach module 'soil.model.mock'

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
      request = null

      beforeEach ->
        request = httpBackend.expectGET('/source_url')
        request.respond null
        instance.loadAll()

      it 'sends a request to the source_url', ->
        httpBackend.verifyNoOutstandingExpectation()

      describe 'with an empty response', ->
        beforeEach ->
          request.respond []
          httpBackend.flush()

        it 'sets members to an empty array', ->
          expect(instance.members).toEqual []

      describe 'with a response', ->
        beforeEach ->
          request.respond [{id: 1, name: 'first'}, {id: 4, name: 'second'}]
          httpBackend.flush()

        it 'creates a model for each member', ->
          _.each instance.members, (member) ->
            expect(member instanceof soilModel).toBeTruthy()

        it 'sets members to the response', ->
          expect(_.map(instance.members, (member) -> member.id)).toEqual [1, 4]

      describe 'on failure', ->
        beforeEach ->
          request.respond 500
          httpBackend.flush()

        it 'leaves members as is', ->
          expect(instance.members).toBeUndefined

    describe '#addItem', ->
      request = null

      describe 'when not loaded', ->
        beforeEach ->
          instance.members = undefined
          instance.addItem { data: 'val' }

        it 'does not send a POST request', ->
          httpBackend.verifyNoOutstandingExpectation()

      describe 'when loaded', ->
        beforeEach ->
          request = httpBackend.expectPOST('/source_url', { data: 'val' })
          request.respond null
          instance.members = ['data1', 'data2']
          instance.addItem { data: 'val' }

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
            expect(newModel()._saved_data).toEqual { response_data: 'formatted val' }

        describe 'on failure', ->
          beforeEach ->
            request.respond 500
            httpBackend.flush()

          it 'does not add a model to the collection', ->
            expect(instance.members.length).toEqual(2)