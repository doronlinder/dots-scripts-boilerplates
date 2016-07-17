PROJECT_NAME=$1
DEPENDENCIES="react react-dom"
DEV_DEPENDENCIES="webpack webpack-dev-server babel-loader babel-preset-es2015 babel-preset-react"

[ -z "${PROJECT_NAME}" ] && {
    >&2 echo Missing project-name
    >&2 echo -e "Usage: $(basename $0) <project-name>"
    exit 1
}

cd ~/sandbox
mkdir -p ~/sandbox/${PROJECT_NAME}/{src,dist}

cd ~/sandbox/${PROJECT_NAME}

cat > package.json << PACKAGE_JSON
{
    "name": "${PROJECT_NAME}",
    "version": "0.0.1",
    "private": true,
    "scripts": {
        "build": "cp src/index.html dist/. && webpack --watch",
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

cd ~/sandbox/${PROJECT_NAME}
