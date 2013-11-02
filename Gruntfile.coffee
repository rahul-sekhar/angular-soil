module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('bower.json')
    coffee:
      compile:
        files: {
          'dist/angular-soil.js': 'src/*.coffee',
          'dist/angular-soil-mocks.js': 'src/mocks/*.coffee'
        }
    uglify:
      build:
        src: 'dist/angular-soil.js',
        dest: 'dist/angular-soil.min.js'
    usebanner:
      options:
        banner: '/* <%= pkg.name %> v<%= pkg.version %> %> */\n'
      files:
        src: ['dist/angular-soil.js', 'dist/angular-soil.min.js', 'dist/angular-soil-mocks.js']


  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-banner');

  grunt.registerTask('default', ['coffee', 'uglify', 'usebanner']);
