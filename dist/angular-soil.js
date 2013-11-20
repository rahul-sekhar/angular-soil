/* angular-soil 0.8.0 %> */

(function() {
  angular.module('soil.association', ['soil.collection']).factory('HasOneAssociation', [
    function() {
      var HasOneAssociation;
      return HasOneAssociation = (function() {
        function HasOneAssociation(_field, _modelClass, options) {
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

        HasOneAssociation.prototype.beforeLoad = function(data) {
          if (data[this._field]) {
            return data[this._field] = new this._modelClass(data[this._field]);
          } else if (data[this._idField]) {
            data[this._field] = new this._modelClass(data[this._idField]);
            return delete data[this._idField];
          }
        };

        HasOneAssociation.prototype.beforeSave = function(data) {
          if (data[this._field]) {
            if (this._options.saveData) {
              return data[this._field] = data[this._field].dataToSave();
            } else {
              data[this._idField] = data[this._field].id;
              return delete data[this._field];
            }
          }
        };

        return HasOneAssociation;

      })();
    }
  ]).factory('HasManyAssociation', [
    'SoilCollection', function(SoilCollection) {
      var HasManyAssociation;
      return HasManyAssociation = (function() {
        function HasManyAssociation(_field, _idField, _modelClass, options) {
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

        HasManyAssociation.prototype.beforeLoad = function(data, parent) {
          var collection, parentUrl;
          if (data[this._field]) {
            parentUrl = parent.url(data.id || parent.id);
            collection = new SoilCollection(this._modelClass, parentUrl + '/' + this._field);
            return data[this._field] = collection.load(data[this._field]);
          }
        };

        HasManyAssociation.prototype.beforeSave = function(data) {
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

        return HasManyAssociation;

      })();
    }
  ]);

}).call(this);

(function() {
  angular.module('soil.collection', []).factory('SoilCollection', [
    '$http', function($http) {
      var SoilCollection;
      return SoilCollection = (function() {
        function SoilCollection(modelClass, _sourceUrl, options) {
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

        SoilCollection.prototype.load = function(data) {
          var _this = this;
          data || (data = []);
          this.members = _.map(data, function(modelData) {
            return new _this.modelClass(modelData);
          });
          return this;
        };

        SoilCollection.prototype.get = function() {
          var _this = this;
          return $http.get(this._sourceUrl).success(function(data) {
            return _this.load(data);
          });
        };

        SoilCollection.prototype.add = function(data) {
          var newItem;
          newItem = new this.modelClass(data);
          this.members.push(newItem);
          return newItem;
        };

        SoilCollection.prototype.addToFront = function(data) {
          var newItem;
          newItem = new this.modelClass(data);
          this.members.unshift(newItem);
          return newItem;
        };

        SoilCollection.prototype.create = function(data, options) {
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

        SoilCollection.prototype.removeById = function(id) {
          return _.remove(this.members, function(item) {
            return item.id === id;
          });
        };

        SoilCollection.prototype.remove = function(itemToRemove) {
          return _.remove(this.members, function(item) {
            return itemToRemove === item;
          });
        };

        SoilCollection.prototype.loaded = function() {
          return !(this.members === void 0);
        };

        return SoilCollection;

      })();
    }
  ]);

}).call(this);

(function() {
  angular.module('soil.model', []).factory('SoilModel', [
    '$http', function($http) {
      var SoilModel;
      return SoilModel = (function() {
        SoilModel.prototype._baseUrl = '/';

        SoilModel.prototype._fieldsToSave = [];

        SoilModel.prototype._associations = [];

        function SoilModel(arg) {
          if (angular.isObject(arg)) {
            this.load(arg);
          } else if (arg) {
            this.get(arg);
          }
        }

        SoilModel.prototype.setBaseUrl = function(newUrl) {
          return this._baseUrl = newUrl;
        };

        SoilModel.prototype.url = function(id) {
          if (id == null) {
            id = this.id;
          }
          if (id) {
            return this._withSlash(this._baseUrl) + id;
          } else {
            return this._baseUrl;
          }
        };

        SoilModel.prototype.load = function(data) {
          var modifiedData;
          modifiedData = this._modifyDataBeforeLoad(data);
          this._clearFields();
          this._setSavedData(data);
          _.assign(this, modifiedData);
          return this;
        };

        SoilModel.prototype.get = function(id) {
          var _this = this;
          return $http.get(this.url(id)).success(function(responseData) {
            return _this.load(responseData);
          });
        };

        SoilModel.prototype.loaded = function() {
          return !!this.id;
        };

        SoilModel.prototype.save = function() {
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

        SoilModel.prototype["delete"] = function() {
          var _this = this;
          this._checkIfLoaded();
          return $http["delete"](this.url()).success(function() {
            return _this.load(null);
          });
        };

        SoilModel.prototype.updateField = function(field) {
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

        SoilModel.prototype.revertField = function(field) {
          var restoreData;
          restoreData = this._modifyDataBeforeLoad(this.savedData);
          return this[field] = restoreData[field];
        };

        SoilModel.prototype.dataToSave = function() {
          var data,
            _this = this;
          data = {};
          _.each(this._fieldsToSave, function(field) {
            return data[field] = _this[field] === void 0 ? null : _this[field];
          });
          return this._modifyDataBeforeSave(data);
        };

        SoilModel.prototype._checkIfLoaded = function() {
          if (!this.loaded()) {
            throw 'Operation not permitted on an unloaded model';
          }
        };

        SoilModel.prototype._clearFields = function() {
          return _.forOwn(this, function(value, key, obj) {
            if (!(_.first(key) === '_' || angular.isFunction(value))) {
              return delete obj[key];
            }
          });
        };

        SoilModel.prototype._withSlash = function(url) {
          return url.replace(/\/?$/, '/');
        };

        SoilModel.prototype._fieldsToSave = [];

        SoilModel.prototype._modifyDataBeforeLoad = function(loadData) {
          var data,
            _this = this;
          data = _.clone(loadData);
          _.each(this._associations, function(association) {
            return association.beforeLoad(data, _this);
          });
          return data;
        };

        SoilModel.prototype._modifyDataBeforeSave = function(saveData) {
          var data,
            _this = this;
          data = _.clone(saveData);
          _.each(this._associations, function(association) {
            return association.beforeSave(data, _this);
          });
          return data;
        };

        SoilModel.prototype._setSavedData = function(data) {
          return this.savedData = data ? _.cloneDeep(data) : {};
        };

        return SoilModel;

      })();
    }
  ]);

}).call(this);
