describe 'soil.collection module', ->
  beforeEach module 'soil.collection'
  beforeEach module 'soil.model.mock'
  beforeEach module 'angular-mock-promise'

  describe 'soilCollection', ->
    soilModel = instance = httpBackend = null

    beforeEach inject (soilCollection, $httpBackend, _soilModel_) ->
      httpBackend = $httpBackend
      soilModel = _soilModel_
      instance = new soilCollection(soilModel, '/source_url')

    it 'sets members to undefined', ->
      expect(instance.members).toBeUndefined()

    # Load data into the collection
    describe '#load', ->
      result = null
      beforeEach ->
        instance.members = ['member1', 'member2', 'member3']

      describe 'with data passed', ->
        beforeEach ->
          result = instance.load([{ id: 1, name: 'first' }, { id: 4, name: 'second' }])

        it 'replaces members with a model for each member', ->
          expect(instance.members).toEqual([jasmine.any(soilModel), jasmine.any(soilModel)])

        it 'loads each models data', ->
          expect(instance.members[0].load).toHaveBeenCalledWith({ id: 1, name: 'first' })
          expect(instance.members[1].load).toHaveBeenCalledWith({ id: 4, name: 'second' })

        it 'returns the instance', ->
          expect(result).toBe(instance)

      describe 'with null passed', ->
        beforeEach -> result = instance.load(null)

        it 'clears members', ->
          expect(instance.members).toEqual([])

        it 'returns the instance', ->
          expect(result).toBe(instance)

    # Check whether data has been loaded
    describe '#loaded', ->
      describe 'with no data', ->
        it 'returns false', ->
          expect(instance.loaded()).toBe(false)

      describe 'with an empty array of members', ->
        beforeEach -> instance.members = []

        it 'returns true', ->
          expect(instance.loaded()).toBe(true)

      describe 'with an array of members', ->
        beforeEach -> instance.members = ['member1', 'member2']

        it 'returns true', ->
          expect(instance.loaded()).toBe(true)

    # Get data from a source
    describe '#get', ->
      request = promise = null
      beforeEach inject (promiseExpectation) ->
        spyOn(instance, 'load')
        request = httpBackend.expectGET('/source_url')
        request.respond null
        promise = promiseExpectation(instance.get())

      it 'sends a request to the source_url', ->
        httpBackend.verifyNoOutstandingExpectation()

      describe 'on success', ->
        beforeEach ->
          request.respond 'some data'
          httpBackend.flush()

        it 'loads the data', ->
          expect(instance.load).toHaveBeenCalledWith('some data')

        it 'resolves the promise', ->
          promise.expectToBeResolved()

      describe 'on failure', ->
        beforeEach ->
          request.respond 500
          httpBackend.flush()

        it 'does not load data', ->
          expect(instance.load).not.toHaveBeenCalled()

        it 'rejects the promise', ->
          promise.expectToBeRejected()

    # Add an item to the collection
    describe '#add', ->
      beforeEach ->
        instance.members = ['member1', 'member2', 'member3']
        instance.add('new member')

      it 'adds the new item to the end of the member array', ->
        expect(instance.members).toEqual(['member1', 'member2', 'member3', 'new member'])

    describe '#addToFront', ->
      beforeEach ->
        instance.members = ['member1', 'member2', 'member3']
        instance.addToFront('new member')

      it 'adds the new item to the front of the member array', ->
        expect(instance.members).toEqual(['new member', 'member1', 'member2', 'member3'])


    # Create an item and add it to the collection
    describe '#create', ->
      promise = response = null
      beforeEach  ->
        instance.members = ['member1', 'member2']
        response = httpBackend.expectPOST('/source_url', { data: 'val' })
        response.respond null

      describe 'with default options', ->
        beforeEach inject (promiseExpectation) ->
          promise = promiseExpectation(instance.create({ data: 'val' }))

        it 'sends a POST request', ->
          httpBackend.verifyNoOutstandingExpectation()

        it 'does nothing until the backend responds', ->
          expect(instance.members).toEqual(['member1', 'member2'])

        describe 'on success', ->
          beforeEach ->
            response.respond { data: 'response val' }
            httpBackend.flush()

          it 'adds the created model', ->
            expect(instance.members).toEqual(['member1', 'member2', jasmine.any(soilModel)])

          it 'loads the added model with the passed data', ->
            expect(instance.members[2].load).toHaveBeenCalledWith({ data: 'response val' })

          it 'resolves the returned promise', ->
            promise.expectToBeResolved()

        describe 'on failure', ->
          beforeEach ->
            response.respond 500
            httpBackend.flush()

          it 'does not add a member', ->
            expect(instance.members).toEqual(['member1', 'member2'])

          it 'rejects the returned promise', ->
            promise.expectToBeRejected()

      describe 'with addToFront set', ->
        beforeEach ->
          instance.create({ data: 'val' }, { addToFront: true })

        it 'adds the created model to the front', ->
          response.respond { data: 'response val' }
          httpBackend.flush()
          expect(instance.members).toEqual([jasmine.any(soilModel), 'member1', 'member2'])

    # Remove an item from the collection by ID
    describe '#removeById', ->
      beforeEach ->
        instance.members = [{ id: 1, name: 'first' }, { id: 2, name: 'second' }, { id: 3, name: 'third' }, { id: 2, name: 'second' }]

      describe 'when passed an id', ->
        beforeEach ->
          instance.removeById(2)

        it 'removes all instances of that id', ->
          expect(instance.members).toEqual [{ id: 1, name: 'first' }, { id: 3, name: 'third' }]

    # Remove an item from the collection by passing the item
    describe '#remove', ->
      beforeEach ->
        instance.members = [{ id: 1, name: 'first' }, { id: 2, name: 'second' }, { id: 3, name: 'third' }, { id: 2, name: 'second' }]

      describe 'when passed an object', ->
        beforeEach ->
          instance.remove(instance.members[1])

        it 'removes only the instance passed', ->
          expect(instance.members).toEqual [{ id: 1, name: 'first' }, { id: 3, name: 'third' }, { id: 2, name: 'second' }]

