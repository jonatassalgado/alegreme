const { environment } = require('@rails/webpacker');

function hotfixPostcssLoaderConfig (subloader) {
	const subloaderName = subloader.loader
	if (subloaderName === 'postcss-loader') {
		if (subloader.options.postcssOptions) {
			console.log(
				'\x1b[31m%s\x1b[0m',
				'Remove postcssOptions workaround in config/webpack/environment.js'
			)
		} else {
			subloader.options.postcssOptions = subloader.options.config;
			delete subloader.options.config;
		}
	}
}

environment.loaders.keys().forEach(loaderName => {
	const loader = environment.loaders.get(loaderName);
	loader.use.forEach(hotfixPostcssLoaderConfig);
});

environment.config.merge({
	module: {
		rules: [
			// {
			// 	test: require.resolve('morphdom/dist/morphdom-esm.js'),
			// 	use: [{
			// 		loader: 'expose-loader',
			// 		options: 'morphdom'
			// 	}]
			// }
		]
	}
});

module.exports = environment
