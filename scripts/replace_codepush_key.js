var fs = require('fs');
var myEnv = require(getUserHome() + '/.nowapp/env');

var ANDROID_FILE_PATH = '../android/app/src/main/res/values/strings.xml';
var ANDROID_STRING_TO_REPLACE = 'CODEPUSH_ANDROID_DEPLOYMENT_KEY';

var IOS_FILE_PATH = '../ios/nowucsandiego/Info.plist';
var IOS_STRING_TO_REPLACE = 'CODEPUSH_IOS_DEPLOYMENT_KEY';

var REPLACEMENT_STRING = myEnv.CODEPUSH_KEY;


// iOS
fs.readFile(IOS_FILE_PATH, 'utf8', function(err, data) {
    if (err) {
        return console.log(err);
    }
    var result = data.replace(IOS_STRING_TO_REPLACE, REPLACEMENT_STRING);

    fs.writeFile(IOS_FILE_PATH, result, 'utf8', function(err) {
        if (err) return console.log(err);
    });
});



// Android
fs.readFile(ANDROID_FILE_PATH, 'utf8', function(err, data) {
    if (err) {
        return console.log(err);
    }
    var result = data.replace(ANDROID_STRING_TO_REPLACE, REPLACEMENT_STRING);

    fs.writeFile(ANDROID_FILE_PATH, result, 'utf8', function(err) {
        if (err) return console.log(err);
    });
});

function getUserHome() {
    return process.env[(process.platform == 'win32') ? 'USERPROFILE' : 'HOME'];
}