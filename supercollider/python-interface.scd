
//////////////////////////////////////////////////////////////////////
// Preliminary Python Interface OSC Responders
//////////////////////////////////////////////////////////////////////

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
