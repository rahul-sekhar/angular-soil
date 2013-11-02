angular-soil
============

AngularJS modules with a model and collection base. Tailored specifically to development with Ruby on Rails.

Dependencies
------------
- [AngularJS 1.2.0rc3](http://angularjs.org)
- [Lo-Dash](http://lodash.com/)

soilCollection
--------------
Include the module `soil.collection` like this:

```javascript
angular.module('your-module', ['soil.collection'])
```

The SoilCollection class can then be injected where required:

```javascript
angular.module('your-module')
  .factory('yourFactory', ['soilCollection', function (soilCollection)
    // ...
])
```