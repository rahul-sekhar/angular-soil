/* angular-soil 0.7.0 %> */

(function() {
  angular.module('soil.association', ['soil.collection']).factory('hasOneAssociation', [
    function() {
      var hasOneAssociation;
      return hasOneAssociation = (function() {
        function hasOneAssociation(_field, _modelClass, options) {
          this._field = _field;
          this._modelClass = _modelClass;
          if (options == null) {
            options = {};
          }
          this._options = _.defaults(options, {
            saveData: false
          });
          this._idField = this._field + '_id';
        }

        hasOneAssociation.prototype.beforeLoad = function(data) {
          if (data[this._field]) {
            return data[this._field] = new this._modelClass(data[this._field]);
          } else if (data[this._idField]) {
            data[this._field] = new this._modelClass(data[this._idField]);
            return delete data[this._idField];
          }
        };

        hasOneAssociation.prototype.beforeSave = function(data) {
          if (data[this._field]) {
            if (this._options.saveData) {
              return data[this._field] = data[this._field].dataToSave();
            } else {
              data[this._idField] = data[this._field].id;
              return delete data[this._field];
            }
          }
        };

        return hasOneAssociation;

      })();
    }
  ]).factory('hasManyAssociation', [
    'soilCollection', function(soilCollection) {
      var hasManyAssociation;
      return hasManyAssociation = (function() {
        function hasManyAssociation(_field, _idField, _modelClass, options) {
          this._field = _field;
          this._idField = _idField;
          this._modelClass = _modelClass;
          if (options == null) {
            options = {};
          }
          this._options = _.defaults(options, {
            saveData: false
          });
        }

        hasManyAssociation.prototype.beforeLoad = function(data, parent) {
          var collection, parentUrl;
          if (data[this._field]) {
            parentUrl = parent.url(data.id || parent.id);
            collection = new soilCollection(this._modelClass, parentUrl + '/' + this._field);
            return data[this._field] = collection.load(data[this._field]);
          }
        };

        hasManyAssociation.prototype.beforeSave = function(data) {
          if (data[this._field]) {
            if (this._options.saveData) {
              return data[this._field] = _.map(data[this._field].members, function(member) {
                return member.dataToSave();
              });
            } else {
              data[this._idField] = _.map(data[this._field].members, function(member) {
                return member.id;
              });
              return delete data[this._field];
            }
          }
        };

        return hasManyAssociation;

      })();
    }
  ]);

}).call(this);

(function() {
  angular.module('soil.collection', []).factory('soilCollection', [
    '$http', function($http) {
      var soilCollection;
      return soilCollection = (function() {
        function soilCollection(modelClass, _sourceUrl, options) {
          this.modelClass = modelClass;
          this._sourceUrl = _sourceUrl;
          if (options == null) {
            options = {};
          }
          this._options = _.defaults(options, {
            getData: false
          });
          this.members = void 0;
          if (this._options.getData) {
            this.get();
          }
        }

        soilCollection.prototype.load = function(data) {
          var _this = this;
          data || (data = []);
          this.members = _.map(data, function(modelData) {
            return new _this.modelClass(modelData);
          });
          return this;
        };

        soilCollection.prototype.get = function() {
          var _this = this;
          return $http.get(this._sourceUrl).success(function(data) {
            return _this.load(data);
          });
        };

        soilCollection.prototype.add = function(data) {
          var newItem;
          newItem = new this.modelClass(data);
          this.members.push(newItem);
          return newItem;
        };

        soilCollection.prototype.addToFront = function(data) {
          var newItem;
          newItem = new this.modelClass(data);
          this.members.unshift(newItem);
          return newItem;
        };

        soilCollection.prototype.create = function(data, options) {
          var _this = this;
          if (options == null) {
            options = {};
          }
          options = _.defaults(options, {
            addToFront: false
          });
          return $http.post(this._sourceUrl, data).success(function(responseData) {
            if (options.addToFront) {
              return _this.addToFront(responseData);
            } else {
              return _this.add(responseData);
            }
          });
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

        soilCollection.prototype.loaded = function() {
          return !(this.members === void 0);
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

        soilModel.prototype._fieldsToSave = [];

        soilModel.prototype._associations = [];

        function soilModel(arg) {
          if (angular.isObject(arg)) {
            this.load(arg);
          } else if (arg) {
            this.get(arg);
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
          var modifiedData;
          modifiedData = this._modifyDataBeforeLoad(data);
          this._clearFields();
          this._setSavedData(data);
          _.assign(this, modifiedData);
          return this;
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
            return $http.put(this.url(), this.dataToSave()).success(function(responseData) {
              return _this.load(responseData);
            });
          } else {
            return $http.post(this.url(), this.dataToSave()).success(function(responseData) {
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
          data = this._modifyDataBeforeSave(data);
          return $http.put(this.url(), data).success(function(responseData) {
            var fieldData;
            _this.savedData = _.cloneDeep(responseData);
            fieldData = _.pick(responseData, field);
            fieldData = _this._modifyDataBeforeLoad(fieldData);
            return _this[field] = fieldData[field];
          }).error(function() {
            return _this.revertField(field);
          });
        };

        soilModel.prototype.revertField = function(field) {
          var restoreData;
          restoreData = this._modifyDataBeforeLoad(this.savedData);
          return this[field] = restoreData[field];
        };

        soilModel.prototype.dataToSave = function() {
          var data,
            _this = this;
          data = {};
          _.each(this._fieldsToSave, function(field) {
            return data[field] = _this[field] === void 0 ? null : _this[field];
          });
          return this._modifyDataBeforeSave(data);
        };

        soilModel.prototype._checkIfLoaded = function() {
          if (!this.loaded()) {
            throw 'Operation not permitted on an unloaded model';
          }
        };

        soilModel.prototype._clearFields = function() {
          return _.forOwn(this, function(value, key, obj) {
            if (!(_.first(key) === '_' || angular.isFunction(value))) {
              return delete obj[key];
            }
          });
        };

        soilModel.prototype._withSlash = function(url) {
          return url.replace(/\/?$/, '/');
        };

        soilModel.prototype._fieldsToSave = [];

        soilModel.prototype._modifyDataBeforeLoad = function(loadData) {
          var data,
            _this = this;
          data = _.clone(loadData);
          _.each(this._associations, function(association) {
            return association.beforeLoad(data, _this);
          });
          return data;
        };

        soilModel.prototype._modifyDataBeforeSave = function(saveData) {
          var data,
            _this = this;
          data = _.clone(saveData);
          _.each(this._associations, function(association) {
            return association.beforeSave(data, _this);
          });
          return data;
        };

        soilModel.prototype._setSavedData = function(data) {
          return this.savedData = data ? _.cloneDeep(data) : {};
        };

        return soilModel;

      })();
    }
  ]);

}).call(this);
