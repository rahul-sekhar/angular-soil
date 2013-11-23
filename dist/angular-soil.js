/* angular-soil 1.0.0 %> */

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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

        HasOneAssociation.prototype.beforeLoad = function(data, parent) {
          if (data[this._field]) {
            return data[this._field] = new this._modelClass(parent._scope, data[this._field]);
          } else if (data[this._idField]) {
            data[this._field] = new this._modelClass(parent._scope, data[this._idField]);
            return delete data[this._idField];
          }
        };

        HasOneAssociation.prototype.beforeSave = function(data) {
          if (data[this._field]) {
            if (this._options.saveData) {
              return data[this._field] = data[this._field].$dataToSave();
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
            saveData: false,
            nestedUpdate: false
          });
        }

        HasManyAssociation.prototype.beforeLoad = function(data, parent) {
          var associationUrl, collection;
          if (data[this._field]) {
            associationUrl = parent.$url(data.id || parent.id) + '/' + this._field;
            collection = new SoilCollection(parent._scope, this._modelClassFor(associationUrl), associationUrl);
            return data[this._field] = collection.$load(data[this._field]);
          }
        };

        HasManyAssociation.prototype.beforeSave = function(data, parent) {
          if (data[this._field]) {
            if (this._options.saveData) {
              return data[this._field] = _.map(data[this._field].members, function(member) {
                return member.$dataToSave();
              });
            } else {
              data[this._idField] = _.map(data[this._field].members, function(member) {
                return member.id;
              });
              return delete data[this._field];
            }
          }
        };

        HasManyAssociation.prototype._modelClassFor = function(url) {
          var extendedModel, _ref;
          if (this._options.nestedUpdate) {
            return extendedModel = (function(_super) {
              __extends(extendedModel, _super);

              function extendedModel() {
                _ref = extendedModel.__super__.constructor.apply(this, arguments);
                return _ref;
              }

              extendedModel.prototype._baseUrl = url;

              return extendedModel;

            })(this._modelClass);
          } else {
            return this._modelClass;
          }
        };

        return HasManyAssociation;

      })();
    }
  ]);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  angular.module('soil.collection', []).factory('SoilCollection', [
    '$http', function($http) {
      var SoilCollection;
      return SoilCollection = (function() {
        function SoilCollection(_scope, modelClass, sourceUrl) {
          this._scope = _scope;
          this.modelClass = modelClass;
          this.sourceUrl = sourceUrl;
          this.$members = [];
          if (this._scope) {
            this._setupListeners();
          }
        }

        SoilCollection.prototype.$load = function(data) {
          var _this = this;
          data || (data = []);
          this.$members = _.map(data, function(modelData) {
            return new _this.modelClass(_this._scope, modelData);
          });
          return this;
        };

        SoilCollection.prototype.$get = function() {
          var _this = this;
          return $http.get(this.sourceUrl).success(function(data) {
            return _this.$load(data);
          });
        };

        SoilCollection.prototype.$add = function(data) {
          var newItem;
          newItem = new this.modelClass(this._scope, data);
          newItem.$setPostUrl(this.sourceUrl);
          this.$members.push(newItem);
          return newItem;
        };

        SoilCollection.prototype.$addToFront = function(data) {
          var newItem;
          newItem = new this.modelClass(this._scope, data);
          newItem.$setPostUrl(this.sourceUrl);
          this.$members.unshift(newItem);
          return newItem;
        };

        SoilCollection.prototype.$removeById = function(id) {
          return _.remove(this.$members, function(item) {
            return item.id === id;
          });
        };

        SoilCollection.prototype.$remove = function(itemToRemove) {
          return _.remove(this.$members, function(item) {
            return itemToRemove === item;
          });
        };

        SoilCollection.prototype._setupListeners = function() {
          var _this = this;
          return this._scope.$on('modelDeleted', function(e, type, id) {
            if (type === _this.modelClass.prototype._modelType) {
              return _this.$removeById(id);
            }
          });
        };

        return SoilCollection;

      })();
    }
  ]).factory('SoilGlobalCollection', [
    'SoilCollection', '$rootScope', function(SoilCollection, $rootScope) {
      var GlobalSoilCollection;
      return GlobalSoilCollection = (function(_super) {
        __extends(GlobalSoilCollection, _super);

        function GlobalSoilCollection(modelClass, sourceUrl) {
          GlobalSoilCollection.__super__.constructor.call(this, $rootScope, modelClass, sourceUrl);
          this._setupCreateListener();
        }

        GlobalSoilCollection.prototype._setupCreateListener = function() {
          var _this = this;
          return this._scope.$on('modelSaved', function(e, model, data) {
            if (model._modelType === _this.modelClass.prototype._modelType) {
              if (!_.any(_this.$members, function(member) {
                return member.id === model.id;
              })) {
                return _this.$add(data);
              }
            }
          });
        };

        return GlobalSoilCollection;

      })(SoilCollection);
    }
  ]);

}).call(this);

(function() {
  angular.module('soil.model', []).factory('SoilModel', [
    '$http', '$rootScope', function($http, $rootScope) {
      var SoilModel;
      return SoilModel = (function() {
        SoilModel.prototype._baseUrl = '/';

        SoilModel.prototype._fieldsToSave = [];

        SoilModel.prototype._fieldsToSaveOnCreate = [];

        SoilModel.prototype._associations = [];

        SoilModel.prototype._modelType = 'model';

        function SoilModel(_scope, arg) {
          this._scope = _scope;
          this.$saved = {};
          if (angular.isObject(arg)) {
            this.$load(arg);
          } else if (arg) {
            this.$get(arg);
          }
          if (this._scope) {
            this._setupListeners();
          }
        }

        SoilModel.prototype.$setBaseUrl = function(newUrl) {
          return this._baseUrl = newUrl;
        };

        SoilModel.prototype.$setPostUrl = function(newUrl) {
          return this._postUrl = newUrl;
        };

        SoilModel.prototype.$url = function(id) {
          if (id == null) {
            id = this.id;
          }
          if (id) {
            return this._withSlash(this._baseUrl) + id;
          } else {
            return this._postUrl || this._baseUrl;
          }
        };

        SoilModel.prototype.$load = function(data) {
          this._clearFields();
          this._setSavedData(data);
          _.assign(this, this._modifyDataBeforeLoad(data));
          return this;
        };

        SoilModel.prototype.$get = function(id) {
          var _this = this;
          return $http.get(this.$url(id)).success(function(responseData) {
            return _this.$load(responseData);
          });
        };

        SoilModel.prototype.$save = function() {
          var sendRequest,
            _this = this;
          sendRequest = this.id ? $http.put : $http.post;
          return sendRequest(this.$url(), this.$dataToSave()).success(function(responseData) {
            _this.$load(responseData);
            return $rootScope.$broadcast('modelSaved', _this, responseData);
          });
        };

        SoilModel.prototype.$delete = function() {
          var _this = this;
          this._checkIfLoaded();
          return $http["delete"](this.$url()).success(function() {
            $rootScope.$broadcast('modelDeleted', _this._modelType, _this.id);
            return _this.$load(null);
          });
        };

        SoilModel.prototype.$revert = function() {
          var savedData;
          savedData = this.$saved;
          this._clearFields();
          this._setSavedData(savedData);
          _.assign(this, this._modifyDataBeforeLoad(savedData));
          return this;
        };

        SoilModel.prototype.$updateField = function(field) {
          var data,
            _this = this;
          this._checkIfLoaded();
          data = {};
          data[field] = this[field];
          data = this._modifyDataBeforeSave(data);
          return $http.put(this.$url(), data).success(function(responseData) {
            _this._loadField(field, responseData);
            return $rootScope.$broadcast('modelFieldUpdated', _this, field, responseData);
          }).error(function() {
            return _this.$revertField(field);
          });
        };

        SoilModel.prototype.$revertField = function(field) {
          var restoreData;
          restoreData = this._modifyDataBeforeLoad(this.$saved);
          return this[field] = restoreData[field];
        };

        SoilModel.prototype.$dataToSave = function() {
          var data, fields,
            _this = this;
          fields = this._fieldsToSave;
          if (!this.id) {
            fields = fields.concat(this._fieldsToSaveOnCreate);
          }
          data = {};
          _.each(fields, function(field) {
            return data[field] = _this[field] === void 0 ? null : _this[field];
          });
          return this._modifyDataBeforeSave(data);
        };

        SoilModel.prototype._loadField = function(field, data) {
          var fieldData;
          this.$saved = _.cloneDeep(data);
          fieldData = _.pick(data, field);
          fieldData = this._modifyDataBeforeLoad(fieldData);
          return this[field] = fieldData[field];
        };

        SoilModel.prototype._checkIfLoaded = function() {
          if (!this.id) {
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
          return this.$saved = data ? _.cloneDeep(data) : {};
        };

        SoilModel.prototype._setupListeners = function() {
          var _this = this;
          this._scope.$on('modelSaved', function(e, model, data) {
            if (_this.id && model._modelType === _this._modelType && model.id === _this.id) {
              return _this.$load(data);
            }
          });
          return this._scope.$on('modelFieldUpdated', function(e, model, field, data) {
            if (_this.id && model._modelType === _this._modelType && model.id === _this.id) {
              return _this._loadField(field, data);
            }
          });
        };

        return SoilModel;

      })();
    }
  ]);

}).call(this);
