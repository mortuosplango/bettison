(
//////////////////////////////////////////////////////////////////////
// RUN THIS
//////////////////////////////////////////////////////////////////////


(
// Server.default = s = Server.internal;
s.options.memSize_(8192 * 8).numOutputBusChannels_(2);
s.options.numWireBufs = 64 * 8;
s.reboot({
	s.doWhenBooted({
	("Lang Port is: " ++ NetAddr.langPort).postln;
	});
});
s.scope;
s.makeGui;
q = q ? ();
);

//
// OSCdef.freeAll;
// q.codeDir;
(
q.lastX = 0;
q.lastY = 0;
q.codeDir = "~/phd/ImageSonification/code/python/supercollider/".standardizePath;
q.loadFile = { |that,path,codeDir|
	codeDir = codeDir ? q.codeDir;
	(q.codeDir ++ path).load;
};

q.getID = { |that, path|
	path = PathName.new(path.asString);
	path.fileName.asSymbol;
};

q.readCSVtoArray = { |that, path, width, height, vectorsize|
	//var in = CSVFileReader.readInterpret(path.fullPath);
	// workaround for 3.7 bug
	var in = CSVFileReader.read(path.fullPath);
	in = in.collect(_.collect(_.interpret));
	in[0].clump(vectorsize).clump(height).clump(width)[0]
};


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
	}, '/new_data');



};

q.dataResponders();
CmdPeriod.add(q['dataResponders']);
);

);





/*
(q.codeDir ++ "datasonogram.scd").load;
*/