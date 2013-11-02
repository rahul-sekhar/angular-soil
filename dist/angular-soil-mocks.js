/* angular-soil v0.1.0 %> */

(function() {
  angular.module('soil.collection.mock', []).factory('soilCollection', [
    '$http', function($http) {
      var soilCollection;
      return soilCollection = (function() {
        var _this = this;

        function soilCollection(_source_url) {
          this._source_url = _source_url;
          this.members = void 0;
        }

        soilCollection.prototype.loadAll = jasmine.createSpy().andCallFake(function() {
          var members;
          return members = [];
        });

        return soilCollection;

      }).call(this);
    }
  ]);

}).call(this);
