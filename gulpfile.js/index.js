const path = require('path');
const debug = require('debug')('wp-development');

const gulp = require('gulp');
const child = require('child_process');
const sass = require('gulp-sass');

function execLogging (error, stdout, stderr) {
    if (error) {
        console.error(`exec error: ${error}`);
        return;
    }
    debug(`stdout: ${stdout}`);
    debug(`stderr: ${stderr}`);
}

function phpCompose() {
    return child.exec('composer update', {
        cwd: path.join(__dirname, '..', 'html')
    }, execLogging);
}

function cssSass(cb) {
    gulp.src(path.join(__dirname, '..', 'html/content/themes/pvdh-nl/sass/**/*.scss'))
        .pipe(sass())
        .pipe(gulp.dest(path.join(__dirname, '..', 'html/content/themes/pvdh-nl/')));

    cb();
}

function jsMinify(cb) {
    cb();
}


function serverBuildAndUpdate(cb) {
    return child.exec('docker-compose build && docker-compose down && docker-compose up -d', {
        cwd: path.join(__dirname, '..')
    }, execLogging);
}


exports.buildWP = phpCompose;
exports.buildTheme = cssSass;

exports.devDeploy = gulp.series(cssSass, jsMinify, serverBuildAndUpdate);

exports.default = gulp.series(phpCompose, cssSass, jsMinify, serverBuildAndUpdate);
