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
#include <lua5.1/lua.h>
#include <lua5.1/lauxlib.h>
#include <lua5.1/lualib.h>
#include <git2.h>

#include "INPLRuntimeState.h"
#include "NPLInterface.hpp"

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
#define InvalidCommand 108

int getContent(lua_State *L);
int repoInit(lua_State *L);
int updateFile(lua_State *L);
int addFile(lua_State *L);
int deleteFile(lua_State *L);
int deleteRepo(lua_State *L);
int traverseTree(lua_State *L);

#endif