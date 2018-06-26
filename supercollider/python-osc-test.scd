(
s.options.sampleRate_(48000).memSize_(8192 * 8).numOutputBusChannels_(2);
s.reboot;
s.scope;
s.makeGui;
q = q ? ();
("Lang Port is: " ++ NetAddr.langPort).postln;
)


OSCdef.freeAll

(
q.getID = { |that, path|
	path = PathName.new(path.asString);
	path.fileName.asSymbol;
};

q.handleMessage = { |that, msg|
	var x,y,inside,button;
	var filename = q.getID(msg[1]);
	inside = msg[4];
	button = msg[5];
	if(inside.asString == "T", {
		x = msg[2].round;
		y = msg[3].round;
		inside = true;
	}, {
		inside = false;
		x = y = 0;
	});
	if((button.asString == "N") or: (button.asString == "T"),
		{
			button = false
		});
	[filename, x, y, inside, button]
};

q.getLabels = { |that,radius,num_points|
	var width = radius - 1;
	var edge_labels = (((num_points / 2).floor - width)..((num_points/2).floor + width ));
	var flat_labels = (0..width) ++ ((num_points - width)..(num_points+1));
	var i14 = (num_points / 4).floor;
	var i34 = (3 * (num_points / 4)).floor;
	var corner_labels = ((i14 - width)..(i14+width)) ++ ((i34 - width)..(i34 + width ));
	(edge: edge_labels.asInt, flat: flat_labels.asInt, corner: corner_labels.asInt)
};

q.lastX = 0;
q.lastY = 0;
OSCdef(\max).clear;
OSCdef(\max, { |msg|
	var path, fingerNo, frame, angle, majAxis, minAxis, x, y, vX, vY, id, state, size;
	# path, fingerNo, frame, angle, majAxis, minAxis, x, y, vX, vY, id, state, size = msg[1..];
	path = q.getID(path).asString;
	path = path[..(path.size-5)].asSymbol;
	x = (x * 512).round;
	y = (y * 512).round;
	if((x != q.lastX) or: (y != q.lastY), {
		["f", path, msg[2..]].postln;
		q.playSound(path, x, y, true, 0, 0.1, 'moved');
	});
	q.lastX = x;
	q.lastY = y;
}, '/touch');

OSCdef(\b).clear;
OSCdef(\b, { |msg|
	var x,y,inside,button, filename;
	# filename, x, y, inside, button = q.handleMessage(msg);
	["mc", filename, x, y, inside, button].postln;
	q.playSound(filename, x, y, inside, button, 0.3, 'clicked');
}, '/mouse/clicked');

OSCdef(\r).clear;
OSCdef(\r, { |msg| 
	var x,y,inside,button, filename;
	# filename, x, y, inside, button = q.handleMessage(msg);
	["mr", filename, x, y, inside, button].postln;
	//(degree: q[filename].lbp[x][y], amp: 0.1).play	
}, '/mouse/released');

OSCdef(\m).clear;
OSCdef(\m, { |msg| 
	var x,y,inside,button, filename;
	# filename, x, y, inside, button = q.handleMessage(msg);
	["mm", filename, x, y, inside, button].postln;
	//(degree: q[filename].lbp[x][y], amp: 0.1).play
	q.playSound(filename, x, y, inside, button, 0.3, 'moved');

}, '/mouse/moved');



q.readCSVtoArray = { |that, path, width, height, vectorsize|
	var in = CSVFileReader.readInterpret(path.fullPath);
	in[0].clump(vectorsize).clump(height).clump(width)[0]
};

OSCdef(\lbp).clear;
OSCdef(\lbp, {|msg, time, addr, recvPort|
	var width, height, vector_size, lbp, path, filename;
	path = PathName.new(msg[1].asString);
	filename = path.fileNameWithoutExtension.asSymbol;
	# width, height, vector_size = msg[2..4].postln;
	lbp = q.readCSVtoArray(path, width, height, vector_size);
	msg.postln;
	q[filename] = (width: width,
		height: height,
		vector_size: vector_size,
		filename: filename,
		path: path,
		lbp: lbp
	)
}, '/new_lbp');

)
(
q.playSound = { |that, filename, x, y, inside, button, amp=0.1|
		if((button != false) && inside  , {
			(degree: q[filename].lbp[x][y], amp: amp).play
		});
};
)

;
/*
q.getLabels(3, 8*3).edge.includes(12)
*/

(
SynthDef(\tick, { |out=0,amp=0.1,sustain=1.0,freq=440|
	var snd, env;
	snd = Impulse.ar(0).dup;
	env = EnvGen.ar(Env.perc(0.01,sustain), doneAction:2);
	OffsetOut.ar(out, snd * amp);
}).add;
)
(
SynthDef(\tick, { |out=0,amp=0.1,sustain=0.1,freq=4|
	var snd, env;
	snd = DC.ar(1).dup;
	env = EnvGen.ar(Env.linen(0.001,sustain,0.001), doneAction:2);
	OffsetOut.ar(out, snd * amp * env);
}).add;
)

Ndef(\rev, { var in = LeakDC.ar(In.ar(0,2)); in + AdCVerb.ar(in * 0.05) }).play


q.labels = q.getLabels(2, 8*2)
(
q.playSound = { |that, filename, x, y, inside, button, amp=0.1|
	if((button != false) && (inside.asString == "T")  , {
		var data = q[filename].lbp[x][y][0];
		if(q.labels.flat.includes(data).not,
			{
				Synth.grain(\tick, [\amp, data/17, \freq, data + 1, \sustain, (data+1)/18 * 0.1])
			});
	});
};
)

(
// sonogram edition
q.playSound = { |that, filename, x, y, inside, button, amp=0.1,action='none'|
	if((button != false) && inside  , {
		var radius = 4;
		var startingSound = true;
		var scoreData, score;
		
		if(action == 'moved', {
			radius = 3;
			startingSound = false;
		});
		
		scoreData = q.[\createScore].(
			dataset: q[filename], 
			velocity: amp/2, 
			impactPos: [x,y], //[1, 0.2, 0.1, 1]
			radius: radius,
			startingSound: startingSound
		);
		score = Score(scoreData).sort.play
	});
};
)



(
Tdef(\a, {
	q['10bph3.bsq'].lbp.do{
		|lbp,x|
		lbp.do{
			|rlbp,y|
			(degree: rlbp, amp: 0.1, sustain:0.05, octave: 5).play;
			[x,y].postln;
			0.1.wait;
		};
	};
}).play;
)
(
Tdef(\a, {
	(q['10bph3.bsq'].lbp[0].size/10).do{
		|x|
		q['10bph3.bsq'].lbp[x * 10].do{
			|rlbp,y|
			10.do{ |z|
				(degree: q['10bph3.bsq'].lbp[x + z][y], amp: 0.1, sustain:0.05, octave: 3, amp:0.01).play;
				0.01.wait;
			};
			[x,y].postln;
			//0.1.wait;
		};
	};
}).play;
)

s.scope

q['10bph3.bsq'].lbp


RandSeed


n.sendMsg("/filter", 3)
n.sendMsg("/mouse_clicked", 3,4)

OSCFunc.trace(true)
OSCFunc.trace(false)
Resonator

Physical

s.reboot
s.makeGui

//Define bow synthdef
(
SynthDef(\help_dwgbowed, { |out=0, freq=440, amp=0.5,force=1, gate=1,pos=0.07,c1=0.25,c3=31,pan=0|
    var vib = Gendy1.kr(1,1,1,1,0.1, 4,mul:0.003,add:1);
    var son = DWGBowed.ar(freq*vib, amp,force, gate,pos,0.1,c1,c3);
	    //son = DWGSoundBoard.ar(son);
	//var son = DWGBowedSimple.ar(freq*vib, amp,force, gate,pos,0.1,c1,c3);
    son = DWGSoundBoard.ar(son);
    son = BPF.ar(son,118,1)+son;
    son = BPF.ar(son,430,1)+son;
    son = BPF.ar(son,490,1)+son;
    son = LPF.ar(son,6000);
    Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;
)

//Use it.
(
Pdef(\a,
Pbind(
    \instrument, \help_dwgbowed,
	    \dur , 0.25,
	\force, Pwhite(0.5, 0.0),
	\pos, Pwhite(0.5, 0.0),
	\octave, [2,3,4,5,6,7],
	\legato, 4,
    \degree, Place([1,[2,5],[7,7+3]], inf),
    \amp , Pseq([0.9,0.7,0.5],inf),
)).play;
)

//Define pluck synthdef
(
SynthDef(\help_dwgplucked, { |out=0, freq=440, amp=0.5, gate=1, c3=20, pan=0|
    var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
    var son = DWGPluckedStiff.ar(freq, amp, gate,0.1,1,c3,inp);
    DetectSilence.ar(son, 0.001, doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;
)

//Use it.
(
a = Scale.new(
    #[0, 1, 3, 5, 7, 8, 10],
    12,
    Tuning.new([0, 0.75, 2, 3.5, 4, 5, 6, 7, 8, 9, 10, 11]),
    "Custom"
);

Pbind(
    \instrument, \help_dwgplucked,
    \scale ,a,
    \delta , Pseq([1,0.5,0.5,0.5,0.5,0.5,0.5,1,0.5,0.5,1,1]*0.25,inf),
    \dur , 2,
    \degree, Pseq([1,8,8,8,8,8,8,-6,Prand([9,10,11],1),1,7,8]-8, inf),
    \amp , Pwhite(0.2,0.8),
    \c3 , Pseq([Pseq([1400],24),Pseq([300],24)],inf),
    \pan , Pwhite(-1,1),
).play;
)

Tempo


BPZ
Ndef(\pl).clear
MdaPiano
(
Ndef(\pl, {
	var trig = PanAz.ar(16, Impulse.ar(5), MouseX.kr(-1,1));
	Splay.ar(DWGPluckedStiff.ar((1..16) * 30 + 500, inp: trig)) * 0.1 }).play
)
(
Ndef(\plo, {
	DWGPluckedStiff.ar((0..511) * 30 + 500, inp: Dust.ar(0.1!512))
}).play;
)



// Data Sonogram Help files

// SGCoord

m = SGMat4.newRot(45, SGVec3(0, 0, 1)).mult(SGMat4.newTrans(SGVec3(1, 2, 3)));
m = SGMat4.newTrans(SGVec3(1, 2, 3)).mult(SGMat4.newRot(45, SGVec3(0, 0, 1)));
m = SGMat4.newTrans(SGVec3(1, 2, 3)).mult(SGMat4.newTrans(SGVec3(1, 2, 3)));
m = SGMat4.newRot(45, SGVec3(1, 0, 0)).mult(SGMat4.newRot(45, SGVec3(1, 0, 0)));

c = SGCoord.fromMat4(m);

SGCoord.fromMat4(SGMat4.newIdent);
SGCoord.fromMat4(SGMat4.newTrans(SGVec3(1, 2, 3)));
SGCoord.fromMat4(SGMat4.newRot(45, SGVec3(1, 0, 0)));
SGCoord.fromMat4(SGMat4.newRot(45, SGVec3(0, 1, 0)));
SGCoord.fromMat4(SGMat4.newRot(45, SGVec3(0, 0, 1)));



// SGMat4

// superclass: SGObject

// A four-by-four matrix class.

//     		0    1    2    3
    
// 0   		0    1    2    3
// 1   		4    5    6    7
// 2   		8    9   10   11
// 3  	    12   13   14   15


// Examples

m = SGMat4.newRot(-30, SGVec3(0, 1, 0));
m.euler;

SGMat4.newRot(30, SGVec3(0, 0, 1)).euler

// h(Z), p(X), r(Y)

SGMat4.newRot

SGMat4.newRot(-90, SGVec3(1, 0, 0)).transformVec3(SGVec3(0, 0, 1));

m = SGMat4.newRot(90, SGVec3(1, 0, 0));
m.euler;
m.transformVec3(SGVec3(0, 1, 0));

// heading
m = SGMat4.newRot(45, SGVec3(0, 0, 1));
m.euler;
v = m.transformVec3(SGVec3(0, 1, 0));
v.hpr;
SGVec3(0, 0, 1).hpr

// pitch
(m = SGMat4.newRot(45, SGVec3(1, 0, 0))).euler;
m.transformVec3(SGVec3(0, 1, 0)).hpr;
m.transformVec3(SGVec3(0, 1, 0));

// roll
(m = SGMat4.newRot(45, SGVec3(0, 1, 0))).euler;
m.transformVec3(SGVec3(1, 0, 0));
m

SGVec3(1, 0, 0).hpr;
SGVec3(0, 1, 0).hpr;

SGMat4.newCoord(SGCoord(SGVec3(0, 0, 0), SGVec3(44, 44, 44))).euler

m = SGMat4.newCoord(SGCoord(SGVec3(0, 0, 0), SGVec3(90, 0, 0)));
m.euler;
m.transformVec3(SGVec3(0, 1, 0));

SGMat4.newRot(30, SGVec3(0, 0, 1)).mult(SGMat4.newRot(-30, SGVec3(0, 0, 1)))

SGMat4.newRot(30, SGVec3(0, 0, 1)).mult(SGMat4.newIdent)
SGMat4.newIdent.mult(SGMat4.newIdent);


m = SGMat4.newRot(30, SGVec3(0, 0, 1));
m.mat[0][0]


/// quat

q = SGMat4.newRot(70, SGVec3(0, 1, 0)).toQuat
q = SGQuat.newAngleAxis(70, SGVec3(0, 1, 0));
q.toAngleAxis;

/// intersect infinite line with plane

p = SGPlane.fromPointAndNormal(SGVec3(0, 0, 0), SGVec3(0, 0, 1));
p.distanceOfVec3(SGVec3(0, 0, 1));

a = -45;
x = SGVec3(1, 0, 0);
m = SGMat4.newRot(a, x);
v = m.transformVec3(SGVec3(0, 1, 0));
p.intersectInfLine(SGVec3(0, 0, 1), v) // origin, direction
p.intersectInfLine(SGVec3(0, 5, 0), SGVec3(0, 1, -1).normalize) // origin, direction

p.intersectInfLine(SGVec3(0, 1, -1), SGVec3(0, 0, 10))


SGPlane.fromPointAndNormal(SGVec3(0, 0, 0), SGVec3(0, 0, 1)).intersectInfLine(SGVec3(0, 0, 1), SGVec3(0, 1, -1).normalize);



p = SGPlane.fromPointAndNormal(SGVec3(0, 0, 0), SGVec3(0, 1, 1).normalize);
p.distanceOfVec3(SGVec3(0, 1, 1));

p.intersectInfLine(SGVec3(0, 0, 4), SGVec3(1, 0, -1));

m = SGMat4.newRot(-45, SGVec3(1, 0, 0));
m = SGMat4.newRot(90, SGVec3(0, 0, 1));

m.transformVec3(SGVec3(0, 1, 0));

p.intersectInfLine(SGVec3(0, 0, 4), SGVec3(1, 0, -1));

// constructors

SGPlane.from3Points(SGVec3(0, 0, 0), SGVec3(1, 1, 0), SGVec3(0, 1, 1))
SGPlane.fromPointAndNormal(SGVec3(0, 0, 0), SGVec3(1, -1, 1).normalize)

//

p = SGPlane.fromPointAndNormal(SGVec3(0, 0, 0), SGVec3(0, 0, 1).normalize);
p.intersectSegment(SGVec3(0, 0, 1), SGVec3(0, 1, 2));
p.intersectInfLine(SGVec3(0, 0, 1), SGVec3(0, -1, -1)); // wrong
p.intersectInfLine2(SGVec3(0, 0, 1), SGVec3(0, -1, -1));

p.intersectSegment(SGVec3(0, 1, 2), SGVec3(0, 0, 1));
p.intersectInfLine(SGVec3(0, 1, 2), SGVec3(0, -1, -1));

// angle axis conversions

SGQuat.newAngleAxis(190, SGVec3(0, 0, 1)).toAngleAxis;

SGQuat.newAngleAxis(179, SGVec3(0, 0, 1))
SGQuat.newAngleAxis(180, SGVec3(0, 0, 1))
SGQuat.newAngleAxis(181, SGVec3(0, 0, 1))

cos(181 * pi / 180 / 2)

// equivalences

SGQuat(0, -0.7071, 0, 0.7071).euler
SGQuat(0, 0.7071, 0, -0.7071).euler
SGQuat.newAngleAxis(270, SGVec3(0, 1, 0))
SGQuat.newAngleAxis(-90, SGVec3(0, 1, 0))

// SGQuat.newAngleAxis - SGMat4.newRot.toQuat

(
a = 70;
x = SGVec3(0, 0, 1);
SGQuat.newAngleAxis(a, x).postln;
SGMat4.newRot(a, x).toQuat.postln;
nil
)

(
a = 70;
x = SGVec3(0, 0, 1);
SGMat4.newRot(a, x).postln;
SGQuat.newAngleAxis(a, x).toMat4.postln;
nil
)

//

SGMat4.newRot(70, SGVec3(0, 0, 1)).euler
SGMat4.newRot(70, SGVec3(0, 0, 1)).toQuat.euler
SGMat4.newRot(70, SGVec3(0, 0, 1)).toQuat.toMat4Bad.euler

m = SGMat4.newRot(190, SGVec3(0, 0, 1));
m.toQuat;
m.toQuat.toAngleAxis;

q = SGQuat.newAngleAxis(570, SGVec3(1, 1, 1));
q.toAngleAxis;

q
q.toMat4.toQuat; // toMat4 seems wrong


// this is ok

SGQuat.newAngleAxis(170, SGVec3(1, 1, 1)).toMat4;
SGMat4.newRot(170, SGVec3(1, 1, 1));

SGQuat.newAngleAxis(170, SGVec3(1, 0, 1)).toAngleAxis;


190 -> 170
200 -> 160
250 -> 110
300 ->  60
330 ->  30
360 ->   0

-20.abs

SGQuat.newAngleAxis(100, SGVec3(0, 1, 0)).euler
SGMat4.newRot(100, SGVec3(1, 0, 0)).euler


SGQuat.newAngleAxis(90, SGVec3(0, 1, 0)).toMat4
SGMat4.newRot(90, SGVec3(0, 1, 0)).euler

SGQuat.newAngleAxis(90, SGVec3(1, 0, 0)).toMat4
SGMat4.newRot(90, SGVec3(1, 0, 0))

v = SGVec3.new;
v = SGVec3.new(1, 2, 3);
v = SGVec3(1, 2, 3);
v.postln;
v.x;
v.x = 3;
v.asArray;
v.zero.postln;
v.asCompileString

SGVec3.new.postln

SGVec3(1, 2, 3).zero
SGVec3(1, 2, 3).negate
SGVec3(1, 2, 3).compare(SGVec3(1, 2, 2.9), 0.01)
SGVec3(1, 2, 3).equal(SGVec3(1, 2, 3))
SGVec3(1, 2, 3).length
SGVec3(1, 2, 3).distance(SGVec3(4, 5, 6))
SGVec3(1, 2, 3).normalize.length
SGVec3(1, 2, 3).scalarProduct(SGVec3(1, 2, 3))
SGVec3(1, 0, 0).vectorProduct(SGVec3(0, 1, 0))

SGVec3(1, 2, 3).lerp(SGVec3(2, 3, 4), 0.5)
SGVec3(1, 2, 3).lerp(SGVec3(0, 0, 0), 0.5)

SGVec3(1, 2, 3).lerpAngles(SGVec3(0, 0, 0), 0.5)

SGVec3(1, 2, 3).lerp(SGVec3(400, 3, 2), 0.5)

SGVec3(0, -1, 0).hpr

x = SGMat4.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
x.mat4x4

x = [[1, 2, 3, 4], [4, 5, 6, 7], [8, 9, 10, 11], [12, 13, 14, 16]]


x[2][2]

SGVec3(1, 2, 3).addScaled(SGVec3(4, 5, 6), 4);

SGMat4.new
SGMat4.newRot(30, SGVec3(1, 0, 0)).euler

c = SGCoord(SGVec3(10, 20, 30), SGVec3(30, 20, 10))
c.x
SGMat4.newCoord(SGCoord(SGVec3(10, 20, 30), SGVec3(30, 20, 10)))

SGQuat.newAngleAxis(30, SGVec3(0, 1, 0)).toAngleAxis
SGQuat.new

SGVec3(1, 1, 1).normalize.length
SGVec3(1, 1, 0).normalize
SGVec3(1, 1, 0).length


SGVec3.makeNormalFrom3Points(SGVec3(0, 0, 0), SGVec3(1, 0, 0), SGVec3(0, 1, 0));
SGVec3.makeNormalFrom3Points(SGVec3(0, 1, 0), SGVec3(1, 0, 0), SGVec3(0, 0, 0));

// heading = -90
SGVec3(1, 0, 0).hpr;

// pitch = 45
SGVec3(0, 1, 1).hpr

