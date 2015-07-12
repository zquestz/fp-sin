var gulp = require('gulp');
var uglify = require('gulp-uglify');
var cssmin = require('gulp-minify-css');
var bower = require('gulp-bower-files');
var include = require('gulp-include');
var concat = require('gulp-concat');
var plumber = require('gulp-plumber');
var sass = require('gulp-sass');
var neat = require('node-neat');

var gulpFilter = require('gulp-filter');
var watch = require('gulp-watch');
var rename = require('gulp-rename');
var react = require('gulp-react');

var reactify = require('reactify');
var browserify = require('browserify');
var source = require('vinyl-source-stream');

var replace = require('gulp-replace');
var debowerify = require('debowerify');
var addsrc = require('gulp-add-src');

var watch = require('gulp-watch');
var batch = require('gulp-batch');

var src = {
  bower: 'bower_components',
  sass: [ 'assets/sass/**/*.scss', ],
  js: ['assets/js/**/*.js',],
  react: ['./src/app.jsx'],
  bower: ['bower.json', '.bowerrc']
};

var dist = 'public';

var dist = {
  js: 'public/js',
  css: 'public/css',
  fonts: 'public/fonts',
};

gulp.task('react', function() {
  browserify(src.react)
    .transform(reactify)
    .transform(debowerify)
    .bundle()
    .pipe(source('bundle.js'))
    .pipe(gulp.dest(dist.js));
});

gulp.task('sass', function() {
  return gulp.src(src.sass)
  .pipe(plumber())
  .pipe(sass({
    includePaths: require('node-neat').with(
        'bower_components/bootstrap-sass-official/assets/stylesheets',
        'bower_components/fontawesome/scss')
  }))
  .pipe(gulp.dest(dist.css))
});

gulp.task('js', function() {
  return gulp.src(src.js)
  .pipe(include())
  .pipe(concat('app.js'))
  .pipe(gulp.dest(dist.js))
});

gulp.task('vendor-js', function() {
  var jsFilter = gulpFilter('**/*.js')
  return bower()
  .pipe(jsFilter)
  .pipe(concat('vendor.js'))
  .pipe(gulp.dest(dist.js))
});

gulp.task('vendor-css', function() {
  var cssFilter = gulpFilter('**/*.css')
  return bower()
  .pipe(cssFilter)
  .pipe(concat('vendor.css'))
  .pipe(gulp.dest(dist.css))
});

gulp.task('bower', function() {
  var fontFilter = gulpFilter('**/*.{eot,woff,woff2,ttf,svg}')
  return bower()
  .pipe(fontFilter)
  .pipe(rename(function(path) {

    if (~path.dirname.indexOf('fonts')) {
      if (~path.dirname.indexOf('bootstrap')) {
        path.dirname = '/bootstrap'
      } else {
        path.dirname = '/'
      }
    }

  }))
  .pipe(gulp.dest(dist.fonts))
});

gulp.task('compress-css', ['sass', 'vendor-css'], function() {
  var filter = gulpFilter(['*', '!*.min.css']);
  return gulp.src(dist.css + '/*.css')
  .pipe(filter)
  .pipe(rename({suffix: '.min'}))
  .pipe(cssmin())
  .pipe(gulp.dest(dist.css))
});

gulp.task('compress-js', ['js', 'vendor-js'], function() {
  var filter = gulpFilter(['*', '!*.min.js']);
  return gulp.src(dist.js + '/*.js')
  .pipe(filter)
  .pipe(rename({suffix: '.min'}))
  .pipe(uglify())
  .pipe(gulp.dest(dist.js))
});

gulp.task('watch-css', function () {
  watch(src.sass, batch(function (events, done) {
    gulp.start('sass', done);
  }));
});

gulp.task('watch-js', function () {
  watch(src.js, batch(function (events, done) {
    gulp.start('js', done);
  }));
});

gulp.task('compress', ['compress-css', 'compress-js']);
gulp.task('default', ['react', 'bower', 'sass', 'js', 'vendor-css', 'vendor-js']);
gulp.task('build', ['default', 'compress']);
gulp.task('watch', ['watch-js', 'watch-css']);
