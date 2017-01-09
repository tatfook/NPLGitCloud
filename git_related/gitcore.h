#ifndef GITCORE_H_   
#define GITCORE_H_

/**
 * error code:
 * 0 OK
 * 100 Repo Not Found
 * 101 Branch Not Found
 * 
 *
 *
 **/
#include <string.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <git2.h>

struct tree_traversal_cb_data {
	int cb_times;
	lua_State *L;
};

#define checkError(errNum, errCode, L) if(errNum != 0) {lua_pushnumber(L, errCode); return 1;}
#define OK 0
#define RepoNotFound 100
#define BranchNotFound 101
#define FileNotFound 103
#define SignatureInvalid 104
#define TreeInsertFailure 105
#define IndexAddFailure 106
#define IndexReadTreeFailure 107

#endif