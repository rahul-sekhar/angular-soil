/* angular-soil 0.3.5 %> */

(function() {
  angular.module('soil.collection', []).factory('soilCollection', [
    '$http', function($http) {
      var soilCollection;
      return soilCollection = (function() {
        function soilCollection(_modelClass, _sourceUrl) {
          this._modelClass = _modelClass;
          this._sourceUrl = _sourceUrl;
          if (!_.isFunction(this._modelClass)) {
            throw 'Expected a model class as the first argument when instantiating soilCollection';
          }
          this.members = void 0;
        }

        soilCollection.prototype.loadAll = function() {
          var _this = this;
          return $http.get(this._sourceUrl).success(function(items) {
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
          return $http.post(this._sourceUrl, data).success(function(response_data) {
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
          }
        }

        soilModel.prototype._base_url = '/';

        soilModel.prototype.getById = function(id) {
          var _this = this;
          return $http.get(this.url(id)).success(function(responseData) {
            return _this._load(responseData);
          });
        };

        soilModel.prototype.isLoaded = function() {
          return !!this.id;
        };

        soilModel.prototype.url = function(id) {
          if (id == null) {
            id = this.id;
          }
          if (id) {
            return this._withSlash(this._base_url) + id;
          } else {
            return this._base_url;
          }
        };

        soilModel.prototype.updateField = function(field) {
          var data,
            _this = this;
          if (this.isLoaded()) {
            data = {};
            data[field] = this[field];
            return $http.put(this.url(), data).success(function(responseData) {
              _this[field] = responseData[field];
              return _this._savedData = responseData;
            }).error(function() {
              return _this[field] = _this._savedData[field];
            });
          } else {
            throw 'Cannot update model without an ID';
          }
        };

        soilModel.prototype.save = function(field) {
          var _this = this;
          if (this.isLoaded()) {
            return $http.put(this.url(), this._dataToSave()).success(function(responseData) {
              return _this._load(responseData);
            });
          } else {
            throw 'Cannot save model without an ID';
          }
        };

        soilModel.prototype._load = function(data) {
          _.forOwn(this, function(value, key, obj) {
            if (_.first(key) !== '_') {
              return delete obj[key];
            }
          });
          _.assign(this, data);
          return this._savedData = data || {};
        };

        soilModel.prototype._withSlash = function(url) {
          return url.replace(/\/?$/, '/');
        };

        soilModel.prototype._fieldsToSave = [];

        soilModel.prototype._dataToSave = function() {
          var data,
            _this = this;
          data = {};
          _.each(this._fieldsToSave, function(field) {
            return data[field] = _this[field] === void 0 ? null : _this[field];
          });
          return data;
        };

        return soilModel;

      })();
    }
  ]);

}).call(this);
