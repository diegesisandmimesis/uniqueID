//
// uniqueID.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_UNIQUE_ID

#define guid(obj, id...) (uidManager.getUID(obj, id))
#define uid2obj(id) (uidManager.getObjByUID(id))
#define oid2obj(id) (uidManager.getObjByOID(id))

#define UNIQUE_ID_H
