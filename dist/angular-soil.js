/* angular-soil v0.1.0 %> */

(function() {
  angular.module('soil-collection', []).factory('soilCollection', [
    '$http', function($http) {
      var Collection;
      return Collection = (function() {
        function Collection(_source_url) {
          this._source_url = _source_url;
          this.members = void 0;
        }

        Collection.prototype.loadAll = function() {
          var _this = this;
          return $http.get(this._source_url).success(function(data) {
            return _this.members = data;
          });
        };

        return Collection;

      })();
    }
  ]);

}).call(this);
