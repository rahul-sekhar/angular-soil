/* angular-soil v0.1.1 %> */

(function() {
  angular.module('soil.collection.mock', []).factory('soilCollection', [
    '$http', function($http) {
      var soilCollection;
      return soilCollection = (function() {
        function soilCollection(_source_url) {
          this._source_url = _source_url;
          this.members = void 0;
          spyOn(this, 'loadAll').andCallThrough();
        }

        soilCollection.prototype.loadAll = function() {
          return this.members = [];
        };

        soilCollection.prototype.addItem = jasmine.createSpy();

        return soilCollection;

      })();
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
