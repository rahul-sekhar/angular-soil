describe 'soil.collection module', ->
  beforeEach module 'soil.collection'
  beforeEach module 'soil.model.mock'
  beforeEach module 'angular-mock-promise'

  describe 'soilCollection', ->
    soilModel = instance = httpBackend = null

    beforeEach inject (soilCollection, $httpBackend, _soilModel_) ->
      httpBackend = $httpBackend
      soilModel = _soilModel_
      instance = new soilCollection(soilModel)

    it 'sets members to undefined', ->
      expect(instance.members).toBeUndefined()

    # Load data into the collection
    describe '#load', ->
      beforeEach ->
        instance.members = ['member1', 'member2', 'member3']

      describe 'with data passed', ->
        beforeEach ->
          instance.load([{ id: 1, name: 'first' }, { id: 4, name: 'second' }])

        it 'replaces old members', ->
          expect(instance.members.length).toEqual(2)

        it 'creates a model for each member', ->
          _.each instance.members, (member) ->
            expect(member instanceof soilModel).toBeTruthy()

        it 'sets members to the response', ->
          expect(_.map(instance.members, (member) -> member.id)).toEqual [1, 4]
          expect(_.map(instance.members, (member) -> member.name)).toEqual ['first', 'second']

      describe 'with null passed', ->
        beforeEach -> instance.load(null)

        it 'clears members', ->
          expect(instance.members).toEqual([])

    # Get data from a source
    describe '#get', ->
      request = promise = null
      beforeEach inject (promiseExpectation) ->
        spyOn(instance, 'load')
        request = httpBackend.expectGET('/source_url')
        request.respond null
        promise = promiseExpectation(instance.get('/source_url'))

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

