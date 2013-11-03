/* angular-soil 0.1.4 %> */

(function() {
  angular.module('soil.collection', []).factory('soilCollection', [
    '$http', function($http) {
      var soilCollection;
      return soilCollection = (function() {
        function soilCollection(_modelClass, _source_url) {
          this._modelClass = _modelClass;
          this._source_url = _source_url;
          if (!_.isFunction(this._modelClass)) {
            throw 'Expected a model class as the first argument when instantiating soilCollection';
          }
          this.members = void 0;
        }

        soilCollection.prototype.loadAll = function() {
          var _this = this;
          return $http.get(this._source_url).success(function(items) {
            return _this.members = _.map(items, function(item) {
              return new _this._modelClass(item);
            });
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

        soilModel.prototype._base_url = '/';

        soilModel.prototype.load = function(data) {
          _.forOwn(this, function(value, key, obj) {
            if (_.first(key) !== '_') {
              return delete obj[key];
            }
          });
          return _.assign(this, data);
        };

        soilModel.prototype.url = function() {
          if (this.id) {
            return this._with_slash(this._base_url) + this.id;
          } else {
            return this._base_url;
          }
        };

        soilModel.prototype.refresh = function() {
          var _this = this;
          if (this.id) {
            return $http.get(this.url()).success(function(data) {
              return _this.load(data);
            });
          } else {
            throw 'Cannot refresh model without an ID';
          }
        };

        soilModel.prototype._with_slash = function(url) {
          return url.replace(/\/?$/, '/');
        };

        return soilModel;

      })();
    }
  ]);

}).call(this);
