describe 'soil-collection module', ->
  beforeEach module 'soil-collection'

  describe 'soilCollection', ->
    soilCollection = instance = httpBackend = rootScope = null

    beforeEach inject (_soilCollection_, $httpBackend, $rootScope) ->
      httpBackend = $httpBackend
      rootScope = $rootScope
      soilCollection = _soilCollection_
      instance = new soilCollection('/source_url')

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
          rootScope.$apply()

        it 'sets members to an empty array', ->
          expect(instance.members).toEqual []

      describe 'with a response', ->
        beforeEach ->
          request.respond [{id: 1, name: 'first'}, {id: 4, name: 'second'}]
          httpBackend.flush()
          rootScope.$apply()

        it 'sets members to the response', ->
          expect(instance.members).toEqual [{id: 1, name: 'first'}, {id: 4, name: 'second'}]

      describe 'on failure', ->
        beforeEach ->
          request.respond 500
          httpBackend.flush()
          rootScope.$apply()

        it 'leaves members as is', ->
          expect(instance.members).toBeUndefined