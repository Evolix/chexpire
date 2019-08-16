const { environment } = require('@rails/webpacker')

environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  Popper: ['popper.js', 'default'],
  Util: "exports-loader?Util!bootstrap/js/dist/util",
}))


module.exports = environment
