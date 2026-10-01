'use strict';

function publicOrigin(value, label) {
  if (!value) throw new Error(`Set ${label} to the confirmed production HTTPS origin.`);
  let url;
  try { url = new URL(value); } catch { throw new Error(`${label} must be an HTTPS origin.`); }
  if (url.protocol !== 'https:' || url.username || url.password || url.search || url.hash || url.pathname !== '/') {
    throw new Error(`${label} must be an HTTPS origin without credentials, paths, queries or fragments.`);
  }
  const host = url.hostname.toLowerCase();
  const ip = host.split('.').map(Number);
  const privateIp = /^\d+\.\d+\.\d+\.\d+$/.test(host) && (
    ip[0] === 0 || ip[0] === 10 || ip[0] === 127 || ip[0] >= 224 ||
    (ip[0] === 169 && ip[1] === 254) || (ip[0] === 172 && ip[1] >= 16 && ip[1] <= 31) ||
    (ip[0] === 192 && ip[1] === 168)
  );
  if (privateIp || host.includes(':') || host === 'localhost' || host.endsWith('.localhost') ||
      host.endsWith('.local') || host.endsWith('.invalid') || host === 'example.com') {
    throw new Error(`${label} must point to a confirmed public deployment.`);
  }
  return url.origin;
}

function readyV2(body) {
  if (body?.status !== 'ready' || body?.database !== 'connected' || body?.schema_version !== 2 || body?.service !== 'auctor-api' ||
      body?.environment !== 'production' || body?.storage !== 'private-volume') {
    throw new Error('The production API is not the ready Auctor v2 service with a configured private volume. Deploy and validate the API first.');
  }
}

async function verifyProduction(env = process.env, request = fetch) {
  const api = publicOrigin(env.AUCTOR_API_URL, 'AUCTOR_API_URL');
  const web = publicOrigin(env.AUCTOR_WEB_URL, 'AUCTOR_WEB_URL');
  const response = await request(`${api}/health`, { redirect: 'error', signal: AbortSignal.timeout(15000) });
  if (!response.ok) throw new Error(`The production API readiness endpoint returned ${response.status}. Deploy the API first.`);
  readyV2(await response.json());
  return { api, web };
}

if (require.main === module) {
  verifyProduction().then(() => console.log('Confirmed public HTTPS targets and ready Auctor API v2.'))
    .catch(error => { console.error(error.message); process.exitCode = 1; });
}
module.exports = { publicOrigin, readyV2, verifyProduction };
