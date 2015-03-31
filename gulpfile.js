var gulp = require('gulp')
var minifyCSS = require('gulp-minify-css')
var minifyHTML = require('gulp-minify-html')
var coffee = require('gulp-coffee')
var uglify = require('gulp-uglify')
var clean = require('gulp-clean')

gulp.task('css',function(){
  return gulp.src('src/*.css')
                        .pipe(minifyCSS())
                        .pipe(gulp.dest('dist/'))
})

gulp.task('html',function(){
  return gulp.src('src/*.html')
                        .pipe(minifyHTML({ quotes: true }))
                        .pipe(gulp.dest('dist/'))
})

gulp.task('coffee',function(){
  return gulp.src('src/*.coffee')
                        .pipe(coffee({ bare: true }))
                        .pipe(uglify({ mangle: false }))
                        .pipe(gulp.dest('dist/'))
})

gulp.task('clean',function(){
  return gulp.src('dist/*').pipe(clean())
})

gulp.task('watch',function(){
  gulp.watch('src/*.coffee',['coffee'])
  gulp.watch('src/*.css',['css'])
  gulp.watch('src/*.html',['html'])
})
gulp.task('default',['html','css','coffee'])
