/* angular-soil 0.3.5 %> */

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
        function soilModel(dataOrId) {
          if (angular.isObject(dataOrId)) {
            this._load(dataOrId);
          } else if (dataOrId) {
            this._getById(dataOrId);
          }
        }

        soilModel.prototype._base_url = '/';

        soilModel.prototype.isLoaded = function() {
          return !!this.id;
        };

        soilModel.prototype.url = function(id) {
          if (id == null) {
            id = this.id;
          }
          if (id) {
            return this._with_slash(this._base_url) + id;
          } else {
            return this._base_url;
          }
        };

        soilModel.prototype.updateField = function(field) {
          var data,
            _this = this;
          if (this.id) {
            data = {};
            data[field] = this[field];
            return $http.put(this.url(), data).success(function(response_data) {
              _this[field] = response_data[field];
              return _this._saved_data = response_data;
            }).error(function() {
              return _this[field] = _this._saved_data[field];
            });
          } else {
            throw 'Cannot update model without an ID';
          }
        };

        soilModel.prototype._load = function(data) {
          _.forOwn(this, function(value, key, obj) {
            if (_.first(key) !== '_') {
              return delete obj[key];
            }
          });
          _.assign(this, data);
          return this._saved_data = data || {};
        };

        soilModel.prototype._getById = function(id) {
          var _this = this;
          return $http.get(this.url(id)).success(function(response_data) {
            return _this._load(response_data);
          });
        };

        soilModel.prototype._with_slash = function(url) {
          return url.replace(/\/?$/, '/');
        };

        return soilModel;

      })();
    }
  ]);

}).call(this);
