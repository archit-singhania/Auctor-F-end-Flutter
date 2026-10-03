/** Local end-to-end test. Isolated Chrome and clearly labelled disposable QA data. */
const {chromium}=require(process.env.AUCTOR_PLAYWRIGHT||'C:/Users/dell/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs=require('fs');
(async()=>{
 const api=process.env.AUCTOR_API_URL||'http://localhost:8011',web=process.env.AUCTOR_WEB_URL||'http://localhost:8041';
 for(const value of [api,web]){
   const origin=new URL(value);
   if(!['http:','https:'].includes(origin.protocol)||!['localhost','127.0.0.1','[::1]'].includes(origin.hostname)||origin.username||origin.password||origin.search||origin.hash||origin.pathname!=='/')throw new Error('Browser QA only accepts a local origin; disposable records must never target production.');
 }
 const browser=await chromium.launch({channel:'chrome',headless:true});
 const record=process.env.AUCTOR_RECORD_VIDEO==='1';
 const context=await browser.newContext({viewport:{width:1440,height:1050},...(record?{recordVideo:{dir:'build/browser-qa/video',size:{width:1440,height:1050}}}:{})});
 let video,passed=false,page;
 try {
 page=await context.newPage();video=page.video();
 const pause=()=>page.waitForTimeout(record?1800:0);
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 const nonce=Date.now().toString(),email='qa-'+nonce+'@example.test',password='local-qa-'+nonce+'-pass',handle='qa-'+nonce;
 const registered=await page.request.post(api+'/api/auth/register',{data:{email,password,handle,display_name:'QA Developer (test account)'}});
 if(registered.status()!==201)throw new Error('QA setup registration failed '+registered.status());
 const session=await registered.json();const headers={Authorization:'Bearer '+session.token};
 const saved=await page.request.put(api+'/api/cv',{headers,data:{data:{skills:['Docker','REST API','PostgreSQL'],projects:[{name:'QA Orders API',description:'Disposable local software-test record',tech_stack:['Docker']}],experience:[],profiles:{}}}});
 if(!saved.ok())throw new Error('QA CV setup failed');
 await page.goto(web);await page.waitForSelector('flutter-view');await page.waitForTimeout(3500);
 fs.mkdirSync('build/browser-qa',{recursive:true});
 await page.screenshot({path:'build/browser-qa/landing-desktop.png'});
 await pause();
 await page.locator('flt-semantics-placeholder').dispatchEvent('click');
 await page.getByRole('textbox',{name:'Email',exact:true}).click(); await page.waitForTimeout(250); await page.keyboard.type(email,{delay:25}); await page.waitForTimeout(250);
 await page.getByLabel('Password',{exact:true}).click(); await page.waitForTimeout(250); await page.keyboard.type(password,{delay:25}); await page.waitForTimeout(250);
 await page.getByRole('button',{name:'Sign in',exact:true}).click();
 try { await page.getByText('A clearer picture of your craft',{exact:true}).waitFor({timeout:20000}); } catch(e) { await page.screenshot({path:'build/browser-qa/signin-failure.png'}); console.log('SIGNIN_FAILURE_BODY',await page.locator('body').innerText()); console.log('SIGNIN_FAILURE_ERRORS',errors); throw e; }
 await page.screenshot({path:'build/browser-qa/overview-desktop.png'});
 await pause();
 await page.getByText('Evidence',{exact:true}).click();
 await page.getByText('A library of your evidence',{exact:true}).waitFor();
 await page.getByText('Review & edit',{exact:true}).click();
 await page.getByText('Review your story',{exact:true}).waitFor();
 await page.getByRole('textbox',{name:'Skills, separated by commas',exact:true}).click();await page.waitForTimeout(250);
 await page.keyboard.press('Control+A');await page.keyboard.type('Docker, REST API, PostgreSQL, Redis',{delay:25});await page.waitForTimeout(250);
 await page.screenshot({path:'build/browser-qa/cv-review.png'});
 await pause();
 await page.getByRole('button',{name:'Save reviewed CV',exact:true}).click();
 await page.getByText('Review your story',{exact:true}).waitFor({state:'hidden'});
 const owned=await (await page.request.get(api+'/api/me',{headers})).json();
 if(!owned.cv.skills.includes('Redis')||owned.versions.length<2)throw new Error('Reviewed CV was not persisted');
 await pause();
 await page.getByText('Challenges',{exact:true}).click();
 await page.getByText('Put your skills into practice',{exact:true}).waitFor();
 await page.screenshot({path:'build/browser-qa/challenges.png'});
 await pause();
 if(!record)await page.setViewportSize({width:1440,height:1900});
 await page.getByRole('button',{name:'Start challenge',exact:true}).nth(1).click();
 await page.getByRole('button',{name:'Close',exact:true}).waitFor();
 await page.screenshot({path:'build/browser-qa/challenge-attempt.png'});
 await pause();
 const correctLabels=new Set(['Separate build tooling from runtime','Content-addressed image','Runtime secret injection','Application readiness/liveness condition','Non-root with minimum permissions']);
 const answers=(await page.getByRole('button').allTextContents()).filter(label=>correctLabels.has(label.trim()));
 if(answers.length!==5)throw new Error('Expected five question choices in the actual accessible UI');
 for(const answer of answers){
   const choice=page.getByRole('button',{name:answer.trim(),exact:true});
   if(record){
     let visible=false;
     for(let scroll=0;scroll<12;scroll++){
       const box=await choice.boundingBox();
       if(box&&box.y>100&&box.y+box.height<930){visible=true;break;}
       await page.mouse.move(730,500);await page.mouse.wheel(0,box&&box.y<100?-350:350);await page.waitForTimeout(180);
     }
     if(!visible)throw new Error('Could not scroll the actual challenge choice into view');
   }
   await choice.click();if(record)await page.waitForTimeout(650);
 }
 await page.getByRole('button',{name:'Submit answers',exact:true}).click();
 await page.getByText('5/5 correct. Actual score change: +0.6.',{exact:true}).waitFor();
 await page.screenshot({path:'build/browser-qa/challenge-result.png'});
 await pause();
 await page.getByRole('button',{name:'Done',exact:true}).click();
 await page.getByRole('button',{name:'Badge details',exact:true}).nth(1).click();
 await page.getByText('A pass covers this five-question assessment. Repeated passes add no score; failed retries preserve an earned badge.',{exact:true}).waitFor();
 await page.screenshot({path:'build/browser-qa/badge-detail.png'});
 await pause();
 await page.getByRole('button',{name:'Close',exact:true}).click();
 const badgeReadback=await (await page.request.get(api+'/api/challenges/docker',{headers})).json();
 if(!badgeReadback.earned||badgeReadback.attempts[0].correct_count!==5)throw new Error('Owned badge detail did not preserve the actual graded result');
 const scored=await (await page.request.get(api+'/api/me',{headers})).json();
 if(scored.insights.skill_graph.nodes.find(n=>n.name==='Docker')?.status!=='assessed'||!scored.insights.roadmap.some(s=>s.skill==='Redis'&&s.track_id==='redis'&&s.priority===1))throw new Error('Evidence graph or personalized roadmap did not reflect server assessment state');
 await page.getByText('Overview',{exact:true}).click();
 await page.getByText('Skills and their evidence',{exact:true}).waitFor();
 let graphVisible=false;
 for(let scroll=0;scroll<16;scroll++){
   const box=await page.getByText('Skills and their evidence',{exact:true}).boundingBox();
   if(box&&box.y>80&&box.y<280){graphVisible=true;break;}
   await page.mouse.move(980,500);await page.mouse.wheel(0,box&&box.y<80?-300:300);await page.waitForTimeout(250);
 }
 if(!graphVisible)throw new Error('Could not scroll the actual skills graph into view');
 await page.screenshot({path:'build/browser-qa/skills-graph.png'});
 await pause();
 await page.setViewportSize({width:1440,height:1050});
 await page.getByText('Profile',{exact:true}).click();
 await page.mouse.move(980,400);await page.mouse.wheel(0,-4000);await page.waitForTimeout(300);
 await page.getByText('A profile that feels like you',{exact:true}).waitFor();
 await page.screenshot({path:'build/browser-qa/profile-desktop.png'});
 await pause();
 await page.getByRole('button',{name:'Create link',exact:true}).click();
 await page.getByRole('button',{name:'Revoke',exact:true}).waitFor();
 await pause();
 const shared=await (await page.request.get(api+'/api/me',{headers})).json();
 const share=shared.shares.find(s=>!s.revoked);if(!share)throw new Error('Share not persisted');
 const publicView=await (await page.request.get(api+'/api/share/'+share.id)).json();
 if(JSON.stringify(publicView).includes(email))throw new Error('Contact email leaked in public share');
 await page.getByRole('button',{name:'Revoke',exact:true}).click();
 await page.getByRole('button',{name:'Revoke',exact:true}).waitFor({state:'hidden'});
 await pause();
 if((await page.request.get(api+'/api/share/'+share.id)).status()!==404)throw new Error('Revoked share still readable');
 await page.reload();await page.waitForSelector('flutter-view');await page.waitForTimeout(2500);
 await page.locator('flt-semantics-placeholder').dispatchEvent('click');
 await page.getByText('A clearer picture of your craft',{exact:true}).waitFor();
 await page.setViewportSize({width:390,height:844});await page.waitForTimeout(500);
 await page.screenshot({path:'build/browser-qa/overview-mobile.png'});
 await pause();
 await page.emulateMedia({colorScheme:'dark'});await page.waitForTimeout(500);await page.screenshot({path:'build/browser-qa/overview-mobile-dark.png'});
 await pause();
 if(errors.length)throw new Error('Browser errors: '+JSON.stringify(errors));
 console.log('PASS: real sign-in, owned CV review/save/readback, server-graded 5/5 Docker assessment (+0.6), owned badge detail, evidence graph/roadmap readback, profile, private share/create/revoke/redaction, persisted session reload, mobile light/dark layout. No browser page errors.');
 passed=true;
 }catch(error){if(page){await page.screenshot({path:'build/browser-qa/failure.png'});console.log('FAILURE_UI',await page.locator('body').innerText());}throw error;}finally{await context.close();if(record&&video&&passed){fs.mkdirSync('docs/demo',{recursive:true});await video.saveAs('docs/demo/auctor-connected-workflow.webm');console.log('VIDEO: docs/demo/auctor-connected-workflow.webm (clearly labelled local QA account and CV fixtures)');}await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});



