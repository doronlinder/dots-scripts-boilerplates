PROJECT_NAME=$1
PROJECTS_FOLDER=~/sandbox
DEPENDENCIES="react react-dom"
BABEL_DEPDENDENCIES="babel-loader babel-preset-es2015 babel-preset-react"
WEBPACK_DEPENDENCIES="webpack webpack-dev-server"
ESLINT_DEPENDENCIES="eslint eslint-plugin-react"
DEV_DEPENDENCIES="${WEBPACK_DEPENDENCIES} ${BABEL_DEPDENDENCIES} ${ESLINT_DEPENDENCIES}"

[ -z "${PROJECT_NAME}" ] && {
    >&2 echo Missing project-name
    >&2 echo -e "Usage: $(basename $0) <project-name>"
    exit 1
}

[ -d "${PROJECTS_FOLDER}" ] || {
    PROJECTS_FOLDER=~/projects
    [ -d "${PROJECTS_FOLDER}" ] || {
        >&2 echo Could not find neither ~/sandbox nor ~/projects to start the project in.
        exit 1
    }
}

mkdir -p ${PROJECTS_FOLDER}/${PROJECT_NAME}/{src,dist}
cd ${PROJECTS_FOLDER}/${PROJECT_NAME}

cat > package.json << PACKAGE_JSON
{
    "name": "${PROJECT_NAME}",
    "version": "0.0.1",
    "private": true,
    "scripts": {
        "start": "cp src/index.html dist/. && { webpack-dev-server & } && google-chrome --incognito http://localhost:8080/webpack-dev-server/"
    }
}
PACKAGE_JSON

cat > webpack.config.js << WEBPACK_CONFIG_JS
var path = require('path');

module.exports = {
    entry: './src/app.js',
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'dist/')
    },
    devtool: 'source-map',
    devServer:{
        contentBase: 'dist'
    },
    module: {
        loaders: [
            {
                test: /.jsx?$/,
                loader: 'babel-loader',
                exclude: /node_modules/,
                query: {
                    presets: ['es2015', 'react']
                }
            }
        ]
    }
}
WEBPACK_CONFIG_JS

cat > .eslintrc.json << ESLINTRC_JSON
{
    "env": {
        "browser": true,
        "es6": true
    },
    "extends": [
        "eslint:recommended",
        "plugin:react/recommended"
    ],
    "parserOptions": {
        "ecmaFeatures": {
            "experimentalObjectRestSpread": true,
            "jsx": true
        },
        "sourceType": "module"
    },
    "plugins": [
        "react"
    ],
    "rules": {
        "indent": [
            "error",
            4
        ],
        "linebreak-style": [
            "error",
            "unix"
        ],
        "quotes": [
            "error",
            "single"
        ],
        "semi": [
            "error",
            "always"
        ]
    }
}
ESLINTRC_JSON


npm install --save ${DEPENDENCIES}
npm install --save-dev ${DEV_DEPENDENCIES}

cat > src/index.html << INDEX_HTML
<!DOCTYPE html>
<html>
    <head lang="en">
        <meta charset="utf-8">
        <title>CHANGE ME</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
    </head>
    <body>
        <div id="app"></div>
        <script src="bundle.js"></script>
    </body>
</html>
INDEX_HTML

cat > src/app.js << APP_JS
import React from 'react';
import ReactDOM from 'react-dom';

class Hello extends React.Component {
    render() {
        return <h1>Hello ${PROJECT_NAME}!</h1>
    }
}

ReactDOM.render(<Hello/>, document.getElementById('app'));
APP_JS
