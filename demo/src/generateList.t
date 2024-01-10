#charset "us-ascii"
//
// base.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
//	This isn't a demo, it's a little utility program that writes
//	a sourceTextGroup exclude list to a file.
//
//	This is used to generate a list of groups whose objects we
//	won't automatically assign OIDs and UIDs to.
//
#include <adv3.h>
#include <en_us.h>

#include "uniqueID.h"

versionInfo: GameID;
gameMain: GameMainDef
	filename = 'uniqueIDExclude.t'
	excludeList = static [ 'uniqueID.t', 'base.t' ]

	newGame() {
		writeExcludeList();
	}

	writeExcludeList() {
		local l, buf, i;

		if((l = uidManager.getSourceTextGroups(excludeList)) == nil) {
			"Failed to get list of source text groups.\n ";
			return;
		}

		buf = new StringBuffer();
		buf.append('#charset "us-ascii"\n');
		buf.append('//\n');
		buf.append('// uniqueIDExclude.t\n');
		buf.append('//\n');
		buf.append('#include <adv3.h>\n');
		buf.append('#include <en_us.h>\n');
		buf.append('\n');
		buf.append('modify uidManager\n');
	
		buf.append('\texcludeList = static [\n');
		for(i = 1; i < l.length; i++) {
			buf.append('\t\t\'');
			buf.append(l[i]);
			buf.append('\',\n');
		}
		buf.append('\t\t\'');
		buf.append(l[l.length]);
		buf.append('\'\n');
		buf.append('\t]\n');
		buf.append(';\n');

		if(_stringToFile(buf, filename) == nil) {
			"Failed.\n ";
		} else {
			"Wrote exclude list to <q><<filename>></q>.\n ";
		}
	}

	_stringToFile(buf, fname) {
		local log;

		try {
			log = File.openTextFile(fname, FileAccessWrite, 'utf8');
			log.writeFile(buf);
			log.closeFile();

			return(true);
		}
		catch(Exception e) {
			"ERROR:  File write failed:\n ";
			"\t";
			e.displayException();
			return(nil);
		}
	}
;
