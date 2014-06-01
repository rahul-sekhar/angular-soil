/* angular-soil 1.5.5 %> */

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
              spyOn(this, '$load').andCallThrough();
              this._getPromise = createMockPromise();
              spyOn(this, '$get').andReturn(this._getPromise);
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
              spyOn(this, '$load').andCallThrough();
              spyOn(this, '$revert').andCallThrough();
              this._getPromise = createMockPromise();
              spyOn(this, '$get').andReturn(this._getPromise);
              this._savePromise = createMockPromise();
              spyOn(this, '$save').andReturn(this._savePromise);
              this._deletePromise = createMockPromise();
              spyOn(this, '$delete').andReturn(this._deletePromise);
              this._updatePromise = createMockPromise();
              spyOn(this, '$updateField').andReturn(this._updatePromise);
              SoilModelMock.__super__.constructor.apply(this, arguments);
            }

            return SoilModelMock;

          })($delegate);
        }
      ]);
    }
  ]);

}).call(this);
