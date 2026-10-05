{{flutter_js}}
{{flutter_build_config}}

// Ship the engine with the app. Opening a local build never needs Google's CDN.
const auctorConfig = {canvasKitBaseUrl: new URL('canvaskit/', document.baseURI).href};
_flutter.loader.load({
  config: auctorConfig,
  onEntrypointLoaded: async engineInitializer => {
    const runner = await engineInitializer.initializeEngine(auctorConfig);
    await runner.runApp();
    document.getElementById('loader')?.remove();
  },
}).catch(() => {
  const status = document.querySelector('#loader p');
  if (status) status.textContent = 'The workspace could not start. Reload after checking the local server.';
});
