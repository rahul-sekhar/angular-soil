/* angular-soil 0.7.0 %> */

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  angular.module('soil.collection.mock', ['soil.collection', 'angular-mock-promise']).config([
    '$provide', function($provide) {
      return $provide.decorator('soilCollection', [
        '$delegate', 'createMockPromise', function($delegate, createMockPromise) {
          var soilCollectionMock;
          return soilCollectionMock = (function(_super) {
            __extends(soilCollectionMock, _super);

            function soilCollectionMock() {
              spyOn(this, 'load').andCallThrough();
              this.getPromise = createMockPromise();
              spyOn(this, 'get').andReturn(this.getPromise);
              this.createPromise = createMockPromise();
              spyOn(this, 'create').andReturn(this.createPromise);
              soilCollectionMock.__super__.constructor.apply(this, arguments);
            }

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
          var soilModelMock;
          return soilModelMock = (function(_super) {
            __extends(soilModelMock, _super);

            function soilModelMock(arg) {
              spyOn(this, 'load').andCallThrough();
              this.getPromise = createMockPromise();
              spyOn(this, 'get').andReturn(this.getPromise);
              this.savePromise = createMockPromise();
              spyOn(this, 'save').andReturn(this.savePromise);
              this.deletePromise = createMockPromise();
              spyOn(this, 'delete').andReturn(this.deletePromise);
              this.updatePromise = createMockPromise();
              spyOn(this, 'updateField').andReturn(this.updatePromise);
              soilModelMock.__super__.constructor.apply(this, arguments);
            }

            return soilModelMock;

          })($delegate);
        }
      ]);
    }
  ]);

}).call(this);
