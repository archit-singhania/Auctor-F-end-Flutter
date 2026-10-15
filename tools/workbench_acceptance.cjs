const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {chromium,request}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const api='http://127.0.0.1:8106/api',wait=ms=>new Promise(r=>setTimeout(r,ms));
const output=path.resolve(__dirname,'../docs/workbench-2026-10-15');fs.mkdirSync(output,{recursive:true});
(async()=>{
 const http=await request.newContext();const stamp=Date.now(),email=`story-${stamp}@example.test`,password='Local-Story-Fixture-2026!',handle=`story-${stamp}`;
 const reg=await http.post(api+'/auth/register',{data:{email,password,handle,display_name:'Illustrative career QA'}});assert.equal(reg.status(),201,await reg.text());const headers={Authorization:'Bearer '+(await reg.json()).token};
 async function get(route){const r=await http.get(api+route,{headers});assert.equal(r.status(),200,await r.text());return r.json();}
 const browser=await chromium.launch({channel:'chrome',headless:true});const context=await browser.newContext({viewport:{width:1440,height:1100}}),page=await context.newPage();const errors=[];page.on('pageerror',e=>errors.push(e.message));
 async function press(name){const b=page.getByRole('button',{name,exact:true}).first();await b.waitFor({state:'visible',timeout:30000});for(let i=0;i<30 && !await b.isEnabled();i++)await wait(500);assert.ok(await b.isEnabled(),name);await b.evaluate(e=>e.click());await wait(250);}
 async function type(name,value){const f=page.getByRole('textbox',{name,exact:true});await f.click({force:true});await wait(300);await page.keyboard.press('ControlOrMeta+A');await page.keyboard.type(value,{delay:20});await page.keyboard.press('Tab');await wait(200);}
 async function open(){await page.goto('http://localhost:3007/#/workspace',{waitUntil:'networkidle'});const p=page.locator('flt-semantics-placeholder');if(await p.count())await p.evaluate(e=>e.click());await Promise.race([page.getByRole('textbox',{name:'Email',exact:true}).waitFor({state:'visible',timeout:30000}),page.getByRole('button',{name:'Profile',exact:true}).first().waitFor({state:'visible',timeout:30000})]);if(await page.getByRole('textbox',{name:'Email',exact:true}).isVisible()){await type('Email',email);await type('Password',password);const signed=page.waitForResponse(r=>r.url().endsWith('/auth/login'));await press('Sign in');assert.equal((await signed).status(),200);}await press('Profile');await page.getByRole('button',{name:'Add milestone',exact:true}).waitFor();}
 try{
  for(const skill of ['Docker','PostgreSQL']){const r=await http.put(api+'/cv',{headers,data:{data:{skills:[skill],projects:[],experience:[],profiles:{}}}});assert.equal(r.status(),200);}
  const versions=(await get('/me')).versions;const snapshots=[];
  for(const v of versions){const r=await http.post(api+'/workbench/snapshots',{headers,data:{kind:'cv_version',source_id:String(v.id)}});assert.equal(r.status(),202);const sid=(await r.json()).id;for(let i=0;i<60;i++){const snap=await get('/workbench/snapshots/'+sid);if(snap.status==='ready'){snapshots.push(snap);break;}assert.notEqual(snap.status,'failed');await wait(500);}}
  assert.equal(snapshots.length,2);const roleSaved=await http.put(api+'/role-fit',{headers,data:{revision:0,title:'Container engineer',description:'Docker',reviewed:true,requirements:[{skill:'Docker'}]}});assert.equal(roleSaved.status(),200);
  await open();
  async function choose(name,snap){const b=page.getByRole('button',{name:new RegExp(name)}).first();await b.waitFor({timeout:30000});await b.evaluate(e=>e.click());await wait(350);await page.getByLabel(new RegExp(snap.id.substring(0,6))).last().evaluate(e=>e.click());await wait(350);}
  await choose('Before snapshot',snapshots[0]);await choose('After snapshot',snapshots[1]);await press('Compare saved snapshots');
  let comp;for(let i=0;i<40;i++){comp=(await get('/workbench/comparisons'))[0];if(comp)break;await wait(500);}assert.ok(comp);
  await press('Add line annotation');await type('Annotation','Reviewed the changed skill claim; this is not a verification.');await press('Keep annotation');await press('Save annotations');
  for(let i=0;i<30;i++){comp=await get('/workbench/comparisons/'+comp.id);if(comp.revision===1)break;await wait(500);}assert.equal(comp.annotations[0].line,1);
  await page.mouse.move(1000,600);await page.mouse.wheel(0,700);await wait(650);await page.screenshot({path:path.join(output,'comparison-desktop.png')});
  await press('Interview practice');const check=page.getByRole('checkbox',{name:'Practice Docker',exact:true});await check.evaluate(e=>e.click());await press('Start practice session');
  let session;for(let i=0;i<30;i++){session=(await get('/workbench/practice')).sessions[0];if(session)break;await wait(500);}assert.ok(session);await type('Practice answer 0','I measured 20 percent fewer failures after changing the container health checks.');await press('Save practice answers');
  for(let i=0;i<30;i++){session=await get('/workbench/practice/'+session.id);if(session.revision===1)break;await wait(500);}assert.ok(session.answers['0'].includes('20 percent'));assert.equal(session.feedback.items[0].has_numeric_detail,true);
  await press('Complete practice');for(let i=0;i<30;i++){session=await get('/workbench/practice/'+session.id);if(session.status==='completed')break;await wait(500);}assert.equal(session.status,'completed');
  await page.mouse.move(1000,500);await page.mouse.wheel(0,550);await wait(650);await page.screenshot({path:path.join(output,'practice-desktop.png')});await page.setViewportSize({width:390,height:1100});await wait(650);await page.screenshot({path:path.join(output,'practice-phone.png')});
  await page.setViewportSize({width:1440,height:1100});const themed=await http.patch(api+'/me',{headers,data:{display_name:'Illustrative workbench QA',bio:'',preferences:{theme:'dark',reduced_motion:true}}});assert.equal(themed.status(),200);await press('Refresh workspace');await wait(650);await page.screenshot({path:path.join(output,'practice-desktop-dark.png')});
  await open();await press('Interview practice');assert.equal((await get('/workbench/practice/'+session.id)).status,'completed');assert.deepEqual(errors,[]);
  const receipt={checkedAtUtc:new Date().toISOString(),snapshots:snapshots.map(s=>s.id),comparisonId:comp.id,annotationRevision:1,practiceId:session.id,practiceCompleted:true,persistedAfterReload:true,pageErrors:errors};fs.writeFileSync(path.join(output,'acceptance.json'),JSON.stringify(receipt,null,2));console.log(JSON.stringify(receipt));
 }catch(e){await page.screenshot({path:path.join(output,'failure.png')});console.error(await page.getByRole('button').allTextContents());throw e;}finally{await browser.close();await http.dispose();}
})().catch(e=>{console.error(e);process.exitCode=1;});
