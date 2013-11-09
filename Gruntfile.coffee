module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-banner');
  grunt.loadNpmTasks('grunt-json-replace');

  grunt.initConfig
    version: grunt.file.read('version.txt').trim()

    pkg: grunt.file.readJSON('bower.json')

    "json-replace":
      options:
        replace:
          version: '<%= version %>'
      default:
        files: [
          { src: 'package.json', dest: 'package.json' },
          { src: 'bower.json', dest: 'bower.json' }
        ]

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
        banner: '/* <%= pkg.name %> <%= version %> %> */\n'
      files:
        src: ['dist/angular-soil.js', 'dist/angular-soil.min.js', 'dist/angular-soil-mocks.js']


  grunt.registerTask('default', ['json-replace', 'coffee', 'uglify', 'usebanner']);
