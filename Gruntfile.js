/*global module:false*/
module.exports = function(grunt) {

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-git-init-and-deploy');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-karma');

  // Project configuration.
  grunt.initConfig({
    // Task configuration.
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        unused: true,
        boss: true,
        eqnull: true,
        globals: {
          jQuery: true
        }
      },
      gruntfile: {
        src: 'Gruntfile.js'
      },
      lib_test: {
        src: ['lib/**/*.js', 'test/**/*.js']
      }
    },
    nodeunit: {
      files: ['test/**/*_test.js']
    },
    watch: {
      gruntfile: {
        files: '<%= jshint.gruntfile.src %>',
        tasks: ['jshint:gruntfile']
      },
      lib_test: {
        files: '<%= jshint.lib_test.src %>',
        tasks: ['jshint:lib_test', 'nodeunit']
      }
    },
    karma: {
      unit: {
        configFile: 'karma.conf.js',
        singleRun: true
      }
    },
    copy: {
      build: {
        files: [
          { expand: true, cwd: 'app/', src: ['**'], dest: 'build/' },
          { expand: true, src: ['Gemfile', 'Gemfile.lock', 'Procfile'], dest: 'build/' }
        ]
      }
    },
    clean: ['build/'],
    gitInitAndDeploy: {
      deploy: {
        options: {
          repository: 'git@heroku.com:concordia-calendar-ninja.git',
          message: 'deployment for v' + process.env.BUILD_NUMBER
        },
        src: 'build'
      }
    }
  });

  // Default task.
  grunt.registerTask('default', ['jshint']);
  grunt.registerTask('deploy', ['copy:build', 'gitInitAndDeploy:deploy']);
};
