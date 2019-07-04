const { environment } = require('@rails/webpacker');

environment.config.merge({
	module: {
		rules: [
			{
				test: require.resolve('@material/chips'),
				use: [{
					loader: 'expose-loader',
					options: 'MDC'
				}]
			},
			{
				test: require.resolve('postal/lib/postal.js'),
				use: [{
					loader: 'expose-loader',
					options: 'postal'
				}]
			},
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
