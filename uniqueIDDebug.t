#charset "us-ascii"
//
// uniqueIDDebug.t
//
#include <adv3.h>
#include <en_us.h>

#ifdef __DEBUG

modify uidManager
	execute() {
		inherited();
		verifyUIDs();
	}

	verifyUIDs() {
		local v;

		v = new Vector();
		forEachInstance(Object, function(o) {
			if(o._uid == nil) return;
			if(v.indexOf(o._uid) != nil)
				"\nUID COLLISION\n ";
			v.append(o._uid);
		});
	}
;

#endif // __DEBUG
