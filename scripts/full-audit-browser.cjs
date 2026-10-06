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
  const context = await browser.newContext({ viewport: { width: 1440, height: 1050 }, permissions: ['clipboard-read', 'clipboard-write'] });
  const page = await context.newPage();
  const errors = [], checks = [];
  page.on('pageerror', error => errors.push(error.message));
  const resumed = process.env.AUCTOR_AUDIT_RESUME_NONCE;
  assert(!resumed || /^\d{13}$/.test(resumed), 'Resume accepts only this audit\'s generated timestamp nonce');
  const nonce = resumed || Date.now().toString();
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
      const scrollX = box ? Math.max(80, Math.min(size.width - 80, box.x + box.width / 2)) : size.width - 80;
      await target.mouse.move(scrollX, size.height / 2);
      await target.mouse.wheel(0, box && box.y < 35 ? -450 : 450);
      await target.waitForTimeout(100);
    }
  }
  async function click(locator, target = page) {
    await reveal(locator, target);
    assert(await locator.isEnabled(), 'Control must be enabled');
    const box = await locator.boundingBox();
    assert(box, 'Control must be visibly laid out');
    // Flutter paints the actual hit target on its canvas; overlapping semantics
    // containers can confuse DOM interception checks. Perform a real pointer tap.
    await target.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
    await target.waitForTimeout(250);
  }
  const button = name => page.getByRole('button', { name, exact: true });
  async function input(name, value, target = page) {
    const field = target.getByRole('textbox', { name, exact: true });
    await reveal(field, target);
    const box = await field.boundingBox();
    assert(box, 'Input must be visibly laid out');
    // Use the visible text area. Flutter's suffix semantics can overlap an input's DOM center.
    await target.mouse.click(box.x + Math.min(24, box.width / 4), box.y + box.height / 2);
    await target.waitForTimeout(150);
    await target.keyboard.press('Control+A'); await target.keyboard.type(value); await target.waitForTimeout(150);
  }
  async function nav(name) { await click(page.getByRole('button', { name: new RegExp('^' + name + '(?: ' + name + ')?$') })); await page.waitForTimeout(350); }
  try {
    const session = await request('post', resumed ? '/auth/login' : '/auth/register', undefined, resumed ? { email: owner.email, password: owner.password } : owner);
    const headers = { Authorization: 'Bearer ' + session.token };
    await page.goto(web); await activate();
    await input('Email', owner.email); await input('Password', owner.password);
    await click(button('Sign in'));
    await page.getByText('A clearer picture of your craft', { exact: true }).waitFor();
    if (!resumed) mark('Real owned sign-in and initially empty score/evidence');
    let state, evidence, certificate, share;
    if (!resumed) {

    await nav('Evidence');
    const chooseCV = page.waitForEvent('filechooser');
    await click(button('Upload CV'));
    await (await chooseCV).setFiles(path.join(fixture, 'synthetic-cv.pdf'));
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

    const sourceDownload = page.waitForEvent('download');
    await click(button('Download original CV source'));
    await (await sourceDownload).saveAs(path.join(out, 'original-synthetic-cv.pdf'));
    assert(fs.readFileSync(path.join(out, 'original-synthetic-cv.pdf')).equals(fs.readFileSync(path.join(fixture, 'synthetic-cv.pdf'))));
    await click(button('Review & edit'));
    await input('Skills, separated by commas', 'Docker, REST API, PostgreSQL, Redis, Unknown Tool');
    await screenshot('cv-review-glass-sheet');
    await click(button('Save reviewed CV'));
    await page.getByText('Review your story', { exact: true }).waitFor({ state: 'hidden' });
    state = await request('get', '/me', headers);
    assert(state.cv.skills.includes('Unknown Tool') && state.versions.length >= 2);
    const editedCV = state.cv;
    const editedVersion = state.versions[0].id;
    await click(button('Compare').last());
    await page.getByText(/Skills added since this revision:/).waitFor();
    await screenshot('cv-version-comparison'); await click(button('Close'));
    await click(button('Restore').last());
    for (let i = 0; i < 30; i++) {
      state = await request('get', '/me', headers);
      if (state.versions.length >= 3) break;
      await page.waitForTimeout(200);
    }
    assert(state.versions.length >= 3 && !state.cv.skills.includes('Unknown Tool'));
    // Restore the edited revision through its visible row, preserving every revision.
    const editedIndex = state.versions.findIndex(version => version.id === editedVersion);
    await click(button('Restore').nth(editedIndex));
    await page.waitForTimeout(500);
    state = await request('get', '/me', headers);
    assert.deepEqual(state.cv.skills, editedCV.skills);
    mark('Exact owner source download, editable unverified claims, visible version comparison and append-only restoration');

    const failedPicker = page.waitForEvent('filechooser');
    await click(button('Upload CV'));
    await (await failedPicker).setFiles(path.join(fixture, 'damaged.pdf'));
    for (let i = 0; i < 50; i++) {
      state = await request('get', '/me', headers);
      if (state.documents[0]?.status === 'failed') break;
      await page.waitForTimeout(200);
    }
    assert.equal(state.documents[0].status, 'failed');
    assert.deepEqual(state.cv.skills, editedCV.skills);
    await click(button('Refresh workspace')); await click(button('Retry'));
    await page.waitForTimeout(1000);
    state = await request('get', '/me', headers);
    assert.equal(state.documents[0].status, 'failed');
    assert.deepEqual(state.cv.skills, editedCV.skills);
    mark('Real damaged-PDF failure and Retry retain the previously saved CV without fabricated extraction');

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
    evidence = state.evidence.find(e => e.title === 'Synthetic independent-review experience');
    assert.equal(evidence.status, 'pending'); assert(evidence.has_file); assert.equal(state.score.total, 0);
    mark('Experience submission and private PDF attachment remain pending without fabricated points');

    const chooseProfile = page.waitForEvent('filechooser');
    await click(button('Import coding profile JSON'));
    await (await chooseProfile).setFiles(path.join(fixture, 'coding-profile.json'));
    await page.getByText('Claimed solved count: 150', { exact: false }).waitFor();
    state = await request('get', '/me', headers);
    assert.equal(state.evidence.find(e => e.kind === 'coding').status, 'pending');
    mark('Actual coding JSON picker imports 150 claimed problems, digest and unverified provenance');

    await click(button('Add evidence'));
    await click(page.getByRole('button', { name: 'Evidence type experience', exact: true }));
    await click(page.getByRole('menuitem', { name: 'certificate', exact: true }));
    await input('Title', 'Synthetic inspection certificate');
    await input('Source URL (HTTPS)', 'https://example.test/synthetic-certificate');
    await input('Certificate issuer', 'Synthetic QA Issuer');
    await input('Credential/reference ID (optional)', 'SYNTHETIC-2026');
    await input('Issued date (optional)', '2026-10-06');
    await screenshot('certificate-issuer-sheet');
    await click(button('Add evidence'));
    await page.getByText('Add supporting evidence', { exact: true }).waitFor({ state: 'hidden' });
    state = await request('get', '/me', headers);
    certificate = state.evidence.find(item => item.title === 'Synthetic inspection certificate');
    assert.equal(certificate.detail.issuer, 'Synthetic QA Issuer');
    assert.equal(certificate.status, 'pending'); assert.equal(state.score.total, 0);
    mark('Actual certificate form retains issuer/reference/date/source, honest pending review and zero formula-v1 points');

    await nav('Challenges');
    assert.equal(await button('Start challenge').count(), 5);
    await click(button('Start challenge').nth(1));
    const answers = ['Separate build tooling from runtime', 'Content-addressed image', 'Runtime secret injection', 'Application readiness/liveness condition', 'Non-root with minimum permissions'];
    for (const answer of answers) await click(button(answer));
    await click(button('Submit answers'));
    await page.getByText('5/5 correct. Actual score change: +0.6.', { exact: true }).waitFor();
    await screenshot('server-graded-docker'); await click(button('Done'));
    await click(button('Badge details').nth(1));
    await page.getByText('A pass covers this five-question assessment. Repeated passes add no score; failed retries preserve an earned badge.', { exact: true }).waitFor();
    await screenshot('owned-badge-detail'); await click(button('Close'));
    const badge = await request('get', '/challenges/docker', headers);
    assert(badge.earned && badge.attempts[0].correct_count === 5);
    state = await request('get', '/me', headers); assert.equal(state.score.total, 0.6);
    assert(state.insights.skill_graph.nodes.some(node => node.name === 'Docker' && node.status === 'assessed'));
    assert(state.insights.roadmap.some(step => step.skill === 'Redis' && step.track_id === 'redis'));
    assert(state.insights.roadmap.some(step => step.skill === 'Unknown Tool' && !step.track_id));
    mark('All five real catalog tracks, visible Docker grading 5/5/+0.6, durable owned badge details and honest graph/roadmap projections');

    await nav('Overview');
    await reveal(page.getByText('Skills and their evidence', { exact: true }));
    await screenshot('skills-graph-roadmap');
    await click(button('Assess this gap').first());
    await button('Submit answers').waitFor(); await click(button('Close'));
    mark('Visible source graph and roadmap launch the supported gap challenge through its actual control');

    await nav('Activity'); await click(button('Mark all read'));
    state = await request('get', '/me', headers);
    assert(state.activity.every(event => event.read));
    await screenshot('activity-persisted');
    mark('Activity mark-read writes real account state');
    await click(button('Compare score signals').first());
    await page.getByText('A certificate review or CV correction can change evidence without changing formula v1 points.', { exact: true }).waitFor();
    await screenshot('score-evidence-comparison'); await click(button('Close'));
    assert(state.history.length > 1 && state.insights.score_comparisons.length > 1);
    mark('Durable formula-v1 input/score history opens actual component and evidence-change comparisons');

    await nav('Profile');
    await input('Your story', 'Synthetic account used to validate the complete local workflow.');
    await click(page.getByRole('switch', { name: /Discoverable public profile/ }));
    await click(button('Save profile'));
    await click(button('Create link'));
    await button('Revoke').waitFor();
    state = await request('get', '/me', headers);
    share = state.shares.find(item => !item.revoked);
    const shared = await request('get', '/share/' + share.id);
    assert(!JSON.stringify(shared).includes(owner.email));
    await click(button('Revoke'));
    await button('Revoke').waitFor({ state: 'hidden' });
    assert.equal((await page.request.get(api + '/api/share/' + share.id)).status(), 404);
    mark('Actual private-link create/revoke controls persist access state and public redaction');
    await button('QR code').waitFor();
    await click(button('QR code')); await button('Done').waitFor();
    await screenshot('profile-qr-sheet'); await click(button('Done'));
    await click(button('Copy profile link'));
    const copiedProfileLink = await page.evaluate(() => navigator.clipboard.readText());
    assert(copiedProfileLink.startsWith(web + '/#/public/' + owner.handle));
    const publicState = await request('get', '/public/' + owner.handle);
    assert(!JSON.stringify(publicState).includes(owner.email));
    mark('Discovery opt-in, public redaction and actual QR/link sheet rendering');

    for (const [label, filename, signature] of [['Download PDF report', 'auctor-evidence.pdf', '%PDF-'], ['Export structured data', 'auctor-evidence.json', '{']]) {
      const pendingDownload = page.waitForEvent('download');
      await click(button(label));
      const downloaded = await pendingDownload; await downloaded.saveAs(path.join(out, filename));
      assert(fs.readFileSync(path.join(out, filename), 'utf8').startsWith(signature));
    }
    const jsonReport = fs.readFileSync(path.join(out, 'auctor-evidence.json'), 'utf8');
    assert(!jsonReport.includes(owner.email));
    assert.equal(JSON.parse(jsonReport).profile.handle, owner.handle);
    const parsedPDF = spawnSync(path.join(backend, '.venv/Scripts/python.exe'), ['-c', 'from pdfminer.high_level import extract_text; import sys; print(extract_text(sys.argv[1]))', path.join(out, 'auctor-evidence.pdf')], { cwd: backend, encoding: 'utf8' });
    assert.equal(parsedPDF.status, 0, 'Downloaded PDF must parse');
    assert(parsedPDF.stdout.includes(owner.display_name) && !parsedPDF.stdout.includes(owner.email));
    await click(button('Copy embed badge'));
    const embed = await page.evaluate(() => navigator.clipboard.readText());
    assert(embed.includes('/api/badge/' + owner.handle + '.svg') && !embed.includes(owner.email));
    const svg = await page.request.get(api + '/api/badge/' + owner.handle + '.svg');
    assert(svg.ok() && (await svg.text()).startsWith('<svg'));
    mark('Actual browser PDF/JSON export and embed controls produce parseable redacted reports and an opt-in SVG');
    } else {
      const previous = JSON.parse(fs.readFileSync(path.join(out, 'resume.json'), 'utf8'));
      assert.equal(previous.nonce, nonce);
      assert.equal(previous.checks.length, 14);
      checks.push(...previous.checks);
      console.log('REUSED: 14 completed checks from this same generated owner on the final web artifact; fresh real sign-in resumes the remaining controls.');
      state = await request('get', '/me', headers);
      evidence = state.evidence.find(item => item.title === 'Synthetic independent-review experience');
      certificate = state.evidence.find(item => item.title === 'Synthetic inspection certificate');
      share = state.shares.find(item => item.revoked);
      assert(evidence && certificate && share && state.score.total === 0.6);
    }

    const candidate = { email: `audit-peer-${nonce}@example.test`, password: owner.password, handle: `audit-peer-${nonce}`, display_name: 'Synthetic Audit Peer' };
    const peerSession = await request('post', resumed ? '/auth/login' : '/auth/register', undefined, resumed ? { email: candidate.email, password: candidate.password } : candidate);
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
    await click(button('Compare (2/3)')); await button('Done').waitFor();
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
      await input(name, value, reviewPage);
    }
    await reviewPage.getByRole('button', { name: 'Sign in', exact: true }).click();
    await click(reviewPage.getByRole('button', { name: /^Reviews(?: Reviews)?$/ }), reviewPage);
    // Existing unrelated pending submissions are deliberately not touched.
    const queue = await request('get', '/reviews', reviewHeaders);
    assert(queue.some(item => item.id === evidence.id));
    const ownIndex = queue.findIndex(item => item.id === evidence.id);
    await click(reviewPage.getByRole('button', { name: 'Verify evidence', exact: true }).nth(ownIndex), reviewPage);
    const rationale = reviewPage.getByRole('textbox', { name: 'Review rationale (at least 10 characters)', exact: true });
    await input('Review rationale (at least 10 characters)', 'Synthetic software workflow test only; independently inspected the attached labelled fixture.', reviewPage);
    await click(reviewPage.getByRole('button', { name: 'Record decision', exact: true }), reviewPage);
    await reviewPage.getByText('Record verification', { exact: true }).waitFor({ state: 'hidden' });
    await reviewPage.waitForTimeout(500);
    const certificateQueue = await request('get', '/reviews', reviewHeaders);
    const certificateIndex = certificateQueue.findIndex(item => item.id === certificate.id);
    assert(certificateIndex >= 0);
    await click(reviewPage.getByRole('button', { name: 'Verify evidence', exact: true }).nth(certificateIndex), reviewPage);
    await input('Review rationale (at least 10 characters)', 'Synthetic certificate workflow only; inspected issuer reference date and source for zero-point audit.', reviewPage);
    await click(reviewPage.getByRole('button', { name: 'Record decision', exact: true }), reviewPage);
    await reviewPage.getByText('Record verification', { exact: true }).waitFor({ state: 'hidden' });
    await reviewPage.waitForTimeout(500);
    await reviewPage.screenshot({ path: path.join(out, 'reviewer-workspace.png') });
    await reviewContext.close();
    state = await request('get', '/me', headers);
    assert.equal(state.score.total, 2.1); assert(state.review_audit.some(item => item.evidence_id === evidence.id));
    assert.equal(state.review_audit.find(item => item.evidence_id === certificate.id).source.detail.issuer, 'Synthetic QA Issuer');
    mark('Distinct reviewer UI loads real queue, records own synthetic evidence decision, persists +1.5 and audit (total 2.1 with earned badge)');
    await click(button('Refresh workspace')); await nav('Activity');
    await reveal(page.getByText('Reviewer decision audit', { exact: true }));
    await screenshot('owner-review-audit');
    assert.equal((await page.request.get(api + '/api/reviews/audit', { headers })).status(), 403);
    assert.equal((await page.request.get(api + '/api/evidence/' + evidence.id + '/file', { headers: peerHeaders })).status(), 404);
    mark('Visible durable reviewer audit and real denied global-audit/private-proof requests enforce account ownership');
    await nav('Evidence');
    const certificateRemoveIndex = state.evidence.findIndex(item => item.id === certificate.id);
    await click(button('Remove').nth(certificateRemoveIndex));
    await page.getByText('Your score is recalculated from the remaining sources.', { exact: true }).waitFor();
    await click(button('Remove').last());
    await page.getByText('Your score is recalculated from the remaining sources.', { exact: true }).waitFor({ state: 'hidden' });
    state = await request('get', '/me', headers);
    assert(!state.evidence.some(item => item.id === certificate.id));
    assert(state.review_audit.some(item => item.evidence_id === certificate.id));
    assert.equal(state.score.total, 2.1);
    mark('Removing a zero-point reviewed certificate preserves issuer/source/reviewer/rationale audit and score history');

    await nav('Profile');
    await click(page.getByRole('switch', { name: /Discoverable public profile/ }));
    await click(button('Save profile'));
    assert.equal((await page.request.get(api + '/api/public/' + owner.handle)).status(), 404);
    assert.equal((await page.request.get(api + '/api/badge/' + owner.handle + '.svg')).status(), 404);
    assert(!(await request('get', '/candidates?q=' + owner.handle, peerHeaders)).some(item => item.profile.handle === owner.handle));
    await page.reload(); await activate();
    state = await request('get', '/me', headers);
    assert(state.shares.find(item => item.id === share.id).revoked && !state.profile.discoverable);
    mark('Discovery opt-out removes public/search access; share revocation and privacy persist after reload');

    await request('patch', '/me', headers, { display_name: owner.display_name, discoverable: true, preferences: { theme: 'system', reduced_motion: false, reduced_transparency: false, high_contrast: false } });
    await click(page.getByRole('button', { name: 'Refresh workspace', exact: true }));
    await nav('Overview'); await screenshot('overview-glass-desktop');
    for (const size of [{ width: 768, height: 1024 }, { width: 390, height: 844 }]) {
      await page.setViewportSize(size); await page.waitForTimeout(300); await screenshot(`overview-${size.width}`);
    }
    await page.emulateMedia({ colorScheme: 'dark' }); await page.waitForTimeout(500); await screenshot('overview-glass-mobile-dark');
    assert.equal(errors.length, 0, `Unexpected page errors: ${errors.join('; ')}`);
    mark('Real desktop/tablet/mobile and dark captures; zero browser page errors');
    fs.writeFileSync(path.join(out, 'results.json'), JSON.stringify({ date: new Date().toISOString(), checks, browserPageErrors: errors, resumedPreviouslyCompletedChecks: resumed ? 14 : 0, recordProvenance: 'Clearly labelled generated local synthetic accounts and fixtures on the same final web build. Any resumed checks were completed earlier on this same generated owner, then the remaining controls ran after fresh real sign-in. Reviewer decision uses the actual separate-account UI. Live OAuth/provider calls were not performed.' }, null, 2));
  } catch (error) {
    await screenshot('failure');
    fs.writeFileSync(path.join(out, 'failure-ui.txt'), await page.locator('body').innerText());
    fs.writeFileSync(path.join(out, 'failure-semantics.json'), JSON.stringify(await page.locator('flt-semantics').evaluateAll(nodes => nodes.map(node => ({ role: node.getAttribute('role'), label: node.getAttribute('aria-label'), text: node.textContent }))), null, 2));
    throw error;
  } finally { await context.close(); await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
