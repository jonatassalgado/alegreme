const { environment } = require('@rails/webpacker');

environment.config.merge({
	module: {
		rules: [
			{
				test: require.resolve('morphdom/dist/morphdom-esm.js'),
				use: [{
					loader: 'expose-loader',
					options: 'morphdom'
				}]
			}
		]
	}
});


module.exports = environment;
