(
Server.default = s = Server.local;
s.boot; //reemplaza cmd+B
/***************** SynthDefs ********************/

//GRANULADOR

SynthDef(\grain, {arg outBus = 0, eqBus, reverbBus = 10, direct = 0.9, gate = 1, amp = 1, envbuf = -1, sndbuf, grainSize = 0.5, trig = 10, rateMin = 0.1, rateMax = 2, pan = 0;
	var env, source, grainbuf;
	~pan = pan;
	env = EnvGen.kr(
		Env([0, 1, 1, 0], [0.05,0.9,0,0.05],\sin, 1),
		gate,
		levelScale: amp,
		doneAction: 2);
	grainbuf = GrainBuf.ar(numChannels: 1,
		trigger: Impulse.kr(trig),
		dur: grainSize,
		sndbuf: sndbuf,
		rate:  LFNoise1.kr.range(rateMin, rateMax),
		pos: LFNoise2.kr(0.1).range(0.0, 1.0),
		interp: 4, //se puede cambiar a 2 si hace falta más memoria
		pan: 0,
		envbufnum: envbuf,
		maxGrains: 256, //se puede cambiar a 128 si hace falta más memoria
		mul: amp,
		add: 0);
	Out.ar(eqBus, Pan2.ar(grainbuf * env * direct, pan));
	Out.ar(reverbBus, grainbuf * env * (1 - direct));
}).add;

//EFECTOS

SynthDef(\reverb, { arg outBus = 0, inBus, roomsize = 30, revtime = 3, damping = 0.5, inputbw = 0.5, spread = 15, drylevel = -3, earlyreflevel = -11, taillevel = -9, maxroomsize = 300, mul = 1, add = 0;
	var input;
	input = In.ar(inBus, 1);
	input = GVerb.ar(input, roomsize, revtime, damping, inputbw, spread, drylevel.dbamp, earlyreflevel.dbamp, taillevel.dbamp, maxroomsize, mul, add);
	Out.ar(outBus, input);
}).add;

~reverbBus = Bus.audio(s,1);
~rev = Synth.new(\reverb, [\inBus, ~reverbBus], addAction: \addToTail);

//EQ

SynthDef(\eqOut, { arg outBus = 0, inBus;
	var input;
	input = In.ar(inBus, 2);
	Out.ar(outBus, input);
}).add;

/***************** Buffers ********************/
//esto se carga desde Processing
~ambiente = Buffer.read(s,thisProcess.nowExecutingPath.dirname+/+"ambiente3.wav");
~edificios = Buffer.read(s,thisProcess.nowExecutingPath.dirname+/+"edificios.wav");
~manija1 = Buffer.read(s,thisProcess.nowExecutingPath.dirname+/+"llaves.wav");
~manija2 = Buffer.read(s,thisProcess.nowExecutingPath.dirname+/+"cuadrado.wav");
~manija3 = Buffer.read(s,thisProcess.nowExecutingPath.dirname+/+"cuadrado2.wav");
~manija4 = Buffer.read(s,thisProcess.nowExecutingPath.dirname+/+"bocina.wav");
~manija5 = Buffer.read(s,thisProcess.nowExecutingPath.dirname+/+"Analysis-cuadrado2.wav");
~manija6 = Buffer.read(s,thisProcess.nowExecutingPath.dirname+/+"bocina_2.wav");


/***************** Envolventes ****************

~env1 = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
~envBuf1 = Buffer.sendCollection(s, ~env1.discretize, 1);
~env2 = Env.perc;
~envBuf2 = Buffer.sendCollection(s, ~env2.discretize, 1);
~env3 = Env([0, 1, 1, 0], [0.025,0.95,0,0.025]);
~envBuf3 = Buffer.sendCollection(s, ~env3.discretize, 1);
*/
/***************** EQs ************************/

//MultiEQs
~eqA = MultiEQ(2, \hishelf, 2200, -14.dbamp, 1.4, \loshelf, 300, -7.dbamp, 1);
~eqB = MultiEQ(2, \eq, 600, 0.7, 1.8, \loshelf, 200, 0.1, \eq, 11000, 1.5, 1.5);
~eqC = MultiEQ(2, \eq, 600, 0.7, 1.8, \loshelf, 200, 0.1, \eq, 11000, 1.5, 1.5);
~eqD = MultiEQ(2, \eq, 1500, 4.dbamp, 2, \eq, 100, -12.dbamp, 1.600);
~eqE = MultiEQ(2, \eq, 600, 0.7, 1.8, \loshelf, 200, 0.1, \eq, 11000, 1.5, 1.5);
~eqF = MultiEQ(2, \hishelf, 2500, 12.dbamp, 2);
~eqG = MultiEQ(2, \eq, 155, 4.dbamp, 2, \eq, 490, 16.dbamp, 1);
~eqH = MultiEQ(2, \eq, 5350, -12.dbamp, 1.8, \loshelf, 250, -12.dbamp, \hishelf, 10900, -9.dbamp, \eq, 6250, -16.dbamp, 2);

~eqSynth = 8.collect({arg i; Synth.new(\eqOut, [\inBus, 20+i], addAction: \addToTail)});
)
(
//este bloque se ejecuta despues de que los synths estén cargados y/o sonando
~eqA.play(a, 20);
~eqB.play(b, 21);
~eqC.play(c, 22);
~eqD.play(d, 23);
~eqE.play(e, 24);
~eqF.play(f, 25);
~eqG.play(g, 26);
~eqH.play(h, 27);
)

~eqA.edit(a, 20);
~eqB.edit(b, 21);
~eqC.edit(c, 22);
~eqD.edit(d, 23);
~eqE.edit(e, 24);
~eqF.edit(f, 25);
~eqG.edit(g, 26);
~eqH.edit(h, 27);

/***************** Synths *********************/
(
a = Synth(\grain,  [\sndbuf, ~ambiente,\eqBus, 20, \rateMin, 0.95, \rateMax, 1.0, \trig, 8, \grainSize, 2]); //valores fijos
a.set(\amp, 0.1); // if (b || c || d || e || f || g están sonando){amp = 0.1}else{amp = 0.4}
)
(
b = Synth.before(~rev, \grain, [\sndbuf, ~manija1,\pan, 1, \reverbBus, ~reverbBus.index, \eqBus, 21, \direct, 0.9, \rateMin, 0.7, \rateMax, 1.2, \amp, 0.7]);
b.set(\trig, 10); //min: 0.1, max: 10
b.set(\grainSize, 1); // min 0.2, max: 1
)
(
c = Synth(\grain,[\sndbuf, ~manija2, \pan, 1,\eqBus, 22, \rateMin, 0.9, \rateMax, 1.1, \amp, 0.7]);
c.set(\trig, 1); //min: 0.1, max: 10
c.set(\grainSize, 1); //min: 0.1, max: 1
)
(
d = Synth(\grain,[\sndbuf, ~manija3, \pan, 1, \eqBus, 23, \rateMin, 0.2, \rateMax, 0.4, \amp, 0.7]);
d.set(\trig, 3); //min: 0.1, max: 3
d.set(\grainSize, 1); //min: 0.1, max: 1
)
(
e = Synth(\grain,[\sndbuf, ~manija4, \pan, -1, \eqBus, 24, \rateMin, 0.1, \rateMax, 1.2,\amp, 0.3]);
e.set(\trig, 8); //min: 0.1, max: 8
e.set(\grainSize, 1); //min: 0.1, max: 10
)
(
f = Synth(\grain,[\sndbuf, ~manija5, \pan, -1, \eqBus, 25, \amp, 0.7, \rateMin, 0.001, \rateMax, 2.0]);
f.set(\trig, 15); //min: 0.1, max: 15
f.set(\grainSize, 0.3); //min: 0.02, max: 0.3
)
(
g = Synth(\grain,[\sndbuf, ~manija6, \pan, -1, \eqBus, 26,\rateMin, 0.5, \rateMax, 1, \amp, 0.7]);
g.set(\trig, 15); //min: 0.1, max: 15
g.set(\grainSize, 0.02); //min: 0.02, max: 0.1
)
(
h = Synth(\grain,[\sndbuf, ~edificios, \eqBus, 27, \trig, 2, \grainSize, 3, \rateMin, 1, \rateMax, 1]);
h.set(\amp, 0.7); // if (aparecen edificios y no hay personas){amp = 0.7}else if(aparecen edificios y hay personas){amp = 0.1}
)

~rev.set([\roomsize, 16, \revtime, 1.24, \damping, 0.10, \inputbw, 0.95, \drylevel -3, \earlylevel, -15, \taillevel, -17, \mul, 0.3]);
