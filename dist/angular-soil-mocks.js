/* angular-soil 0.5.0 %> */

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  angular.module('soil.collection.mock', ['soil.collection', 'angular-mock-promise']).config([
    '$provide', function($provide) {
      return $provide.decorator('soilCollection', [
        '$delegate', 'createMockPromise', function($delegate, createMockPromise) {
          var soilCollectionMock, _ref;
          return soilCollectionMock = (function(_super) {
            __extends(soilCollectionMock, _super);

            function soilCollectionMock() {
              _ref = soilCollectionMock.__super__.constructor.apply(this, arguments);
              return _ref;
            }

            soilCollectionMock.prototype.get = jasmine.createSpy('get').andReturn(createMockPromise());

            return soilCollectionMock;

          })($delegate);
        }
      ]);
    }
  ]);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  angular.module('soil.model.mock', ['soil.model', 'angular-mock-promise']).config([
    '$provide', function($provide) {
      return $provide.decorator('soilModel', [
        '$delegate', 'createMockPromise', function($delegate, createMockPromise) {
          var soilModelMock, _ref;
          return soilModelMock = (function(_super) {
            __extends(soilModelMock, _super);

            function soilModelMock() {
              _ref = soilModelMock.__super__.constructor.apply(this, arguments);
              return _ref;
            }

            soilModelMock.prototype.get = jasmine.createSpy('get').andReturn(createMockPromise());

            soilModelMock.prototype.save = jasmine.createSpy('save').andReturn(createMockPromise());

            soilModelMock.prototype["delete"] = jasmine.createSpy('delete').andReturn(createMockPromise());

            soilModelMock.prototype.updateField = jasmine.createSpy('updateField').andReturn(createMockPromise());

            return soilModelMock;

          })($delegate);
        }
      ]);
    }
  ]);

}).call(this);
