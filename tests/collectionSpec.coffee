describe 'soil.collection module', ->
  beforeEach module 'soil.collection'
  beforeEach module 'soil.model.mock'
  beforeEach module 'angular-mock-promise'

  describe 'SoilCollection', ->
    SoilModel = instance = httpBackend = scope = rootScope = null

    beforeEach inject (SoilCollection, $httpBackend, _SoilModel_, $rootScope) ->
      httpBackend = $httpBackend
      rootScope = $rootScope
      scope = rootScope.$new()
      SoilModel = _SoilModel_
      instance = new SoilCollection(scope, SoilModel, '/source_url')

    it 'sets members to an empty array', ->
      expect(instance.$members).toEqual []

    it 'sets the modelClass', ->
      expect(instance.modelClass).toBe(SoilModel)

    it 'sets the scope', ->
      expect(instance._scope).toBe(scope)

    # Load data into the collection
    describe '#$load', ->
      result = null
      beforeEach ->
        instance.$members = ['member1', 'member2', 'member3']

      describe 'with data passed', ->
        beforeEach ->
          result = instance.$load([{ id: 1, name: 'first' }, { id: 4, name: 'second' }])

        it 'replaces members with a model for each member', ->
          expect(instance.$members).toEqual([jasmine.any(SoilModel), jasmine.any(SoilModel)])

        it 'loads each models data', ->
          expect(instance.$members[0].$load).toHaveBeenCalledWith({ id: 1, name: 'first' })
          expect(instance.$members[1].$load).toHaveBeenCalledWith({ id: 4, name: 'second' })

        it 'sets the scope for each model', ->
          expect(instance.$members[0]._scope).toBe(scope)
          expect(instance.$members[1]._scope).toBe(scope)

        it 'returns the instance', ->
          expect(result).toBe(instance)

      describe 'with an object passed', ->
        beforeEach ->
          result = instance.$load({ 
            items: [{ id: 1, name: 'first' }, { id: 4, name: 'second' }]
            data: 'some data'
          })

        it 'sets data', ->
          expect(instance.data).toBe 'some data'

        it 'replaces members with a model for each member', ->
          expect(instance.$members).toEqual([jasmine.any(SoilModel), jasmine.any(SoilModel)])

        it 'loads each models data', ->
          expect(instance.$members[0].$load).toHaveBeenCalledWith({ id: 1, name: 'first' })
          expect(instance.$members[1].$load).toHaveBeenCalledWith({ id: 4, name: 'second' })

        it 'sets the scope for each model', ->
          expect(instance.$members[0]._scope).toBe(scope)
          expect(instance.$members[1]._scope).toBe(scope)

        it 'returns the instance', ->
          expect(result).toBe(instance)

      describe 'with null passed', ->
        beforeEach -> result = instance.$load(null)

        it 'clears members', ->
          expect(instance.$members).toEqual([])

        it 'returns the instance', ->
          expect(result).toBe(instance)

    # Get data from a source
    describe '#$get', ->
      request = promise = null
      beforeEach inject (promiseExpectation) ->
        spyOn(instance, '$load')
        request = httpBackend.expectGET('/source_url')
        request.respond null
        promise = promiseExpectation(instance.$get())

      it 'sends a request to the source_url', ->
        httpBackend.verifyNoOutstandingExpectation()

      describe 'on success', ->
        beforeEach ->
          request.respond 'some data'
          httpBackend.flush()

        it 'loads the data', ->
          expect(instance.$load).toHaveBeenCalledWith('some data')

        it 'resolves the promise', ->
          promise.expectToBeResolved()

      describe 'on failure', ->
        beforeEach ->
          request.respond 500
          httpBackend.flush()

        it 'does not load data', ->
          expect(instance.$load).not.toHaveBeenCalled()

        it 'rejects the promise', ->
          promise.expectToBeRejected()

    # Add an item to the collection
    describe '#$add', ->
      result = null
      beforeEach ->
        instance.$members = ['member1', 'member2', 'member3']
        result = instance.$add({ data: 'val' })

      it 'adds the new item to the end of the member array', ->
        expect(instance.$members).toEqual(['member1', 'member2', 'member3', jasmine.any(SoilModel)])

      it 'loads data into the new member', ->
        expect(instance.$members[3].$load).toHaveBeenCalledWith({ data: 'val' })

      it 'sets the scope of the member', ->
        expect(instance.$members[3]._scope).toBe(scope)

      it 'sets the members postUrl to its source', ->
        expect(instance.$members[3]._postUrl).toEqual('/source_url')

      it 'returns the new item', ->
        expect(result).toBe(_.last(instance.$members))

    describe '#$addToFront', ->
      result = null
      beforeEach ->
        instance.$members = ['member1', 'member2', 'member3']
        result = instance.$addToFront({ data: 'val' })

      it 'adds the new item to the front of the member array', ->
        expect(instance.$members).toEqual([jasmine.any(SoilModel), 'member1', 'member2', 'member3'])

      it 'loads data into the new member', ->
        expect(instance.$members[0].$load).toHaveBeenCalledWith({ data: 'val' })

      it 'sets the scope of the member', ->
        expect(instance.$members[0]._scope).toBe(scope)

      it 'sets the members postUrl to its source', ->
        expect(instance.$members[0]._postUrl).toEqual('/source_url')

      it 'returns the new item', ->
        expect(result).toBe(_.first(instance.$members))

    # Add an item at an index
    describe '#$addAt', ->
      result = null
      beforeEach ->
        instance.$members = ['member1', 'member2', 'member3']
        result = instance.$addAt(1, { data: 'val' })

      it 'adds the new item at the index', ->
        expect(instance.$members).toEqual(['member1', jasmine.any(SoilModel), 'member2', 'member3'])

      it 'loads data into the new member', ->
        expect(instance.$members[1].$load).toHaveBeenCalledWith({ data: 'val' })

      it 'sets the scope of the member', ->
        expect(instance.$members[1]._scope).toBe(scope)

      it 'sets the members postUrl to its source', ->
        expect(instance.$members[1]._postUrl).toEqual('/source_url')

      it 'returns the new item', ->
        expect(result).toBe(instance.$members[1])

    # Remove an item from the collection by ID
    describe '#$removeById', ->
      beforeEach ->
        instance.$members = [{ id: 1, name: 'first' }, { id: 2, name: 'second' }, { id: 3, name: 'third' }, { id: 2, name: 'second' }]

      describe 'when passed an id', ->
        beforeEach ->
          instance.$removeById(2)

        it 'removes all instances of that id', ->
          expect(instance.$members).toEqual [{ id: 1, name: 'first' }, { id: 3, name: 'third' }]

    # Remove an item from the collection by passing the item
    describe '#$remove', ->
      beforeEach ->
        instance.$members = [{ id: 1, name: 'first' }, { id: 2, name: 'second' }, { id: 3, name: 'third' }, { id: 2, name: 'second' }]

      describe 'when passed an object', ->
        beforeEach ->
          instance.$remove(instance.$members[1])

        it 'removes only the instance passed', ->
          expect(instance.$members).toEqual [{ id: 1, name: 'first' }, { id: 3, name: 'third' }, { id: 2, name: 'second' }]

    # Find an item by ID
    describe '#$find', ->
      beforeEach ->
        instance.$members = [{ id: 1, name: 'first' }, { id: 2, name: 'second' }, { id: 3, name: 'third' }]

      it 'returns the item if found', ->
        expect(instance.$find(2)).toBe(instance.$members[1])

      it 'returns false if nothing was found', ->
        expect(instance.$find(4)).toBeFalsy()

    # After initial load promise
    describe '#$afterInitialLoad', ->
      promise = null
      beforeEach inject (promiseExpectation) ->
        promise = promiseExpectation(instance.$afterInitialLoad)

      it 'is initially not resolved', ->
        promise.expectToBeUnresolved()

      describe 'after $get is called', ->
        beforeEach ->
          httpBackend.expectGET('/source_url').respond 'data'
          instance.$get()

        it 'the promise is still not resolved', ->
          promise.expectToBeUnresolved()

        describe 'on success', ->
          beforeEach -> httpBackend.flush()

          it 'resolves the promise', ->
            promise.expectToBeResolved()

          describe 'on a subsequent call to $get', ->
            beforeEach ->
              httpBackend.expectGET('/source_url').respond 'other data'
              instance.$get()

            it 'the promise is still resolved', ->
              promise.expectToBeResolved()

            describe 'on success', ->
              beforeEach -> httpBackend.flush()

              it 'the promise is still resolved', ->
                promise.expectToBeResolved()


    # A collection with a parent
    describe 'with a parent', ->
      beforeEach ->
        instance._parent = 'parent obj'

      describe '#$load', ->
        beforeEach -> instance.$load([{ id: 1, name: 'first' }, { id: 4, name: 'second' }])

        it 'sets the parent for each model', ->
          expect(instance.$members[0]._parent).toBe('parent obj')
          expect(instance.$members[1]._parent).toBe('parent obj')

      describe '#$add', ->
        beforeEach ->
          instance.$members = ['member1', 'member2', 'member3']
          instance.$add({ data: 'val' })

        it 'sets the parent of the member', ->
          expect(instance.$members[3]._parent).toBe('parent obj')

      describe '#$addToFront', ->
        beforeEach ->
          instance.$members = ['member1', 'member2', 'member3']
          instance.$addToFront({ data: 'val' })

        it 'sets the parent of the member', ->
          expect(instance.$members[0]._parent).toBe('parent obj')

      describe '#$addAt', ->
        beforeEach ->
          instance.$members = ['member1', 'member2', 'member3']
          instance.$addAt(1, { data: 'val' })

        it 'sets the parent of the member', ->
          expect(instance.$members[1]._parent).toBe('parent obj')

    # Set scope
    describe '#$setScope', ->
      scope = null
      beforeEach inject (SoilCollection) ->
        instance = new SoilCollection(null, SoilModel, '/source_url')
        scope = rootScope.$new()
        instance.$load [{ id: 1 }, { id: 2 }, { id: 3 }]
        instance.$setScope(scope)

      it 'sets the scope', ->
        expect(instance._scope).toBe(scope)

      it 'sets up event listeners', ->
        memberIds = ->
          _.map instance.$members, (member) ->
            member.id

        rootScope.$broadcast('modelDeleted', 'model', 2)
        expect(memberIds()).toEqual [1, 3]

      it 'sets model scopes', ->
        expect(instance.$members[0]._scope).toBe(scope)
        expect(instance.$members[1]._scope).toBe(scope)
        expect(instance.$members[2]._scope).toBe(scope)

      describe 'with the scope already set', ->
        it 'raises an error', ->
          newScope = rootScope.$new()
          expect( -> instance.$setScope(newScope) ).toThrow('Scope has already been set')

    # Event listeners
    describe 'Event listeners', ->
      beforeEach inject (SoilCollection) ->
        class SoilModelWithType extends SoilModel
          _modelType: 'some type'
        instance = new SoilCollection(scope, SoilModelWithType, '/source_url')
        instance.$load [{ id: 1 }, { id: 2 }, { id: 3 }]

      memberIds = ->
        _.map instance.$members, (member) ->
          member.id

      describe 'on model deletion', ->
        describe 'with a different model type', ->
          beforeEach ->
            rootScope.$broadcast('modelDeleted', 'different type', 2)

          it 'does not remove any models', ->
            expect(memberIds()).toEqual [1, 2, 3]

        describe 'with the same model type, but an id not present', ->
          beforeEach ->
            rootScope.$broadcast('modelDeleted', 'some type', 4)

          it 'does not remove any models', ->
            expect(memberIds()).toEqual [1, 2, 3]

        describe 'with the same model type and an id that is present', ->
          beforeEach ->
            rootScope.$broadcast('modelDeleted', 'some type', 2)

          it 'removes matching models', ->
            expect(memberIds()).toEqual [1, 3]

  describe 'SoilGlobalCollection', ->
    SoilModelWithType = SoilModel = instance = rootScope = httpBackend = null

    beforeEach inject (SoilGlobalCollection, $httpBackend, _SoilModel_, $rootScope) ->
      rootScope = $rootScope

      SoilModel = _SoilModel_
      class SoilModelWithType extends SoilModel
        _modelType: 'some type'

      httpBackend = $httpBackend
      httpBackend.expectGET('/source_url').respond 'data'
      instance = new SoilGlobalCollection(SoilModelWithType, '/source_url')

    it 'is an instance of a SoilCollection', inject (SoilCollection) ->
      expect(instance instanceof SoilCollection).toBeTruthy()

    it 'sets members to an empty array', ->
      expect(instance.$members).toEqual []

    it 'sets the modelClass', ->
      expect(instance.modelClass).toBe(SoilModelWithType)

    it 'sets the scope to rootScope', ->
      expect(instance._scope).toBe(rootScope)

    it 'gets data from the server', ->
      httpBackend.verifyNoOutstandingExpectation()

    # Loaded attribute set after the initial load
    describe '_loaded', ->
      it 'is initially false', ->
        expect(instance._loaded).toBeFalsy()

      describe 'after the server responds', ->
        beforeEach -> httpBackend.flush()

        it 'is true', ->
          expect(instance._loaded).toBeTruthy()

    # Event listeners
    describe 'on model creation', ->
      beforeEach ->
        instance.$load [{ id: 1 }, { id: 2 }, { id: 3 }]
        spyOn(instance, '$add')

      describe 'with a different model type', ->
        beforeEach ->
          rootScope.$broadcast('modelSaved', new SoilModel(null, { id: 4 }), { id: 4, data: 'val' })

        it 'does not add any models', ->
          expect(instance.$add).not.toHaveBeenCalled()

      describe 'with the same model type, but an id already present', ->
        beforeEach ->
          rootScope.$broadcast('modelSaved', new SoilModelWithType(null, { id: 2 }), { id: 2, data: 'val' })

        it 'does not add any models', ->
          expect(instance.$add).not.toHaveBeenCalled()

      describe 'with the same model type and an id that is not present', ->
        beforeEach ->
          rootScope.$broadcast('modelSaved', new SoilModelWithType(null, { id: 4 }), { id: 4, data: 'val' })

        it 'adds the model', ->
          expect(instance.$add).toHaveBeenCalledWith({ id: 4, data: 'val' })


    describe 'on model creation failure', ->
      beforeEach ->
        instance.$load [{ id: 1 }, { id: 2 }, { id: 3 }]
        spyOn(instance, '$remove')

      describe 'with a different model type', ->
        beforeEach ->
          rootScope.$broadcast('modelCreateFailed', new SoilModel(null, { id: 2 }))

        it 'does not remove any model', ->
          expect(instance.$remove).not.toHaveBeenCalled()

      describe 'with the same model type', ->
        modelToRemove = null
        beforeEach ->
          modelToRemove = new SoilModelWithType(null, { id: 4 })
          rootScope.$broadcast('modelCreateFailed', modelToRemove)

        it 'removes the model', ->
          expect(instance.$remove).toHaveBeenCalledWith(modelToRemove)
