import fs from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';
// Diagnostic de défauts connus, pas une assertion de comportement correct.
// Exécute des fragments du code réel ; DOM, réseau et timers sont simulés.
const root = new URL('../../../games/web/includes/canvas/play/register.js', import.meta.url);
const src = fs.readFileSync(root, 'utf8');
const cut = (start, end) => {
 const a=src.indexOf(start), b=src.indexOf(end,a+start.length);
 assert(a>=0 && b>a, `${start} / ${end}`); return src.slice(a,b);
};
const settle = async()=>{for(let i=0;i<20;i++) await Promise.resolve();};
// Reproduction 1: actual probe function, simulated WS and fake timers.
for (const outcome of ['response','timeout']) {
 const sockets=[],timers=[];
 class WS { constructor(){sockets.push(this);} send(){} close(){this.onclose?.();} }
 const ctx=vm.createContext({WebSocket:WS,wsUrl:'wss://local.invalid',slug:'bingo',hubAutoPlayer:{player_id:'p:test'},
  _wsProbeInFlight:false,_wsProbePromise:null,_lastStatus:null,normalizeStatus:x=>x,Bus:{emit(){}},sanitizeError:String,
  setTimeout:fn=>timers.push(fn)});
 vm.runInContext(cut('  function tryConnectWebSocket(sessionId) {','  function toggleForm'),ctx);
 let firstDone=false,secondDone=false;
 const p1=ctx.tryConnectWebSocket('s').then(()=>firstDone=true);
 ctx.tryConnectWebSocket('s').then(()=>secondDone=true);
 assert.equal(sockets.length,1);
 if(outcome==='response')sockets[0].onmessage({data:JSON.stringify({type:'sessionStatus',token:'s',active:true,full:false})});
 else timers[0]();
 await p1;await settle();
 assert.equal(firstDone,true);assert.equal(secondDone,false);
 console.log(`REPRO probe concurrent (${outcome}): first resolved; follower still pending`);
}
// Reproduction 2: actual Hub bootstrap, UI state, failure catch and polling loop.
const hubFunctions=cut('  async function tryAutoRegisterFromHub(', '  let hubAutoRegisterBootPromise');
const uiFunction=cut('  function setUiState(', '  function formatSessionLabel');
const catchStart=src.indexOf("      } catch (err) {\n        try { Bus?.emit?.('register/autoreg:flow_fail'");
const catchEnd=src.indexOf('      } finally {',catchStart);
assert(catchStart>0 && catchEnd>catchStart);
const catchBody=src.slice(catchStart+'      } catch (err) {'.length,catchEnd);
let poll=cut("  let lastKey = '';",'    // Suspend/reprend quand');
poll=poll.replace('(async function pollGate(){','globalThis.pollTask = (async function pollGate(){');
function build(){
 const timers=[],events=[],store=new Map(); let submits=0;
 const node=()=>({style:{},hidden:false,textContent:'',setAttribute(){},removeAttribute(){}});
 const ctx=vm.createContext({
  window:{AppConfig:{sessionId:'s',hubAutoPlayer:{}}},document:{documentElement:node()},
  hubAutoPlayer:{enabled:true,name:'test',player_id:'p:test',playerId:1,session_token:'s'},
  slug:'bingo',sessionId:'s',hubAutoRegisterStarted:false,registered:false,registrationCompleted:false,
  leftVoluntarily:false,playerFormSubmitBound:true,pendingHubAutoRegisterReason:'',pollRunning:true,
  currentUiState:null,UI_STATE:{OPEN:'OPEN',FULL:'FULL',NO_MASTER:'NO_MASTER',GM_AUTOREGISTERING:'GM'},
  isHubAutoMappingActive:()=>true,isPaperMode:()=>false,isReturningPlayer:()=>false,
  form:Object.assign(node(),{requestSubmit(){submits++;}}),playerNameInput:node(),registerNote:node(),
  closedTitle:node(),closedSub:node(),registerClosed:node(),errorMessage:node(),paperMessage:node(),paperCta:node(),paperUnregisterBlock:node(),playerAccountBlock:node(),
  keyPid:'pid',keyPnm:'pnm',keyPdb:'pdb',localStorage:{getItem:k=>store.get(k),setItem:(k,v)=>store.set(k,v)},
  getPlayerId:()=>null,persistStablePlayerId(){},persistServerPlayerIdIfAbsent(){},setPlayerDbId(){},
  emitRegisterDebug:(...a)=>events.push(a),releaseHubAutoRestore(){},Bus:{emit(){}},setStage(){},
  updatePlayerAccountPromise(){},updateEpConnectNote(){},hasPendingEpConnectFlow:()=>false,
  isGmIframe:false,epConnectToken:'',lastRejectedRegisterCode:null,sanitizeError:String,
  gate:{active:true,full:false},setTimeout:fn=>timers.push(fn),
  syncEpConnectNoMasterState:async()=>{},tryAutoRegisterFromEp:async()=>{},
 });
 ctx.tryConnectWebSocket=async()=>({...ctx.gate});
 vm.runInContext(hubFunctions+uiFunction+'\nasync function registrationFailed(err){'+catchBody+'\n}',ctx);
 return {ctx,timers,events,submits:()=>submits,poll:()=>vm.runInContext(poll,ctx)};
}
// Successful stable-gate bootstrap does not submit twice.
{
 const h=build();await h.ctx.bootHubAutoRegister('initial');h.poll();await settle();
 assert.equal(h.submits(),1);h.ctx.registered=true;h.timers.shift()();await h.ctx.pollTask;
 console.log('CONTROL initial in-flight registration: exactly one submission');
}
// Failure AFTER the OPEN gate has already been processed: no retry.
{
 const h=build();await h.ctx.bootHubAutoRegister('initial');h.poll();await settle();
 assert.equal(h.ctx.currentUiState,'OPEN');assert.equal(h.submits(),1);
 await h.ctx.registrationFailed(new Error('simulated transient grid error'));
 assert.equal(h.ctx.hubAutoRegisterStarted,false);
 for(let i=0;i<3;i++){assert(h.timers.length);h.timers.shift()();await settle();}
 assert.equal(h.submits(),1);assert.equal(h.ctx.registered,false);
 console.log('REPRO late transient failure: 3 successful OPEN polls; no retry; player unregistered');
 h.ctx.gate={active:false,full:false};h.timers.shift()();await settle();assert.equal(h.submits(),2);
 console.log('CONTROL gate change after failure: submission retried');
 h.ctx.registered=true;h.timers.shift()();await h.ctx.pollTask;
}
// Identical failure BEFORE first OPEN observation: retry occurs.
{
 const h=build();await h.ctx.bootHubAutoRegister('initial');
 await h.ctx.registrationFailed(new Error('same simulated transient grid error'));await settle();
 assert.equal(h.submits(),2);
 console.log('CONTROL early transient failure: submission retried immediately');
}
