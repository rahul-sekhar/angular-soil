/* angular-soil v0.1.0 %> */

(function() {
  angular.module('soil.collection', []).factory('soilCollection', [
    '$http', function($http) {
      var soilCollection;
      return soilCollection = (function() {
        function soilCollection(_source_url) {
          this._source_url = _source_url;
          this.members = void 0;
        }

        soilCollection.prototype.loadAll = function() {
          var _this = this;
          return $http.get(this._source_url).success(function(data) {
            return _this.members = data;
          });
        };

        return soilCollection;

      })();
    }
  ]);

}).call(this);
