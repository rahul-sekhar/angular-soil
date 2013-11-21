/* angular-soil 0.8.1 %> */

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  angular.module('soil.collection.mock', ['soil.collection', 'angular-mock-promise']).config([
    '$provide', function($provide) {
      return $provide.decorator('SoilCollection', [
        '$delegate', 'createMockPromise', function($delegate, createMockPromise) {
          var SoilCollectionMock;
          return SoilCollectionMock = (function(_super) {
            __extends(SoilCollectionMock, _super);

            function SoilCollectionMock() {
              spyOn(this, 'load').andCallThrough();
              this.getPromise = createMockPromise();
              spyOn(this, 'get').andReturn(this.getPromise);
              this.createPromise = createMockPromise();
              spyOn(this, 'create').andReturn(this.createPromise);
              SoilCollectionMock.__super__.constructor.apply(this, arguments);
            }

            return SoilCollectionMock;

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
      return $provide.decorator('SoilModel', [
        '$delegate', 'createMockPromise', function($delegate, createMockPromise) {
          var SoilModelMock;
          return SoilModelMock = (function(_super) {
            __extends(SoilModelMock, _super);

            function SoilModelMock(arg) {
              spyOn(this, 'load').andCallThrough();
              this.getPromise = createMockPromise();
              spyOn(this, 'get').andReturn(this.getPromise);
              this.savePromise = createMockPromise();
              spyOn(this, 'save').andReturn(this.savePromise);
              this.deletePromise = createMockPromise();
              spyOn(this, 'delete').andReturn(this.deletePromise);
              this.updatePromise = createMockPromise();
              spyOn(this, 'updateField').andReturn(this.updatePromise);
              SoilModelMock.__super__.constructor.apply(this, arguments);
            }

            return SoilModelMock;

          })($delegate);
        }
      ]);
    }
  ]);

}).call(this);
