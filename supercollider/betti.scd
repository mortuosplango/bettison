
(
// dataResponder loads any data that python sends it
//  saving it into a subfield of the image
q.forceReload = false;
q.dataResponders = {
	OSCdef(\data).clear;
	OSCdef(\data, {|msg, time, addr, recvPort|
		var width, height, vector_size, data, path, imgpath, filename;
		var label = msg[1];
		imgpath = PathName.new(msg[2].asString);
		path = PathName.new(msg[3].asString);
		filename = imgpath.fileName.asSymbol;
		msg.postln;
		# width, height, vector_size = msg[4..6];
		if(q.forceReload or: q[filename].isNil, {
			q[filename] = (width: width,
				height: height,
				vector_size: vector_size,
				filename: filename,
				path: imgpath,
			);
		});
		if(q.forceReload or: q[filename][label].isNil, {
			data = q.readCSVtoArray(path, width, height, vector_size);
			q[filename][label] = data;
		}, {
			"Not reloading data. Set q.forceReload to true to force reloading.".warn;
		});
		if(label == 'betti', {
			q.bettibuf.setn(0, q[filename]['betti'].flatten.collect(_[1]).postln);
			Ndef(\betti).set(\t_trig, 1);
		});
		q.last_path = filename;
		//q.bettibuf.setn(0, q[filename]['betti'].flatten.postln);
	}, '/new_data');
};

q.dataResponders();

q.bettibuf = q.bettibuf ? Buffer.alloc(s, 7*7, 1);
q.revbus = q.revbus ? Bus.audio(s, 2);
q.playSound = { |that, filename, x, y, inside, button, amp=0.1,action='none'| };

OSCdef(\max).clear;
OSCdef(\max, { |msg|
	var path, fingerNo, frame, angle, majAxis, minAxis, x, y, vX, vY, id, state, size;
	# path, fingerNo, frame, angle, majAxis, minAxis, x, y, vX, vY, id, state, size = msg[1..];
	path = q.getID(path).asString;
	path = path[..(path.size-5)].asSymbol;
	x = (x * 511).round;
	y = 511 - (y * 511).round;
	//[x,y].postln;
	//["mc",path, fingerNo, frame, angle, majAxis, minAxis, x, y, vX, vY, id, state, size].postln;
	q.playSound(path, x, y, true, fingerNo, 0.1, 'moved');

	if(fingerNo == 0, {
	//q.playSound(path, x, y, true, 0, size.linlin(0,3,0,1), 'moved');
		Ndef(\betti).set(\x, x, \y, y);
		q.lastX = x;
		q.lastY = y;
	});
}, '/touch');
)
s.scope
s.meter


q[q.last_path]['betti'].collect({|i| i.collect(_[1]) })
q[q.last_path]['betti'][0][3]

q[q.last_path]['betti'].flatten.collect(_[1])

Quarks.gui
(

Ndef(\rev, {
	var in = In.ar(q.revbus,2); in}).play;
)

(

Ndef(\rev, {
	var in = In.ar(q.revbus,2); in + AdCVerb.ar(in * 0.01,2,0.9) }).play;
)
(
Ndef(\betti, { |t_trig=1,x=0,y=0|
	var activation;
	var snd = Silent.ar;
	var changed;
	var timePerLine = 0.1;
	var flag = (EnvGen.ar( Env.perc(0.15,3),
		DelayN.ar(
		Trig1.ar(t_trig),
		(0..6) * timePerLine,
		(0..6) * timePerLine)
	) + 0.1).tanh;
	//[x,y].poll;

	var buf = q.bettibuf;
	var steps = 7;

	var maxDist = ((steps-1).squared * 2).sqrt;
	var radius = 2.sqrt;

	x = x * (steps/511);
	y = y * (steps/511);
	changed = LagUD.kr((Changed.kr([x,y]).sum).clip(0,1), 0.1, 5);
	//x.poll;

	steps.do{ |yy|
		snd = snd + Splay.ar(
			steps.collect{ |xx|
				var sweepAxis = yy;
				var index = (xx * steps) + yy;
				var betti = BufRd.kr(1, buf, index, interpolation: 1);
				var freq = 110 * (((betti > 4)
					* (betti - 4))
					+ 1);
				var amp = Pan2.ar(DC.ar(1),
					// euclidean distance from mouse pointer
					// to middle of field
					((xx - x + 0.5).squared
						+ (yy - y + 0.5).squared
					).sqrt.linlin(0,radius, 1, -1, clip: 'minmax'))[1] * changed;
				// equal-power panning between this point
				// and diagonally next point
				LPF.ar(
					SinOsc.ar(freq * LFNoise1.kr(0.01).range(0.99,1.01))
					* AmpComp.kr(freq, 110)
					* (0.1 + (amp * 2) + flag[sweepAxis]).clip(0,1),
					(400 + ((flag[sweepAxis] - 0.1) * 18000)
						+ (LagUD.ar(amp,0.01,1)
							//amp
							* 18000)
					).clip(20,20000)
				)
			});
	};
	//(snd * LagUD.ar(Trig1.ar(t_trig), 0.15, 4,add:0.1)).tanh;
	(snd * 0.2).tanh;
	}).play;
)



Ndef(\betti).stop



Ndef(\betti).play

s.quit


Ndef(\betti).clear








// sweeping gist
/*
	var timePerLine = 0.1;
	var xenv = EnvGen.kr(
		Env.new(
			[0,steps-1].dup(steps).flatten,
			[timePerLine,0].dup(steps).flatten.drop(-1)), t_trig) + 0.5;
	var yenv = EnvGen.kr(
		Env.new(
			[0,6],
			timePerLine * (steps-1)), t_trig).round(1) + 0.5;
	var xyenv = EnvGen.kr(Env.linen(0.01,steps * timePerLine,0.5), t_trig);
*/
