/* angular-soil 0.5.0 %> */

(function() {
  angular.module('soil.collection', []).factory('soilCollection', [
    '$http', function($http) {
      var soilCollection;
      return soilCollection = (function() {
        function soilCollection(_modelClass) {
          this._modelClass = _modelClass;
          this.members = void 0;
        }

        soilCollection.prototype.load = function(data) {
          var _this = this;
          data || (data = []);
          return this.members = _.map(data, function(modelData) {
            return new _this._modelClass(modelData);
          });
        };

        soilCollection.prototype.get = function(url) {
          var _this = this;
          return $http.get(url).success(function(data) {
            return _this.load(data);
          });
        };

        soilCollection.prototype.add = function(item) {
          return this.members.push(item);
        };

        soilCollection.prototype.addToFront = function(item) {
          return this.members.unshift(item);
        };

        soilCollection.prototype.removeById = function(id) {
          return _.remove(this.members, function(item) {
            return item.id === id;
          });
        };

        soilCollection.prototype.remove = function(itemToRemove) {
          return _.remove(this.members, function(item) {
            return itemToRemove === item;
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
        soilModel.prototype._baseUrl = '/';

        function soilModel(arg) {
          if (angular.isNumber(arg)) {
            this.get(arg);
          } else if (angular.isObject(arg)) {
            this.load(arg);
          }
        }

        soilModel.prototype.setBaseUrl = function(newUrl) {
          return this._baseUrl = newUrl;
        };

        soilModel.prototype.url = function(id) {
          if (id == null) {
            id = this.id;
          }
          if (id) {
            return this._withSlash(this._baseUrl) + id;
          } else {
            return this._baseUrl;
          }
        };

        soilModel.prototype.load = function(data) {
          this._clearFields();
          _.assign(this, data);
          return this.savedData = data || {};
        };

        soilModel.prototype.get = function(id) {
          var _this = this;
          return $http.get(this.url(id)).success(function(responseData) {
            return _this.load(responseData);
          });
        };

        soilModel.prototype.loaded = function() {
          return !!this.id;
        };

        soilModel.prototype.save = function() {
          var _this = this;
          if (this.id) {
            return $http.put(this.url(), this._dataToSave()).success(function(responseData) {
              return _this.load(responseData);
            });
          } else {
            return $http.post(this.url(), this._dataToSave()).success(function(responseData) {
              return _this.load(responseData);
            });
          }
        };

        soilModel.prototype["delete"] = function() {
          var _this = this;
          this._checkIfLoaded();
          return $http["delete"](this.url()).success(function() {
            return _this.load(null);
          });
        };

        soilModel.prototype.updateField = function(field) {
          var data,
            _this = this;
          this._checkIfLoaded();
          data = {};
          data[field] = this[field];
          return $http.put(this.url(), data).success(function(responseData) {
            _this[field] = responseData[field];
            return _this.savedData = responseData;
          }).error(function() {
            return _this[field] = _this.savedData[field];
          });
        };

        soilModel.prototype._checkIfLoaded = function() {
          if (!this.loaded()) {
            throw 'Operation not permitted on an unloaded model';
          }
        };

        soilModel.prototype._clearFields = function() {
          return _.forOwn(this, function(value, key, obj) {
            if (_.first(key) !== '_') {
              return delete obj[key];
            }
          });
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
