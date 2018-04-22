# Electron Boilerplate

A simple desktop app built with
  * [Electron](https://electronjs.org/)
  * [CoffeeScript](http://coffeescript.org/)
  * [Pug](https://pugjs.org/)
  * [gulp](https://gulpjs.com/)

## Getting started

Using `npm` scripts

```
npm install
npm start
npm run build
npm run package
```

Or, install `gulp` and `electron` globally

```
npm install -g gulp-cli electron
npm install
```

Then run the commands directly
```
gulp build
gulp watch
electron out
```

Package the app into a file for [distribution](https://electronjs.org/docs/tutorial/application-distribution)

```
gulp package
electron app.asar
```
