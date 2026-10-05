/** Actual local Flutter/API journeys. Test records are clearly labelled synthetic. */
'use strict';
const { chromium } = require(process.env.AUCTOR_PLAYWRIGHT || 'C:/Users/dell/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const assert = require('node:assert/strict');
const api = process.env.AUCTOR_API_URL || 'http://localhost:8011';
const web = process.env.AUCTOR_WEB_URL || 'http://localhost:8041';
for (const value of [api, web]) {
  const url = new URL(value);
  assert(['http:', 'https:'].includes(url.protocol) && ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname) && !url.username && !url.password && !url.search && !url.hash && url.pathname === '/', 'Local targets only');
}
const backend = path.resolve(__dirname, '../../Auctor-B-end-FastAPI');
const fixture = path.join(backend, '_data/manual-fixtures');
const out = path.resolve(__dirname, '../build/full-audit-2026-10-05');
fs.mkdirSync(out, { recursive: true });

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 1050 } });
  const page = await context.newPage();
  const errors = [], checks = [];
  page.on('pageerror', error => errors.push(error.message));
  const nonce = Date.now().toString();
  const owner = { email: `audit-owner-${nonce}@example.test`, password: `local-audit-${nonce}-pass`, handle: `audit-owner-${nonce}`, display_name: 'Synthetic Audit Developer' };
  const mark = title => { checks.push(title); console.log('PASS:', title); };
  const screenshot = name => page.screenshot({ path: path.join(out, `${name}.png`) });
  async function request(method, route, headers, data) {
    const response = await page.request[method](api + '/api' + route, { headers, ...(data ? { data } : {}) });
    assert(response.ok(), `${method} ${route} returned ${response.status()}`);
    return response.json();
  }
  async function activate() {
    await page.waitForSelector('flutter-view');
    await page.waitForTimeout(2200);
    const placeholder = page.locator('flt-semantics-placeholder');
    if (await placeholder.count()) await placeholder.dispatchEvent('click');
  }
  async function reveal(locator, target = page) {
    await locator.waitFor({ timeout: 15000 });
    for (let i = 0; i < 30; i++) {
      const box = await locator.boundingBox();
      const size = target.viewportSize();
      if (box && box.y > 35 && box.y + box.height < size.height - 90 && box.x >= 0 && box.x + box.width <= size.width) return;
      await target.mouse.move(size.width - 80, size.height / 2);
      await target.mouse.wheel(0, box && box.y < 35 ? -450 : 450);
      await target.waitForTimeout(100);
    }
  }
  async function click(locator, target = page) { await reveal(locator, target); await locator.click(); await target.waitForTimeout(250); }
  const button = name => page.getByRole('button', { name, exact: true });
  async function input(name, value) {
    const field = page.getByRole('textbox', { name, exact: true });
    await click(field); await page.keyboard.press('Control+A'); await page.keyboard.type(value); await page.waitForTimeout(150);
  }
  async function nav(name) { await page.getByText(name, { exact: true }).first().click(); await page.waitForTimeout(350); }
  try {
    const session = await request('post', '/auth/register', undefined, owner);
    const headers = { Authorization: 'Bearer ' + session.token };
    await page.goto(web); await activate();
    await input('Email', owner.email); await input('Password', owner.password);
    await click(button('Sign in'));
    await page.getByText('A clearer picture of your craft', { exact: true }).waitFor();
    mark('Real owned sign-in and initially empty score/evidence');

    await nav('Evidence');
    const chooseCV = page.waitForEvent('filechooser');
    await click(button('Upload CV'));
    await (await chooseCV).setFiles(path.join(fixture, 'synthetic-cv.pdf'));
    let state;
    for (let i = 0; i < 50; i++) {
      state = await request('get', '/me', headers);
      if (state.documents[0]?.status === 'succeeded') break;
      assert(state.documents[0]?.status !== 'failed', 'Text PDF parsing failed');
      await page.waitForTimeout(300);
    }
    assert.equal(state.documents[0].status, 'succeeded');
    assert(state.versions.length && state.documents[0].source.verified === false);
    await click(page.getByRole('button', { name: 'Refresh workspace', exact: true }));
    await screenshot('evidence-text-pdf');
    mark('Native browser picker uploads labelled text PDF; real durable parser completes and marks claims unverified');

    await click(button('Add evidence'));
    await input('Title', 'Synthetic independent-review experience');
    await input('Source URL (HTTPS)', 'https://example.test/synthetic-audit');
    await click(button('Add evidence'));
    await page.getByText('Add supporting evidence', { exact: true }).waitFor({ state: 'hidden' });
    await page.getByText('Synthetic independent-review experience', { exact: true }).waitFor();
    const chooseProof = page.waitForEvent('filechooser');
    await click(button('Attach PDF proof'));
    await (await chooseProof).setFiles(path.join(fixture, 'synthetic-proof.pdf'));
    await button('Download proof').waitFor();
    state = await request('get', '/me', headers);
    const evidence = state.evidence.find(e => e.title === 'Synthetic independent-review experience');
    assert.equal(evidence.status, 'pending'); assert(evidence.has_file); assert.equal(state.score.total, 0);
    mark('Experience submission and private PDF attachment remain pending without fabricated points');

    const chooseProfile = page.waitForEvent('filechooser');
    await click(button('Import coding profile JSON'));
    await (await chooseProfile).setFiles(path.join(fixture, 'coding-profile.json'));
    await page.getByText('Claimed solved count: 150', { exact: false }).waitFor();
    state = await request('get', '/me', headers);
    assert.equal(state.evidence.find(e => e.kind === 'coding').status, 'pending');
    mark('Actual coding JSON picker imports 150 claimed problems, digest and unverified provenance');

    await nav('Activity'); await click(button('Mark all read'));
    state = await request('get', '/me', headers);
    assert(state.activity.every(event => event.read));
    await screenshot('activity-persisted');
    mark('Activity mark-read writes real account state');

    await nav('Profile');
    await input('Your story', 'Synthetic account used to validate the complete local workflow.');
    await click(page.getByRole('switch', { name: /Discoverable public profile/ }));
    await click(button('Save profile'));
    await button('QR code').waitFor();
    await click(button('QR code')); await page.getByText('Share your profile', { exact: true }).waitFor();
    await screenshot('profile-qr-sheet'); await click(button('Done'));
    const publicState = await request('get', '/public/' + owner.handle);
    assert(!JSON.stringify(publicState).includes(owner.email));
    mark('Discovery opt-in, public redaction and actual readable QR sheet');

    for (const [label, filename, signature] of [['Download PDF report', 'auctor-evidence.pdf', '%PDF-'], ['Export structured data', 'auctor-evidence.json', '{']]) {
      const pendingDownload = page.waitForEvent('download');
      await click(button(label));
      const downloaded = await pendingDownload; await downloaded.saveAs(path.join(out, filename));
      assert(fs.readFileSync(path.join(out, filename), 'utf8').startsWith(signature));
    }
    assert(!fs.readFileSync(path.join(out, 'auctor-evidence.json'), 'utf8').includes(owner.email));
    mark('Actual browser PDF/JSON export controls download parseable redacted reports');

    const candidate = { email: `audit-peer-${nonce}@example.test`, password: owner.password, handle: `audit-peer-${nonce}`, display_name: 'Synthetic Audit Peer' };
    const peerSession = await request('post', '/auth/register', undefined, candidate);
    const peerHeaders = { Authorization: 'Bearer ' + peerSession.token };
    await request('patch', '/me', peerHeaders, { display_name: candidate.display_name, discoverable: true });
    await nav('Discover');
    await input('Name, handle or skill', 'audit-');
    await page.keyboard.press('Enter'); await page.waitForTimeout(800);
    await button('Save').first().waitFor(); await click(button('Save').first());
    const saved = await request('get', '/candidates?q=audit-', headers);
    assert(saved.some(person => person.saved));
    const compare = page.getByRole('checkbox', { name: 'Compare', exact: true });
    const compareButtons = page.getByRole('button', { name: 'Compare', exact: true });
    const selection = await compare.count() ? compare : compareButtons;
    await click(selection.nth(0)); await click(selection.nth(1));
    await click(button('Compare (2/3)')); await page.getByText('Evidence side by side', { exact: true }).waitFor();
    await screenshot('candidate-comparison'); await click(button('Done'));
    mark('Real opt-in search, candidate save/read-back and two-profile comparison');

    await nav('Profile');
    await click(page.getByRole('switch', { name: /Reduce motion/ }));
    await click(page.getByRole('switch', { name: /Reduce transparency/ }));
    await click(page.getByRole('switch', { name: /Increase contrast/ }));
    state = await request('get', '/me', headers);
    assert.deepEqual([state.profile.preferences.reduced_motion, state.profile.preferences.reduced_transparency, state.profile.preferences.high_contrast], [true, true, true]);
    await screenshot('accessibility-opaque-contrast');
    await page.reload(); await activate();
    state = await request('get', '/me', headers); assert.equal(state.profile.preferences.high_contrast, true);
    mark('Motion/transparency/high-contrast preferences persist after actual reload');

    // Live consent needs the operator. The local missing-provider state must stay honest.
    await nav('Overview'); await click(button('Connect GitHub'));
    await page.getByText(/GitHub OAuth is not configured/).waitFor();
    state = await request('get', '/me', headers); assert.equal(Object.keys(state.profile.github_identity).length, 0);
    mark('Missing OAuth reports a real unconfigured error and never verifies a username');

    // Assign only the generated synthetic reviewer; no existing account role is changed.
    const reviewCredentials = { email: `audit-reviewer-${nonce}@example.test`, password: owner.password, handle: `audit-reviewer-${nonce}`, display_name: 'Synthetic Independent Reviewer' };
    const reviewerSession = await request('post', '/auth/register', undefined, reviewCredentials);
    const reviewHeaders = { Authorization: 'Bearer ' + reviewerSession.token };
    const granted = spawnSync(path.join(backend, '.venv/Scripts/python.exe'), ['-m', 'app.manage', 'grant-reviewer', reviewCredentials.email], { cwd: backend, env: { ...process.env, APP_ENV: 'development', OPENAI_API_KEY: '', PYTHONDONTWRITEBYTECODE: '1' }, encoding: 'utf8' });
    assert.equal(granted.status, 0, 'Generated local synthetic reviewer role assignment failed');
    const reviewContext = await browser.newContext({ viewport: { width: 1440, height: 1050 } });
    const reviewPage = await reviewContext.newPage();
    reviewPage.on('pageerror', error => errors.push('Reviewer: ' + error.message));
    await reviewPage.goto(web); await reviewPage.waitForSelector('flutter-view'); await reviewPage.waitForTimeout(2400);
    await reviewPage.locator('flt-semantics-placeholder').dispatchEvent('click');
    for (const [name, value] of [['Email', reviewCredentials.email], ['Password', reviewCredentials.password]]) {
      await reviewPage.getByRole('textbox', { name, exact: true }).click(); await reviewPage.keyboard.type(value); await reviewPage.waitForTimeout(200);
    }
    await reviewPage.getByRole('button', { name: 'Sign in', exact: true }).click();
    await reviewPage.getByText('Reviews', { exact: true }).first().waitFor(); await reviewPage.getByText('Reviews', { exact: true }).first().click();
    // Existing unrelated pending submissions are deliberately not touched.
    const queue = await request('get', '/reviews', reviewHeaders);
    assert(queue.some(item => item.id === evidence.id));
    const ownIndex = queue.findIndex(item => item.id === evidence.id);
    await click(reviewPage.getByRole('button', { name: 'Verify evidence', exact: true }).nth(ownIndex), reviewPage);
    const rationale = reviewPage.getByRole('textbox', { name: 'Review rationale (at least 10 characters)', exact: true });
    await rationale.click(); await reviewPage.keyboard.type('Synthetic software workflow test only; independently inspected the attached labelled fixture.');
    await click(reviewPage.getByRole('button', { name: 'Record decision', exact: true }), reviewPage);
    await reviewPage.getByText('Record verification', { exact: true }).waitFor({ state: 'hidden' });
    await reviewPage.waitForTimeout(500);
    await reviewPage.screenshot({ path: path.join(out, 'reviewer-workspace.png') });
    await reviewContext.close();
    state = await request('get', '/me', headers);
    assert.equal(state.score.total, 1.5); assert(state.review_audit.some(item => item.evidence_id === evidence.id));
    mark('Distinct reviewer UI loads real queue, records own synthetic evidence decision, persists +1.5 and audit');

    await request('patch', '/me', headers, { display_name: owner.display_name, discoverable: true, preferences: { theme: 'system', reduced_motion: false, reduced_transparency: false, high_contrast: false } });
    await click(page.getByRole('button', { name: 'Refresh workspace', exact: true }));
    await nav('Overview'); await screenshot('overview-glass-desktop');
    for (const size of [{ width: 768, height: 1024 }, { width: 390, height: 844 }]) {
      await page.setViewportSize(size); await page.waitForTimeout(300); await screenshot(`overview-${size.width}`);
    }
    await page.emulateMedia({ colorScheme: 'dark' }); await page.waitForTimeout(500); await screenshot('overview-glass-mobile-dark');
    assert.equal(errors.length, 0, `Unexpected page errors: ${errors.join('; ')}`);
    mark('Real desktop/tablet/mobile and dark captures; zero browser page errors');
    fs.writeFileSync(path.join(out, 'results.json'), JSON.stringify({ date: new Date().toISOString(), checks, browserPageErrors: errors, recordProvenance: 'Clearly labelled generated local synthetic accounts and fixtures. Reviewer decision uses the actual separate-account UI. Live OAuth/provider calls were not performed.' }, null, 2));
  } catch (error) {
    await screenshot('failure');
    fs.writeFileSync(path.join(out, 'failure-ui.txt'), await page.locator('body').innerText());
    throw error;
  } finally { await context.close(); await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
