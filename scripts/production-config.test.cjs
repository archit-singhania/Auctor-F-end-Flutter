const { test } = require('node:test');
const assert = require('node:assert/strict');
const { publicOrigin, verifyProduction } = require('./production-config.cjs');

test('production URL validation rejects local bundles and credentials', () => {
  for (const value of ['', 'http://localhost:8011', 'https://127.0.0.1', 'https://10.0.0.1',
    'https://[::1]', 'https://api.example.invalid', 'https://user:private@api.example.org',
    'https://api.example.org/?key=private', 'https://api.example.org/api']) {
    assert.throws(() => publicOrigin(value, 'AUCTOR_API_URL'));
  }
  assert.equal(publicOrigin('https://api.example.org/', 'AUCTOR_API_URL'), 'https://api.example.org');
});

test('an unavailable or old public API cannot pass the production gate', async () => {
  const env = { AUCTOR_API_URL: 'https://api.example.org', AUCTOR_WEB_URL: 'https://web.example.org' };
  await assert.rejects(verifyProduction(env, async () => ({ ok: false, status: 404 })), /404/);
  await assert.rejects(verifyProduction(env, async () => ({ ok: true, json: async () => ({ status: 'ok' }) })), /v2/);
  await assert.rejects(verifyProduction(env, async () => ({ ok: true, json: async () => ({ status: 'ready', database: 'connected', schema_version: 2, service: 'auctor-api', environment: 'development', storage: 'local-private' }) })), /private volume/);
  const result = await verifyProduction(env, async (url, options) => {
    assert.equal(url, 'https://api.example.org/health');
    assert.equal(options.redirect, 'error');
    return { ok: true, json: async () => ({ status: 'ready', database: 'connected', schema_version: 2, service: 'auctor-api', environment: 'production', storage: 'private-volume' }) };
  });
  assert.equal(result.web, 'https://web.example.org');
});
