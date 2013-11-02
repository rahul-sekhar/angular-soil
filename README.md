angular-soil
============

AngularJS modules with a model and collection base. Tailored specifically to development with Ruby on Rails.

Dependencies
------------
AngularJS 1.2.0rc3

soilCollection
--------------
Include the module `soil-collection` like so:

```javascript
angular.module('your-module', ['soil-collection'])
```

The SoilCollection class can then be injected where required:

```javascript
angular.module('your-module').factory('yourFactory', ['soilCollection', function (soilCollection)
  // ...
])
```