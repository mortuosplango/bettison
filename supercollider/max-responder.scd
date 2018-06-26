// generic responder for max interface

OSCdef(\max).clear;
OSCdef(\max, { |msg|
	var path, fingerNo, frame, angle, majAxis, minAxis, x, y, vX, vY, id, state, size;
	# path, fingerNo, frame, angle, majAxis, minAxis, x, y, vX, vY, id, state, size = msg[1..];
	path = q.getID(path).asString;
	path = path[..(path.size-5)].asSymbol;
	x = (x * 512).round;
	y = (y * 512).round;
	["mc",path, fingerNo, frame, angle, majAxis, minAxis, x, y, vX, vY, id, state, size].postln;
	if((x != q.lastX) or: (y != q.lastY), {
		["f", path, msg[2..]].postln;
		//q.playSound(path, x, y, true, 0, 0.1, 'moved');
	});
	q.playSound(path, x, y, true, 0, size.linlin(0,3,0,1), 'moved');
	q.lastX = x;
	q.lastY = y;
}, '/touch');
