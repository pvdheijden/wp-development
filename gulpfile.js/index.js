const path = require('path');
const debug = require('debug')('wp-development');

const fs = require('fs');

const gulp = require('gulp');
const child = require('child_process');
const composer = require('gulp-composer');
const sass = require('gulp-sass');
const zip = require('gulp-zip');

function execLogging (error, stdout, stderr) {
    if (error) {
        console.error(`exec error: ${error}`);
        return;
    }
    debug(`stdout: ${stdout}`);
    debug(`stderr: ${stderr}`);
}

function wpComposer(cb) {
    composer('update', {
        'working-dir': path.join(__dirname, '..', 'html'),
        bin: 'composer'
    });

    cb();
}

function _pluginComposer(plugin) {
    return function pluginComposer(cb) {
        console.log('*****************' + plugin + '*********************');
        composer( 'update', {
            'working-dir': path.join(__dirname, '..', 'html/content/plugins/', plugin ),
            bin: 'composer'
        });

        cb();
    };
}

function _cssSass(module) {
    return function cssSass(cb) {
        let modulePath = path.join(__dirname, '..', 'html/content/themes/', module);
        if (!fs.existsSync(modulePath)) {
            modulePath = path.join(__dirname, '..', 'html/content/plugins/', module);
        }

        gulp.src(path.join(modulePath, '/sass/**/*.scss'))
            .pipe(sass())
            .pipe(gulp.dest(modulePath));

        cb();
    };
}

function _jsMinify(module) {
    return function jsMinify(cb) {
        cb();
    };
}

function _zipContent(module) {
    return function zipContent(cb) {
        let modulePath = path.join(__dirname, '..', 'html/content/themes/', module);
        if (!fs.existsSync(modulePath)) {
            modulePath = path.join(__dirname, '..', 'html/content/plugins/', module);
        }

        let version = require(path.join(modulePath, 'composer.json')).version;
        if (!version) {
            version = 'development';
        }

        gulp.src(path.join(modulePath, '**'))
            .pipe(zip(module + '-' + version + '.zip'))
            .pipe(gulp.dest(path.join(__dirname, '..', 'dist')));

        cb();
    }
}

/**
 *
 *
 */

exports.wpDevelopment = wpComposer;

const plntn_nl_v2 = gulp.series(
    _cssSass('plntn-nl-v2'),
    _jsMinify('plntn-nl-v2'),
    _zipContent('plntn-nl-v2')
);
exports.plntn_nl_v2 = plntn_nl_v2;

const px2 = gulp.series(
    _cssSass('px2'),
    _jsMinify('px2'),
    _zipContent('px2')
);
exports.px2 = px2;

exports.default = gulp.series(
    wpComposer,
    gulp.parallel(px2, plntn_nl_v2));
