(
q.loadFile("lbp-labels.scd");
// linear binary pattern sonification

OSCdef(\lbp).clear;
OSCdef(\lbp, {|msg, time, addr, recvPort|
	var width, height, vector_size, lbp, path, filename;
	path = PathName.new(msg[1].asString);
	filename = path.fileNameWithoutExtension.asSymbol;
	msg.postln;
	# width, height, vector_size = msg[2..4];
	lbp = q.readCSVtoArray(path, width, height, vector_size);
	q[filename] = (width: width,
		height: height,
		vector_size: vector_size,
		filename: filename,
		path: path,
		lbp: lbp
	)
}, '/new_lbp');

);