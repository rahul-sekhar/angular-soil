/* angular-soil 1.6.3 %> */

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  angular.module('soil.association', ['soil.collection']).factory('HasOneAssociation', [
    '$injector', function($injector) {
      var HasOneAssociation;
      return HasOneAssociation = (function() {
        function HasOneAssociation(_field, modelClass, options) {
          this._field = _field;
          if (options == null) {
            options = {};
          }
          this._options = _.defaults(options, {
            saveData: false,
            buildEmpty: false
          });
          this._modelClass = $injector.get(modelClass);
          this._idField = this._field + '_id';
        }

        HasOneAssociation.prototype.beforeLoad = function(data, parent) {
          if (!data) {
            return;
          }
          if (data[this._field]) {
            return data[this._field] = this._createModelInstance(parent, data[this._field]);
          } else if (data[this._idField]) {
            data[this._field] = this._createModelInstance(parent, data[this._idField]);
            return delete data[this._idField];
          } else if (this._options.buildEmpty) {
            return data[this._field] = this._createModelInstance(parent);
          }
        };

        HasOneAssociation.prototype.beforeSave = function(data) {
          var id;
          if (data[this._field]) {
            if (this._options.saveData) {
              id = data[this._field].id;
              data[this._field] = data[this._field].$dataToSave();
              return data[this._field].id = id;
            } else {
              data[this._idField] = data[this._field].id;
              return delete data[this._field];
            }
          } else if (data[this._field] !== void 0) {
            if (!this._options.saveData) {
              data[this._idField] = null;
              return delete data[this._field];
            }
          }
        };

        HasOneAssociation.prototype.setScope = function(scope, parent) {
          if (parent[this._field]) {
            return parent[this._field].$setScope(scope);
          }
        };

        HasOneAssociation.prototype._createModelInstance = function(parent, data) {
          var model;
          model = new this._modelClass(parent._scope, data);
          model._parent = parent;
          return model;
        };

        return HasOneAssociation;

      })();
    }
  ]).factory('HasManyAssociation', [
    'SoilCollection', '$injector', function(SoilCollection, $injector) {
      var HasManyAssociation;
      return HasManyAssociation = (function() {
        function HasManyAssociation(_field, _idField, modelClass, options) {
          this._field = _field;
          this._idField = _idField;
          if (options == null) {
            options = {};
          }
          this._options = _.defaults(options, {
            saveData: false,
            nestedUpdate: false
          });
          this._modelClass = $injector.get(modelClass);
        }

        HasManyAssociation.prototype.beforeLoad = function(data, parent) {
          var associationUrl, collection;
          if (!data) {
            return;
          }
          associationUrl = parent.$url(data.slug || data.id || parent.slug || parent.id) + '/' + this._field;
          if (data[this._field]) {
            collection = this._createCollection(parent, this._modelClassFor(associationUrl), associationUrl);
            return data[this._field] = collection.$load(data[this._field]);
          } else {
            return data[this._field] = this._createCollection(parent, this._modelClass, associationUrl);
          }
        };

        HasManyAssociation.prototype.beforeSave = function(data, parent) {
          if (data[this._field]) {
            if (this._options.saveData) {
              return data[this._field] = _.map(data[this._field].$members, function(member) {
                return _.merge({
                  id: member.id
                }, member.$dataToSave());
              });
            } else {
              data[this._idField] = _.map(data[this._field].$members, function(member) {
                return member.id;
              });
              return delete data[this._field];
            }
          }
        };

        HasManyAssociation.prototype.setScope = function(scope, parent) {
          if (parent[this._field]) {
            return parent[this._field].$setScope(scope);
          }
        };

        HasManyAssociation.prototype._modelClassFor = function(url) {
          var extendedModel;
          if (this._options.nestedUpdate) {
            return extendedModel = (function(_super) {
              __extends(extendedModel, _super);

              function extendedModel() {
                return extendedModel.__super__.constructor.apply(this, arguments);
              }

              extendedModel.prototype._baseUrl = url;

              return extendedModel;

            })(this._modelClass);
          } else {
            return this._modelClass;
          }
        };

        HasManyAssociation.prototype._createCollection = function(parent, modelClass, url) {
          var collection;
          collection = new SoilCollection(parent._scope, modelClass, url);
          collection._parent = parent;
          return collection;
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
    '$http', '$q', function($http, $q) {
      var SoilCollection;
      return SoilCollection = (function() {
        function SoilCollection(_scope, modelClass, sourceUrl) {
          this._scope = _scope;
          this.modelClass = modelClass;
          this.sourceUrl = sourceUrl;
          this.$members = [];
          this._initialLoad = $q.defer();
          this.$afterInitialLoad = this._initialLoad.promise;
          if (this._scope) {
            this._setupListeners();
          }
        }

        SoilCollection.prototype.$load = function(data, append) {
          if (!angular.isArray(data) && angular.isObject(data)) {
            this.data = data.data;
            data = data.items;
          }
          if (append == null) {
            this.$members = [];
          }
          data || (data = []);
          _.each(data, (function(_this) {
            return function(modelData) {
              return _this.$add(modelData);
            };
          })(this));
          return this;
        };

        SoilCollection.prototype.$get = function() {
          return $http.get(this.sourceUrl).success((function(_this) {
            return function(data) {
              _this.$load(data);
              return _this._initialLoad.resolve();
            };
          })(this));
        };

        SoilCollection.prototype.$add = function(data) {
          var newItem;
          newItem = this._createModel(data);
          this.$members.push(newItem);
          return newItem;
        };

        SoilCollection.prototype.$addToFront = function(data) {
          var newItem;
          newItem = this._createModel(data);
          this.$members.unshift(newItem);
          return newItem;
        };

        SoilCollection.prototype.$addAt = function(index, data) {
          var newItem;
          newItem = this._createModel(data);
          this.$members.splice(index, 0, newItem);
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

        SoilCollection.prototype.$find = function(id) {
          return _.find(this.$members, function(member) {
            return member.id === id;
          });
        };

        SoilCollection.prototype.$setScope = function(scope) {
          if (this._scope) {
            throw 'Scope has already been set';
          }
          this._scope = scope;
          this._setupListeners();
          return _.each(this.$members, (function(_this) {
            return function(member) {
              member.$setScope(scope);
            };
          })(this));
        };

        SoilCollection.prototype._setupListeners = function() {
          return this._scope.$on('modelDeleted', (function(_this) {
            return function(e, type, id) {
              if (type === _this.modelClass.prototype._modelType) {
                return _this.$removeById(id);
              }
            };
          })(this));
        };

        SoilCollection.prototype._createModel = function(data) {
          var model;
          model = new this.modelClass(this._scope, data);
          model.$setPostUrl(this.sourceUrl);
          if (this._parent) {
            model._parent = this._parent;
          }
          return model;
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
          this._setupCreateListeners();
          this.$afterInitialLoad.then((function(_this) {
            return function() {
              return _this._loaded = true;
            };
          })(this));
          this.$get();
        }

        GlobalSoilCollection.prototype._setupCreateListeners = function() {
          this._scope.$on('modelSaved', (function(_this) {
            return function(e, model, data) {
              if (model._modelType === _this.modelClass.prototype._modelType) {
                if (!_.any(_this.$members, function(member) {
                  return member.id === model.id;
                })) {
                  return _this.$add(data);
                }
              }
            };
          })(this));
          return this._scope.$on('modelCreateFailed', (function(_this) {
            return function(e, model) {
              if (model._modelType === _this.modelClass.prototype._modelType) {
                return _this.$remove(model);
              }
            };
          })(this));
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

        SoilModel.prototype._initializeFields = function() {};

        function SoilModel(_scope, arg) {
          this._scope = _scope;
          this._dataLoadedCallback = function() {};
          this.$saved = {};
          if (angular.isObject(arg)) {
            this.$load(arg);
          } else if (arg) {
            this.$get(arg);
          } else {
            this.$load({});
          }
          if (this._scope) {
            this._setupListeners();
          }
        }

        SoilModel.prototype.$onDataLoaded = function(_dataLoadedCallback) {
          this._dataLoadedCallback = _dataLoadedCallback;
        };

        SoilModel.prototype.$setBaseUrl = function(newUrl) {
          return this._baseUrl = newUrl;
        };

        SoilModel.prototype.$setPostUrl = function(newUrl) {
          return this._postUrl = newUrl;
        };

        SoilModel.prototype.$url = function(id) {
          id || (id = this.slug || this.id);
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
          this._dataLoadedCallback();
          return this;
        };

        SoilModel.prototype.$get = function(id) {
          return $http.get(this.$url(id)).then((function(_this) {
            return function(response) {
              return _this.$load(response.data);
            };
          })(this));
        };

        SoilModel.prototype.$save = function(url, loadData) {
          var sendRequest;
          if (loadData == null) {
            loadData = true;
          }
          sendRequest = this.id ? $http.put : $http.post;
          url || (url = this.$url());
          return sendRequest(url, this.$dataToSave()).success((function(_this) {
            return function(responseData) {
              if (loadData) {
                _this.$load(responseData);
              }
              return $rootScope.$broadcast('modelSaved', _this, responseData);
            };
          })(this)).error((function(_this) {
            return function() {
              if (!_this.id) {
                return $rootScope.$broadcast('modelCreateFailed', _this);
              }
            };
          })(this)).then((function(_this) {
            return function() {
              return _this;
            };
          })(this));
        };

        SoilModel.prototype.$delete = function() {
          if (this.id) {
            return $http["delete"](this.$url()).success((function(_this) {
              return function() {
                $rootScope.$broadcast('modelDeleted', _this._modelType, _this.id);
                return _this.$load(null);
              };
            })(this));
          } else {
            return $rootScope.$broadcast('modelCreateFailed', this);
          }
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
          var data;
          this._checkIfLoaded();
          data = {};
          data[field] = this[field];
          data = this._modifyDataBeforeSave(data);
          return $http.put(this.$url(), data).success((function(_this) {
            return function(responseData) {
              _this._loadField(field, responseData);
              return $rootScope.$broadcast('modelFieldUpdated', _this, field, responseData);
            };
          })(this)).error((function(_this) {
            return function() {
              return _this.$revertField(field);
            };
          })(this)).then((function(_this) {
            return function() {
              return _this;
            };
          })(this));
        };

        SoilModel.prototype.$revertField = function(field) {
          var restoreData;
          restoreData = this._modifyDataBeforeLoad(this.$saved);
          return this[field] = restoreData[field];
        };

        SoilModel.prototype.$dataToSave = function() {
          var data, fields;
          fields = this._fieldsToSave;
          if (!this.id) {
            fields = fields.concat(this._fieldsToSaveOnCreate);
          }
          data = {};
          _.each(fields, (function(_this) {
            return function(field) {
              data[field] = _this[field] === void 0 ? null : _this[field];
            };
          })(this));
          return this._modifyDataBeforeSave(data);
        };

        SoilModel.prototype.$setScope = function(scope) {
          if (this._scope) {
            throw 'Scope has already been set';
          }
          this._scope = scope;
          this._setupListeners();
          return _.each(this._associations, (function(_this) {
            return function(association) {
              association.setScope(scope, _this);
            };
          })(this));
        };

        SoilModel.prototype._loadField = function(field, data) {
          var fieldData;
          this.$saved = _.cloneDeep(data);
          fieldData = _.pick(data, field);
          fieldData = this._modifyDataBeforeLoad(fieldData);
          this[field] = fieldData[field];
          return this._dataLoadedCallback();
        };

        SoilModel.prototype._checkIfLoaded = function() {
          if (!this.id) {
            throw 'Operation not permitted on an unloaded model';
          }
        };

        SoilModel.prototype._clearFields = function() {
          _.forOwn(this, function(value, key, obj) {
            if (!(_.first(key) === '_' || angular.isFunction(value))) {
              delete obj[key];
            }
          });
          return this._initializeFields();
        };

        SoilModel.prototype._withSlash = function(url) {
          return url.replace(/\/?$/, '/');
        };

        SoilModel.prototype._fieldsToSave = [];

        SoilModel.prototype._modifyDataBeforeLoad = function(loadData) {
          var data;
          data = _.clone(loadData);
          _.each(this._associations, (function(_this) {
            return function(association) {
              association.beforeLoad(data, _this);
            };
          })(this));
          return data;
        };

        SoilModel.prototype._modifyDataBeforeSave = function(saveData) {
          var data;
          data = _.clone(saveData);
          _.each(this._associations, (function(_this) {
            return function(association) {
              association.beforeSave(data, _this);
            };
          })(this));
          return data;
        };

        SoilModel.prototype._setSavedData = function(data) {
          return this.$saved = data ? _.cloneDeep(data) : {};
        };

        SoilModel.prototype._setupListeners = function() {
          this._scope.$on('modelSaved', (function(_this) {
            return function(e, model, data) {
              if (_this.id && model !== _this && model._modelType === _this._modelType && model.id === _this.id) {
                return _this.$load(data);
              }
            };
          })(this));
          return this._scope.$on('modelFieldUpdated', (function(_this) {
            return function(e, model, field, data) {
              if (_this.id && model !== _this && model._modelType === _this._modelType && model.id === _this.id) {
                return _this._loadField(field, data);
              }
            };
          })(this));
        };

        return SoilModel;

      })();
    }
  ]);

}).call(this);
