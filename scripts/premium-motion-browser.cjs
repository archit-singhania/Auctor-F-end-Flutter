/** Real local browser checks; only generated labelled synthetic accounts are changed. */
'use strict';
const {chromium}=require(process.env.AUCTOR_PLAYWRIGHT || 'C:/Users/dell/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),{spawnSync}=require('node:child_process');
const api=process.env.AUCTOR_API_URL || 'http://localhost:8011',web=process.env.AUCTOR_WEB_URL || 'http://localhost:8041';
for(const origin of [api,web]){const u=new URL(origin);assert(['localhost','127.0.0.1','[::1]'].includes(u.hostname)&&!u.username&&!u.password&&u.pathname==='/','Local origins only');}
const out=path.resolve('docs/screenshots/motion-2026-10-06');fs.mkdirSync(out,{recursive:true});
(async()=>{
 const browser=await chromium.launch({channel:'chrome',headless:true});
 const context=await browser.newContext({viewport:{width:1440,height:1050}}),page=await context.newPage();
 const checks=[],errors=[],blocked=[],nonce=Date.now().toString(),password='synthetic-motion-'+nonce;
 await context.route('**/*',route=>{const u=new URL(route.request().url());if(['http:','https:'].includes(u.protocol)&&!['localhost','127.0.0.1','[::1]'].includes(u.hostname)){blocked.push(u.origin);return route.abort();}return route.continue();});
 page.on('pageerror',e=>errors.push(e.message));
 const mark=s=>{checks.push(s);console.log('PASS:',s);};
 async function request(method,route,headers,data){const r=await page.request[method](api+'/api'+route,{headers,...(data?{data}:{})});assert(r.ok(),method+' '+route+' '+r.status());return r.json();}
 async function reveal(locator,target=page){await locator.waitFor();for(let i=0;i<120;i++){const b=await locator.boundingBox(),v=target.viewportSize();if(b&&b.y>35&&b.y+b.height<v.height-(v.width>=1000?16:110)&&b.x>=0&&b.x+b.width<=v.width)return b;await target.mouse.move(b?Math.max(80,Math.min(v.width-80,b.x+b.width/2)):v.width-80,v.height/2);await target.mouse.wheel(0,b&&b.y<35?-600:600);await target.waitForTimeout(100);}console.log('REVEAL_FAILURE_RECT',await locator.boundingBox(),'viewport',target.viewportSize());await target.screenshot({path:path.join(out,'failure-target.png')});throw Error('Cannot reveal '+await locator.innerText());}
 async function click(locator,target=page){const b=await reveal(locator,target);assert(await locator.isEnabled());await target.mouse.click(b.x+b.width/2,b.y+b.height/2);await target.waitForTimeout(300);}
 async function input(name,value,target=page){const field=target.getByRole('textbox',{name,exact:true}),b=await reveal(field,target);await field.click();await field.focus();await target.waitForTimeout(200);await target.keyboard.press('Control+A');await target.keyboard.type(value,{delay:15});await target.waitForTimeout(100);}
 async function activate(target=page){await target.waitForSelector('flutter-view');await target.waitForTimeout(2200);const p=target.locator('flt-semantics-placeholder');if(await p.count())await p.dispatchEvent('click');}
 const button=name=>page.getByRole('button',{name,exact:true});
 async function nav(name){const loc=page.getByRole('button',{name:new RegExp('^'+name+'(?: '+name+')?$')});await loc.waitFor();await page.waitForTimeout(100);const v=page.viewportSize();if(v.width<1000){for(let i=0;i<16;i++){const b=await loc.boundingBox();if(b&&b.x>=0&&b.x+b.width<=v.width)break;await page.mouse.move(v.width/2,v.height-55);await page.keyboard.down('Shift');await page.mouse.wheel(0,b&&b.x<0?-140:140);await page.keyboard.up('Shift');await page.waitForTimeout(120);}const b=await loc.boundingBox();assert(b&&b.x>=0&&b.x+b.width<=v.width&&b.y>=0&&b.y+b.height<=v.height);await page.mouse.click(b.x+b.width/2,b.y+b.height/2);await page.waitForTimeout(300);}else await click(loc);}
 async function signIn(target,email){await target.goto(web);await activate(target);await input('Email',email,target);await input('Password',password,target);await click(target.getByRole('button',{name:'Sign in',exact:true}),target);await target.getByText('A clearer picture of your craft',{exact:true}).waitFor();}
 try{
  const owner={email:'motion-owner-'+nonce+'@example.test',password,handle:'motion-'+nonce,display_name:'Synthetic Motion Developer'};
  const session=await request('post','/auth/register',undefined,owner),headers={Authorization:'Bearer '+session.token};
  await signIn(page,owner.email);await nav('Profile');
  await input('Display name','Unsaved motion draft');
  const name=page.getByRole('textbox',{name:'Display name',exact:true}),before=await name.boundingBox();
  await nav('Evidence');await nav('Profile');
  await name.focus();await page.waitForTimeout(100);assert.equal(await name.inputValue(),'Unsaved motion draft');
  const after=await name.boundingBox();assert(Math.abs(before.y-after.y)<2,'Per-pane scroll should survive destination revisits');
  mark('Desktop destination revisits retain unsaved profile text and scroll position');
  for(const [label,value,current] of [['Linen & Ink','archive','Ivory & Jade'],['Rose & Slate','dusk','Linen & Ink'],['Ivory & Jade','atelier','Rose & Slate']]){
   await click(page.getByRole('button',{name:new RegExp(current)}));for(let i=0;i<(value==='atelier'?2:1);i++)await page.keyboard.press(value==='atelier'?'ArrowUp':'ArrowDown');await page.keyboard.press('Enter');await page.waitForTimeout(400);
   const state=await request('get','/me',headers);assert.equal(state.profile.preferences.palette,value);
   await name.focus();await page.waitForTimeout(100);assert.equal(await name.inputValue(),'Unsaved motion draft','Appearance change must preserve unsaved fields');
   await page.screenshot({path:path.join(out,'palette-'+value+'.png')});
  }
  mark('All three curated palettes persist server-side while preserving profile draft');
  await click(page.getByRole('switch',{name:/Reduce motion/}));
  await click(page.getByRole('switch',{name:/Reduce transparency/}));
  await click(page.getByRole('switch',{name:/Increase contrast/}));
  let state=await request('get','/me',headers);assert.deepEqual([state.profile.preferences.reduced_motion,state.profile.preferences.reduced_transparency,state.profile.preferences.high_contrast],[true,true,true]);
  await page.emulateMedia({reducedMotion:'reduce'});await page.reload();await activate();await page.getByText('A clearer picture of your craft',{exact:true}).waitFor();
  await page.setViewportSize({width:390,height:844});await page.waitForTimeout(450);await nav('Evidence');await page.screenshot({path:path.join(out,'mobile-reduced-evidence.png')});
  await nav('Overview');await page.emulateMedia({colorScheme:'dark',reducedMotion:'reduce'});await page.waitForTimeout(250);await page.screenshot({path:path.join(out,'mobile-reduced-dark.png')});
  mark('390px light/dark navigation works with restored reduced motion, opaque surfaces and high contrast');
  const evidence=await request('post','/evidence',headers,{kind:'experience',title:'Synthetic Motion Review '+nonce,url:'https://example.test/synthetic-source',detail:{}});
  const reviewer={email:'motion-reviewer-'+nonce+'@example.test',password,handle:'reviewer-'+nonce,display_name:'Synthetic Motion Reviewer'};
  const reviewSession=await request('post','/auth/register',undefined,reviewer),reviewHeaders={Authorization:'Bearer '+reviewSession.token};
  const backend=path.resolve('../Auctor-B-end-FastAPI');
  const grant=spawnSync(path.join(backend,'.venv/Scripts/python.exe'),['-m','app.manage','grant-reviewer',reviewer.email],{cwd:backend,env:{...process.env,APP_ENV:'development',OPENAI_API_KEY:'',PYTHONDONTWRITEBYTECODE:'1'},encoding:'utf8'});assert.equal(grant.status,0,'Generated synthetic reviewer role assignment');
  const reviewContext=await browser.newContext({viewport:{width:1440,height:1050}}),reviewPage=await reviewContext.newPage();reviewPage.on('pageerror',e=>errors.push(e.message));
  await signIn(reviewPage,reviewer.email);await click(reviewPage.getByRole('button',{name:/^Reviews(?: Reviews)?$/}),reviewPage);
  const queue=await request('get','/reviews',reviewHeaders),index=queue.findIndex(e=>e.id===evidence.id);assert(index>=0);console.log('SYNTHETIC_REVIEW_QUEUE_INDEX',index,'of',queue.length);
  await click(reviewPage.getByRole('button',{name:'Verify evidence',exact:true}).nth(index),reviewPage);
  await input('Review rationale (at least 10 characters)','Synthetic workflow only; inspected labelled source to verify independent decision transition.',reviewPage);
  await click(reviewPage.getByRole('button',{name:'Record decision',exact:true}),reviewPage);
  await reviewPage.getByText('Record verification',{exact:true}).waitFor({state:'hidden'});await reviewPage.waitForTimeout(350);
  state=await request('get','/me',headers);assert.equal(state.evidence.find(e=>e.id===evidence.id).status,'verified');assert.equal(state.score.total,1.5);assert(state.review_audit.some(e=>e.evidence_id===evidence.id));
  await reveal(reviewPage.getByText(new RegExp('Synthetic Motion Review '+nonce+'.*verified')),reviewPage);await reviewPage.screenshot({path:path.join(out,'reviewer-confirmed.png')});await reviewContext.close();
  mark('Reviewer sheet records real independent decision; verified state, +1.5 score and durable audit read back');
  await page.setViewportSize({width:1440,height:1050});await page.waitForTimeout(450);await nav('Evidence');await click(button('Refresh workspace'));await page.getByText('Review: Synthetic workflow only; inspected labelled source to verify independent decision transition.',{exact:true}).waitFor();
  await page.screenshot({path:path.join(out,'owner-confirmed-state.png')});
  await page.goto(web+'/landing/index.html');await page.waitForTimeout(300);assert.equal(await page.locator('.hero .path').evaluate(e=>getComputedStyle(e).animationName),'none');assert(await page.locator('.btn[href="/"]').count()>=3);assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false);
  await page.setViewportSize({width:390,height:844});await page.waitForTimeout(450);assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth),false);await page.screenshot({path:path.join(out,'landing-mobile-reduced.png')});
  mark('Public landing respects system reduced motion and keeps mobile workspace links usable');
  assert.equal(errors.length,0,JSON.stringify(errors));assert.equal(blocked.length,0,JSON.stringify(blocked));
  fs.writeFileSync('docs/premium-motion-browser-2026-10-06.json',JSON.stringify({checked_at_utc:new Date().toISOString(),synthetic_account_nonce:nonce,checks,page_errors:errors,external_requests:blocked},null,2));
 }catch(e){await page.screenshot({path:path.join(out,'failure.png')});console.error('BODY',await page.locator('body').innerText());throw e;}finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
