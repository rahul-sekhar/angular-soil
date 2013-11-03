/* angular-soil 0.1.3 %> */

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  angular.module('soil.collection.mock', ['soil.collection']).config([
    '$provide', function($provide) {
      return $provide.decorator('soilCollection', [
        '$delegate', function($delegate) {
          var soilCollectionMock;
          return soilCollectionMock = (function(_super) {
            __extends(soilCollectionMock, _super);

            function soilCollectionMock() {
              var _this = this;
              soilCollectionMock.__super__.constructor.apply(this, arguments);
              spyOn(this, 'loadAll').andCallFake(function() {
                return _this.members = [];
              });
            }

            soilCollectionMock.prototype.addItem = jasmine.createSpy();

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

  angular.module('soil.model.mock', ['soil.model']).config([
    '$provide', function($provide) {
      return $provide.decorator('soilModel', [
        '$delegate', function($delegate) {
          var soilModelMock, _ref;
          return soilModelMock = (function(_super) {
            __extends(soilModelMock, _super);

            function soilModelMock() {
              _ref = soilModelMock.__super__.constructor.apply(this, arguments);
              return _ref;
            }

            return soilModelMock;

          })($delegate);
        }
      ]);
    }
  ]);

}).call(this);
