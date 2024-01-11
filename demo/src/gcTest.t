#charset "us-ascii"
//
// gcTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the uniqueID library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f gcTest.t3m
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

class Foo: Thing;
foo01: Foo;
foo02: Foo;
foo03: Foo;

versionInfo: GameID;
gameMain: GameMainDef
	newGame() {
		countFoo();
		newFoo();
		countFoo();
		t3RunGC();
		countFoo();
	}
	newFoo() {
		local obj;

		obj = new Foo();
		guid(obj);

		obj.releaseUID();
	}
	countFoo() {
		local n;

		n = 0;
		forEachInstance(Foo, function(o) { n += 1; });

		"foo count = <<toString(n)>>\n ";
	}
;
