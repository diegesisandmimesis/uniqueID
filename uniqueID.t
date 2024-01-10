#charset "us-ascii"
//
// uniqueID.t
//
//	A TADS3/adv3 module for creating and managing unique object IDs.
//
//
// OVERVIEW
//
//	By default, this module will create a numeric object ID (OID) for
//	each object declared in the game source, not including those
//	defined in stock adv3.
//
//	In addition, you can either assign a unique alphanumeric ID (UID)
//	for each object, or have one automatically assigned by the module.
//
//	This is intended to make it easier to programatically interact with
//	data structures and functions that index objects.
//
//
// USAGE
//
//	OID assignment is automatic, happening at preinit.
//
//	To assign a UID to an object, use:
//
//		guid(obj, 'someIdentifier');
//
//	This will attempt to assign the UID "someIdentifier" to the object.
//	If that UID is already in use, obj will instead be assigned
//	a UID equal to "someIdentifier" plus its OID.  I.e., if obj's OID
//	is 123, then its UID would be "someIdentifier#123".
//
//	The return value of guid() is the assigned UID, or nil on failure.
//
//	To assign an arbitrary UID to an object, use:
//
//		guid(obj);
//
//	...by itself.  It will be assigned a UID of the form "obj#123",
//	where 123 is the object's UID.
//
//
//	Each object's OID and UID will be available on the object as its
//	_oid and _uid property, respectively.
//
//
//	To obtain an object reference for a given OID or UID, use:
//
//		uid2obj('someIdentifier');	// returns object with given UID
//		oid2obj(123);			// returns object with given OID
//
#include <adv3.h>
#include <en_us.h>

// Module ID for the library
uniqueIDModuleID: ModuleID {
        name = 'Unique ID Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

// Add a couple properties to each object.
modify Object
	_oid = nil		// object ID.  numeric, assigned by uidManager
	_uid = nil		// unique ID.  can be assigned by the programmer
;

// Singleton that keeps track of OIDs and UIDs.
uidManager: PreinitObject
	_groups = nil		// lookup table of sourceTextGroups
	_offsets = nil		// number of objects in each sourceTextGroup

	_counter = 0		// number of extant object IDs

	// Lookup tables for UID -> OID and OID -> UID
	_uidLookup = perInstance(new LookupTable())
	_oidLookup = perInstance(new LookupTable())

	excludeList = static []

	// Preinit bookkeeping.
	execute() {
		enumerateGroups();
		createOffsets();
		traverseObjects();
	}

	// Iterate over all the objects and figure out how many sourceTextGroups
	// we have.  This should roughly correspond to the number of source
	// files.
	enumerateGroups() {
		_groups = new LookupTable();
		forEachInstance(Object, function(o) {
			if(isExcluded(o))
				return;
			if(o.sourceTextGroup == nil)
				return;
			if(_groups.isKeyPresent(o.sourceTextGroup) == nil)
				_groups[o.sourceTextGroup] = 0;
			_groups[o.sourceTextGroup] += 1;
		});
	}

	isExcluded(obj) {
		if(obj == nil)
			return(true);
		if(obj.sourceTextGroup == nil)
			return(true);
		return(excludeList.indexOf(obj.sourceTextGroup
			.sourceTextGroupName) != nil);
	}

	// Figure out the offset for each sourceTextGroup.  Each group
	// has a certain number of objects in it, but the compiler tags
	// them according to their order in their source file.  Here we're
	// just figuring out how to convert an object's order in its source
	// text group into a global order.
	createOffsets() {
		local n;

		_offsets = new LookupTable();
		n = 0;
		_groups.forEachAssoc(function(k, v) {
			_offsets[k] = n;
			n += v;
		});
	}

	// Go back through every object and assign an OID based on
	// its global order.
	// Note that the global order is arbitrary; we don't care about
	// ordering the source text group, all we care about is that
	// the OID is unique.
	traverseObjects() {
		forEachInstance(Object, function(o) {
			if(isExcluded(o))
				return;
			if((o.sourceTextOrder == nil)
				|| (o.sourceTextGroup == nil))
				return;
			o._oid = _offsets[o.sourceTextGroup]
				+ o.sourceTextOrder;
			if(o._oid > _counter) _counter = o._oid;
		});
		_counter += 1;
	}

	getSourceTextGroups(excl?) {
		local r;

		if(excl == nil)
			excl = [];
		r = new Vector();
		_offsets.forEachAssoc(function(k, v) {
			if(excl.indexOf(k.sourceTextGroupName) != nil)
				return;
			r.append(k.sourceTextGroupName);
		});

		return(r);
	}

	// Assign an OID to an object that doesn't already have one.
	// This will be used by objects created after preinit.
	// We just increment our global object counter and use its value
	// as the OID.
	_assignOID(obj) {
		if(obj == nil) return(nil);
		if(obj._oid == nil) {
			obj._oid = _counter;
			_counter += 1;
		}
		return(obj._oid);
	}

	// Assign a UID.  The UID is intended to be a unique human-readable tag
	// for the object.
	// The second arg is the "proposed" UID.  If that UID isn't already in
	// use, it will be used.  If the UID is already in use, then a unique
	// version based on the second arg will be created.
	_assignUID(obj, id?) {
		if(obj == nil)
			return(nil);

		// If the second arg is nil, we use a UID of the form obj#1234
		// where the numbers are the object's OID.
		// If the second arg is not nil we check to see if it's
		// already in use.  If it is, we use that id + the object's
		// OID.  If there's no conflict, we use the second arg
		// as the UID as-is.
		if(id == nil)
			id = 'obj#<<toString(obj._oid)>>';
		else if(_uidLookup.isKeyPresent(id))
			id = '<<id>>#<<toString(obj._oid)>>';

		obj._uid = id;

		// Remember the UID -> OID and OID -> UID mappings.
		_uidLookup[obj._uid] = obj;
		_oidLookup[obj._oid] = obj;

		return(obj._uid);
	}

	getUID(obj, id?) {
		if(obj._oid == nil)
			_assignOID(obj);
		if(obj._uid == nil)
			_assignUID(obj, id);

		return(obj._uid);
	}

	getObjByUID(v) {
		if(v == nil)
			return(nil);
		if(_uidLookup.isKeyPresent(v))
			return(_uidLookup[v]);

		_objectUIDSearch(v);
		return(_uidLookup[v]);
	}

	getObjByOID(v) {
		if(v == nil)
			return(nil);
		if(_oidLookup.isKeyPresent(v))
			return(_oidLookup[v]);

		_objectOIDSearch(v);
		return(_oidLookup[v]);
	}

	_objectSearch(fn) {
		local o;

		for(o = firstObj(Object, ObjAll); o != nil;
			o = nextObj(o, Object, ObjAll)) {
			if(fn(o) == true) {
				_uidLookup[o._uid] = o;
				_oidLookup[o._oid] = o;
				return(true);
			}
		}
		return(nil);
	}

	_objectUIDSearch(v) {
		return(_objectSearch(function(o) { return(o._uid == v); }));
	}

	_objectOIDSearch(v) {
		return(_objectSearch(function(o) { return(o._oid == v); }));
	}
;
