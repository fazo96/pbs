var gulp = require('gulp')
var minifyCSS = require('gulp-minify-css')
var minifyHTML = require('gulp-minify-html')
var coffee = require('gulp-coffee')
var uglify = require('gulp-uglify')
var clean = require('gulp-clean')

gulp.task('css',function(){
  cssFiles = ["src/*.css","bower_components/vis/dist/vis.min.css",
      "bower_components/sweetalert/lib/sweet-alert.css",
      "bower_components/bootstrap/dist/css/bootstrap.css"]
  return gulp.src(cssFiles)
                        .pipe(gulp.dest('test/'))
                        .pipe(minifyCSS())
                        .pipe(gulp.dest('dist/'))
})

gulp.task('html',function(){
  return gulp.src('src/*.html')
                        .pipe(gulp.dest('test/'))
                        .pipe(minifyHTML({ quotes: true }))
                        .pipe(gulp.dest('dist/'))
})
gulp.task('js',function(){
  jsFiles = ["src/*.js",
      "bower_components/jquery/dist/jquery.js",
      "bower_components/moment/moment.js",
      "bower_components/angular/angular.js",
      "bower_components/sweetalert/lib/sweet-alert.js",
      "bower_components/angular-ui-router/release/angular-ui-router.js",
      "bower_components/vis/dist/vis.min.js"]
  return gulp.src(jsFiles).pipe(gulp.dest('test/'))
                          .pipe(uglify({ mangle: false }))
                          .pipe(gulp.dest('dist/'))
              
})
gulp.task('coffee',function(){
  return gulp.src('src/*.coffee')
                        .pipe(coffee({ bare: true }))
                        .pipe(gulp.dest('test/'))
                        .pipe(uglify({ mangle: false }))
                        .pipe(gulp.dest('dist/'))
})

gulp.task('clean',function(){
  return gulp.src(['dist/*','test/*']).pipe(clean())
})

gulp.task('watch',function(){
  gulp.watch('src/*.coffee',['coffee'])
  gulp.watch('src/*.css',['css'])
  gulp.watch('src/*.html',['html'])
})
gulp.task('default',['html','css','js','coffee'])
