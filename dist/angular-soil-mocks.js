/* angular-soil v0.1.0 %> */

(function() {
  angular.module('soil.collection.mock', []).factory('soilCollection', [
    '$http', function($http) {
      var soilCollection;
      return soilCollection = (function() {
        function soilCollection(_source_url) {
          this._source_url = _source_url;
          this.members = void 0;
        }

        soilCollection.prototype.loadAll = jasmine.createSpy();

        return soilCollection;

      })();
    }
  ]);

}).call(this);
