/* angular-soil v0.1.1 %> */

(function() {
  angular.module('soil.collection', []).factory('soilCollection', [
    '$http', function($http) {
      var soilCollection;
      return soilCollection = (function() {
        function soilCollection(_modelClass, _source_url) {
          this._modelClass = _modelClass;
          this._source_url = _source_url;
          this.members = void 0;
        }

        soilCollection.prototype.loadAll = function() {
          var _this = this;
          return $http.get(this._source_url).success(function(data) {
            return _this.members = data;
          });
        };

        soilCollection.prototype.addItem = function(data) {
          var _this = this;
          if (this.members === void 0) {
            return;
          }
          return $http.post(this._source_url, data).success(function(response_data) {
            var newModel;
            newModel = new _this._modelClass(response_data);
            return _this.members.push(newModel);
          });
        };

        return soilCollection;

      })();
    }
  ]);

}).call(this);

(function() {
  angular.module('soil.model', []).factory('soilModel', [
    '$http', function($http) {
      var soilModel;
      return soilModel = (function() {
        function soilModel(data) {
          this.load(data);
        }

        soilModel.prototype.load = function(data) {
          _.forOwn(this, function(value, key, obj) {
            if (_.first(key) !== '_') {
              return delete obj[key];
            }
          });
          return _.assign(this, data);
        };

        soilModel.prototype._url = '/';

        return soilModel;

      })();
    }
  ]);

}).call(this);
