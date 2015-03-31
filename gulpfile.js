// Gulp Dependencies
var gulp = require('gulp');
var gutil = require('gulp-util')
var uglify = require('gulp-uglify');
var minifyCSS = require('gulp-minify-css');
var coffee = require('gulp-coffee')

gulp.task('css',function(){
  return gulp.src('src/*.css')
    .pipe(minifyCSS())
    .pipe(gulp.dest('.'))
})
gulp.task('coffee',function(){
  return gulp.src('src/*.coffee')
    .pipe(coffee({ bare: true }))
    .pipe(uglify())
    .pipe(gulp.dest('.'))
})

gulp.task('default',['css','coffee'])

gulp.task('watch',function(){
  gulp.watch('src/*.css',['css'])
  gulp.watch('src/*.coffee',['coffee'])
})
