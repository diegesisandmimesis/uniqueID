#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the uniqueID library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "uniqueID.h"

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;

versionInfo: GameID;
gameMain: GameMainDef
	initialPlayerChar = me
	newGame() {
		"This demo provides a <b>&gt;FOOZLE</b> command.  It
		implements a few simple tests of OIDs and UIDs. ";
		"<.p> ";
		runGame(true);
	}
;

DefineSystemAction(Foozle)
	_printIDs(obj) {
		if(obj == nil) {
			"\n_printIDs():  Nil object.\n ";
			return;
		}
		"\n<<obj.name>>: oid = <<toString(obj._oid)>>,
			uid = <q><<toString(obj._uid)>></q>\n ";
	}

	_lookupOID(id) {
		local obj;

		if((obj = oid2obj(id)) == nil) {
			"\nLookup of OID <<toString(id)>> failed.\n ";
			return;
		} else {
			"\nLookup of OID <<toString(id)>> returned
				<<obj.name>>\n ";
		}
	}

	_lookupUID(id) {
		local obj;

		if((obj = uid2obj(id)) == nil) {
			"\nLookup of UID <q><<toString(id)>></q> failed.\n ";
			return;
		} else {
			"\nLookup of UID <q><<toString(id)>></q> returned
				<<obj.name>>\n ";
		}
	}

	execSystemAction() {
		"Attempting to assign the <q>me</q> object the UID
			<q>foo</q>.\n ";
		guid(me, 'foo');

		_printIDs(me);

		"Attempting to assign the <q>startRoom</q> object the
			UID <q>foo</q>.  This should fail.\n ";
		guid(startRoom, 'foo');

		_printIDs(startRoom);

		_lookupUID('foo');
		_lookupOID(1);
		_lookupOID(2);
	}
;
VerbRule(Foozle) 'foozle': FoozleAction verbPhrase = 'foozle/foozling';
