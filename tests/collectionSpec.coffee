describe 'soil-collection module', ->
  beforeEach module 'soil-collection'

  describe 'soilCollection', ->
    soilCollection = instance = httpBackend = null

    beforeEach inject (_soilCollection_, $httpBackend) ->
      httpBackend = $httpBackend
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
