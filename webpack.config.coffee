module.exports =
   entry: './src/views/main'
   output:
      filename: 'bundle.js'
   # externals:
   #    "mithril": "mithril"

   module:
      loaders: [
         (test: /\.coffee$/, loader: 'coffee-loader')
      ]

   resolve:
      extensions: ['','.coffee', '.js']
      modulesDirectories: ['node_modules']
