/*global module:false*/
module.exports = function(grunt) {

	grunt.loadNpmTasks('grunt-contrib-coffee');
	// Project configuration.
	grunt.initConfig({
	    coffee: {
	      source: {
	        options: {
	          bare: true
	        },
	        cwd: '.',
	        src: 'src/ng-iscroll.coffee',
	        dest: 'dist/ng-iscroll.js',
	      }
	    },
	
	});

	// Register tasks.
	grunt.registerTask('default', ['coffee']);
};