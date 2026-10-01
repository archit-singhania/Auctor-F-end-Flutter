/** Local end-to-end test. Isolated Chrome and clearly labelled disposable QA data. */
const {chromium}=require(process.env.AUCTOR_PLAYWRIGHT||'C:/Users/dell/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs=require('fs');
(async()=>{
 const browser=await chromium.launch({channel:'chrome',headless:true});
 try {
 const page=await browser.newPage({viewport:{width:1440,height:1050}});
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 const api=process.env.AUCTOR_API_URL||'http://localhost:8011',web=process.env.AUCTOR_WEB_URL||'http://localhost:8041';
 const nonce=Date.now().toString(),email='qa-'+nonce+'@example.test',password='local-qa-'+nonce+'-pass',handle='qa-'+nonce;
 const registered=await page.request.post(api+'/api/auth/register',{data:{email,password,handle,display_name:'QA Developer (test account)'}});
 if(registered.status()!==201)throw new Error('QA setup registration failed '+registered.status());
 const session=await registered.json();const headers={Authorization:'Bearer '+session.token};
 const saved=await page.request.put(api+'/api/cv',{headers,data:{data:{skills:['Docker','REST API','PostgreSQL'],projects:[{name:'QA Orders API',description:'Disposable local software-test record',tech_stack:['Docker']}],experience:[],profiles:{}}}});
 if(!saved.ok())throw new Error('QA CV setup failed');
 await page.goto(web);await page.waitForSelector('flutter-view');await page.waitForTimeout(3500);
 fs.mkdirSync('build/browser-qa',{recursive:true});
 await page.screenshot({path:'build/browser-qa/landing-desktop.png'});
 await page.locator('flt-semantics-placeholder').dispatchEvent('click');
 await page.getByRole('textbox',{name:'Email',exact:true}).click(); await page.keyboard.type(email);
 await page.getByLabel('Password',{exact:true}).click(); await page.keyboard.type(password);
 await page.getByRole('button',{name:'Sign in',exact:true}).click();
 try { await page.getByText('A clearer picture of your craft',{exact:true}).waitFor({timeout:20000}); } catch(e) { await page.screenshot({path:'build/browser-qa/signin-failure.png'}); console.log('SIGNIN_FAILURE_BODY',await page.locator('body').innerText()); console.log('SIGNIN_FAILURE_ERRORS',errors); throw e; }
 await page.screenshot({path:'build/browser-qa/overview-desktop.png'});
 await page.getByText('Evidence',{exact:true}).click();
 await page.getByText('A library of your evidence',{exact:true}).waitFor();
 await page.getByText('Review & edit',{exact:true}).click();
 await page.getByText('Review your story',{exact:true}).waitFor();
 await page.screenshot({path:'build/browser-qa/cv-review.png'});
 await page.getByRole('button',{name:'Cancel',exact:true}).click();
 await page.getByText('Challenges',{exact:true}).click();
 await page.getByText('Put your skills into practice',{exact:true}).waitFor();
 await page.screenshot({path:'build/browser-qa/challenges.png'});
 await page.getByRole('button',{name:'Start challenge',exact:true}).nth(1).click();
 await page.getByRole('button',{name:'Close',exact:true}).waitFor(); console.log('ATTEMPT_BODY', (await page.locator('body').innerText()).slice(-6000));
 await page.screenshot({path:'build/browser-qa/challenge-attempt.png'});
 console.log('QUESTIONS_VISIBLE',await page.getByRole('button',{name:'Separate build tooling from runtime',exact:true}).count());
 await page.getByRole('button',{name:'Close',exact:true}).click();
 await page.getByText('Profile',{exact:true}).click();
 await page.getByText('A profile that feels like you',{exact:true}).waitFor();
 await page.screenshot({path:'build/browser-qa/profile-desktop.png'});
 await page.reload();await page.waitForSelector('flutter-view');await page.waitForTimeout(2500);
 await page.locator('flt-semantics-placeholder').dispatchEvent('click');
 await page.getByText('A clearer picture of your craft',{exact:true}).waitFor();
 await page.setViewportSize({width:390,height:844});await page.waitForTimeout(500);
 await page.screenshot({path:'build/browser-qa/overview-mobile.png'});
 if(errors.length)throw new Error('Browser errors: '+JSON.stringify(errors));
 console.log('PASS: real sign-in, owned CV readback/edit dialog, challenge catalog/timed attempt, profile, persisted session reload, mobile layout. No browser page errors.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});



