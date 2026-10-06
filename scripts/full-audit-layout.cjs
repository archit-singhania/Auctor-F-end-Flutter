/** Targeted real-browser layout verification after the mobile dock label fix. */
'use strict';
const { chromium } = require(process.env.AUCTOR_PLAYWRIGHT || 'C:/Users/dell/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const web = process.env.AUCTOR_WEB_URL || 'http://localhost:8041';
const url = new URL(web);
assert(['http:', 'https:'].includes(url.protocol) && ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname) && !url.username && !url.password && !url.search && !url.hash && url.pathname === '/', 'Local targets only');
const nonce = process.env.AUCTOR_LAYOUT_NONCE;
assert(/^\d{13}$/.test(nonce || ''), 'Use a generated full-audit account nonce');
const out = path.resolve(__dirname, '../build/full-audit-2026-10-05/final-layout');
fs.mkdirSync(out, { recursive: true });

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 1050 }, colorScheme: 'light' });
  const blocked = [], errors = [], checks = [], localAssets = [];
  await context.route('**/*', route => {
    const requested = new URL(route.request().url());
    if (['http:', 'https:'].includes(requested.protocol) && !['localhost', '127.0.0.1', '[::1]'].includes(requested.hostname)) {
      blocked.push(requested.origin); return route.abort();
    }
    return route.continue();
  });
  const page = await context.newPage();
  page.on('pageerror', error => errors.push(error.message));
  page.on('response', response => {
    const resource = new URL(response.url());
    if (resource.pathname.endsWith('/Inter.ttf') || resource.pathname.endsWith('/canvaskit.wasm')) localAssets.push({ path: resource.pathname, status: response.status() });
  });
  async function tap(locator) {
    await locator.waitFor();
    const box = await locator.boundingBox(); assert(box && await locator.isEnabled());
    await page.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
    await page.waitForTimeout(300);
  }
  async function navigation(name) {
    const locator = page.getByRole('button', { name, exact: true });
    const size = page.viewportSize();
    for (let i = 0; i < 14; i++) {
      const box = await locator.count() ? await locator.boundingBox({ timeout: 1500 }) : null;
      if (box && box.x >= 0 && box.x + box.width <= size.width) { await tap(locator); return; }
      await page.mouse.move(size.width / 2, size.height - 55);
      await page.keyboard.down('Shift');
      await page.mouse.wheel(0, box && box.x < 0 ? -130 : 130);
      await page.keyboard.up('Shift');
      await page.waitForTimeout(120);
    }
    throw new Error('Mobile navigation could not reveal ' + name);
  }
  async function top() {
    const size = page.viewportSize();
    await page.mouse.move(size.width * .65, size.height / 2);
    await page.mouse.wheel(0, -10000); await page.waitForTimeout(250);
  }
  try {
    await page.goto(web); await page.waitForSelector('flutter-view'); await page.waitForTimeout(2200);
    await page.locator('flt-semantics-placeholder').dispatchEvent('click');
    for (const [name, value] of [['Email', `audit-owner-${nonce}@example.test`], ['Password', `local-audit-${nonce}-pass`]]) {
      await tap(page.getByRole('textbox', { name, exact: true }));
      await page.keyboard.type(value); await page.waitForTimeout(150);
    }
    await tap(page.getByRole('button', { name: 'Sign in', exact: true }));
    await page.getByText('A clearer picture of your craft', { exact: true }).waitFor();
    await page.setViewportSize({ width: 390, height: 844 });
    for (const mode of ['light', 'dark']) {
      await page.emulateMedia({ colorScheme: mode });
      for (const destination of ['Overview', 'Evidence', 'Challenges', 'Activity', 'Discover', 'Profile']) {
        await navigation(destination); await top();
        await page.screenshot({ path: path.join(out, `mobile-${mode}-${destination.toLowerCase()}.png`) });
        checks.push(`390 px ${mode}: ${destination} reached through the real scrollable dock`);
      }
    }
    await page.setViewportSize({ width: 1440, height: 1050 });
    await navigation('Overview'); await top();
    await page.emulateMedia({ colorScheme: 'light' }); await page.waitForTimeout(350);
    await page.screenshot({ path: path.join(out, 'overview-glass-desktop.png') });
    await page.emulateMedia({ colorScheme: 'dark' }); await page.waitForTimeout(350);
    await page.screenshot({ path: path.join(out, 'overview-glass-desktop-dark.png') });
    await page.emulateMedia({ colorScheme: 'light' });
    await page.setViewportSize({ width: 768, height: 1024 }); await page.waitForTimeout(350);
    await page.screenshot({ path: path.join(out, 'overview-768.png') });
    checks.push('Final desktop light/dark and tablet captures');
    assert.deepEqual(errors, []);
    assert(blocked.every(origin => origin === 'https://fonts.gstatic.com'), 'Unexpected external provider request');
    assert(localAssets.some(asset => asset.path.endsWith('/Inter.ttf') && asset.status === 200));
    assert(localAssets.some(asset => asset.path.endsWith('/canvaskit.wasm') && asset.status === 200));
    fs.writeFileSync(path.join(out, 'results.json'), JSON.stringify({ date: new Date().toISOString(), checks, browserPageErrors: errors, blockedExternalOrigins: blocked, bundledAssets: localAssets, provenance: 'Same labelled generated full-audit account, final dock-only web rebuild. Actual UI sign-in and all six mobile destinations in both themes; every external HTTP origin blocked. Flutter may attempt its built-in Google font fallback; this blocked attempt is recorded separately from the successfully served local Inter/CanvasKit and readable capture verification.' }, null, 2));
    console.log('PASS: 13 targeted final-layout groups, all six mobile destinations in both themes, desktop/tablet, zero page errors. Bundled Inter/CanvasKit served locally; external fallback attempts blocked and recorded.');
  } catch (error) {
    await page.screenshot({ path: path.join(out, 'failure.png') });
    fs.writeFileSync(path.join(out, 'failure-ui.txt'), await page.locator('body').innerText());
    fs.writeFileSync(path.join(out, 'failure-semantics.json'), JSON.stringify(await page.locator('flt-semantics').evaluateAll(nodes => nodes.map(node => ({ role: node.getAttribute('role'), label: node.getAttribute('aria-label'), text: node.textContent }))), null, 2));
    throw error;
  } finally { await context.close(); await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
