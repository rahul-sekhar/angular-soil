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

    describe '_url', ->
      it 'is the root by default', ->
        expect(instance._url).toBe('/')

      it 'can be overridden', ->
        instance._url = '/test'
        expect(instance._url).toBe('/test')

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

      describe 'with no data', ->
        beforeEach ->
          instance._private = 'private val'
          instance.load()

        it 'is cleared, except for private fields', ->
          expect(Object.getOwnPropertyNames(instance)).toEqual ['_private']
