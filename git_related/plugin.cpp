#include <lua5.1/lua.hpp>
#include <lua5.1/lauxlib.h>
#include <lua5.1/lualib.h>

#include "gitcore.h"
#include "plugin.h"

#ifdef WIN32
#define CORE_EXPORT_DECL    __declspec(dllexport)
#else
#define CORE_EXPORT_DECL
#endif

// forward declare of exported functions. 
#ifdef __cplusplus
extern "C" {
#endif
	CORE_EXPORT_DECL const char* LibDescription();
	CORE_EXPORT_DECL int LibNumberClasses();
	CORE_EXPORT_DECL unsigned long LibVersion();
	CORE_EXPORT_DECL ParaEngine::ClassDescriptor* LibClassDesc(int i);
	CORE_EXPORT_DECL void LibInit();
	CORE_EXPORT_DECL void LibActivate(int nType, void* pVoid);
#ifdef __cplusplus
}   /* extern "C" */
#endif
 
HINSTANCE Instance = NULL;

using namespace ParaEngine;

ClassDescriptor* GitcorePlugin_GetClassDesc();
typedef ClassDescriptor* (*GetClassDescMethod)();

GetClassDescMethod Plugins[] = 
{
	GitcorePlugin_GetClassDesc,
};

/** This has to be unique, change this id for each new plugin.
*/
#define Gitcore_CLASS_ID Class_ID(0x8d613d70, 0xdf155872)

class GitcorePluginDesc:public ClassDescriptor
{
public:
	void* Create(bool loading = FALSE)
	{
		return new GitcoreMain();
	}

	const char* ClassName()
	{
		return "GitcoreMain";
	}

	SClass_ID SuperClassID()
	{
		return OBJECT_MODIFIER_CLASS_ID;
	}

	Class_ID ClassID()
	{
		return Gitcore_CLASS_ID;
	}

	const char* Category() 
	{ 
		return "Gitcore"; 
	}

	const char* InternalName() 
	{ 
		return "Gitcore"; 
	}

	HINSTANCE HInstance() 
	{ 
		extern HINSTANCE Instance;
		return Instance; 
	}
};

ClassDescriptor* GitcorePlugin_GetClassDesc()
{
	static GitcorePluginDesc s_desc;
	return &s_desc;
}

CORE_EXPORT_DECL const char* LibDescription()
{
	return "Gitcore Plugin Ver 1.0.0";
}

CORE_EXPORT_DECL unsigned long LibVersion()
{
	return 1;
}

CORE_EXPORT_DECL int LibNumberClasses()
{
	return sizeof(Plugins)/sizeof(Plugins[0]);
}

CORE_EXPORT_DECL ClassDescriptor* LibClassDesc(int i)
{
	if (i < LibNumberClasses() && Plugins[i])
	{
		return Plugins[i]();
	}
	else
	{
		return NULL;
	}
}

CORE_EXPORT_DECL void LibInit()
{
}

#ifdef WIN32
BOOL WINAPI DllMain(HINSTANCE hinstDLL,ULONG fdwReason,LPVOID lpvReserved)
#else
void __attribute__ ((constructor)) DllMain()
#endif
{
	// TODO: dll start up code here
#ifdef WIN32
	Instance = hinstDLL;				// Hang on to this DLL's instance handle.
	return (TRUE);
#endif
}

/**
 * Activate Entrance
 * How to call:
 * 		the argument must be arrange as 
 *		{callback="/path/to/callback/handler", cmd="command e.g. getContent",
 *		payload=argument_array(sequence the same with gitcore.cpp)}
 *
 *
 */
CORE_EXPORT_DECL void LibActivate(int nType, void* pVoid)
{
    if(nType == ParaEngine::PluginActType_STATE)
    {
        NPL::INPLRuntimeState* pState = (NPL::INPLRuntimeState*)pVoid;
        const char* sMsg = pState->GetCurrentMsg();
        int nMsgLength = pState->GetCurrentMsgLength();

        NPLInterface::NPLObjectProxy input_msg = NPLInterface::NPLHelper::MsgStringToNPLTable(sMsg);
        const std::string& callback = input_msg["callback"];
        const std::string& cmd = input_msg["git_cmd"];

        NPLInterface::NPLObjectProxy payload = input_msg["payload"];

        NPLInterface::NPLObjectProxy output_msg;
        lua_State *L = luaL_newstate();

        if(cmd == "getContent"){
        	lua_pushstring(L, ((std::string)payload[1]).c_str());
        	lua_pushstring(L, ((std::string)payload[2]).c_str());
        	lua_pushstring(L, ((std::string)payload[3]).c_str());

        	int numArg = 3;
        	int numRet = getContent(L);

        	output_msg[1] = luaL_checknumber(L, numArg+1);
        	for(int i = 2; i <= numRet; i++){
        		output_msg[i] = luaL_checkstring(L, numArg+i);
        	}
        }
        else if(cmd == "repoInit"){
        	lua_pushstring(L, ((std::string)payload[1]).c_str());
        	lua_pushnumber(L, (int)payload[2]);

        	int numArg = 2;
        	int numRet = getContent(L);

        	output_msg[1] = luaL_checknumber(L, numArg+1);
        	for(int i = 2; i <= numRet; i++){
        		output_msg[i] = luaL_checkstring(L, numArg+i);
        	}
        }
        else if(cmd == "updateFile"){
        	lua_pushstring(L, ((std::string)payload[1]).c_str());
        	lua_pushstring(L, ((std::string)payload[2]).c_str());
        	lua_pushstring(L, ((std::string)payload[3]).c_str());
        	lua_pushstring(L, ((std::string)payload[4]).c_str());
        	lua_pushstring(L, ((std::string)payload[5]).c_str());
        	lua_pushstring(L, ((std::string)payload[6]).c_str());
        	lua_pushstring(L, ((std::string)payload[7]).c_str());

        	int numArg = 7;
        	int numRet = getContent(L);

        	output_msg[1] = luaL_checknumber(L, numArg+1);
        	for(int i = 2; i <= numRet; i++){
        		output_msg[i] = luaL_checkstring(L, numArg+i);
        	}
        }
        else if(cmd == "addFile"){
        	lua_pushstring(L, ((std::string)payload[1]).c_str());
        	lua_pushstring(L, ((std::string)payload[2]).c_str());
        	lua_pushstring(L, ((std::string)payload[3]).c_str());
        	lua_pushstring(L, ((std::string)payload[4]).c_str());
        	lua_pushstring(L, ((std::string)payload[5]).c_str());
        	lua_pushstring(L, ((std::string)payload[6]).c_str());
        	lua_pushstring(L, ((std::string)payload[7]).c_str());

        	int numArg = 7;
        	int numRet = getContent(L);

        	output_msg[1] = luaL_checknumber(L, numArg+1);
        	for(int i = 2; i <= numRet; i++){
        		output_msg[i] = luaL_checkstring(L, numArg+i);
        	}
        }
        else if(cmd == "deleteFile"){
        	lua_pushstring(L, ((std::string)payload[1]).c_str());
        	lua_pushstring(L, ((std::string)payload[2]).c_str());
        	lua_pushstring(L, ((std::string)payload[3]).c_str());
        	lua_pushstring(L, ((std::string)payload[4]).c_str());
        	lua_pushstring(L, ((std::string)payload[5]).c_str());

        	int numArg = 5;
        	int numRet = getContent(L);

        	output_msg[1] = luaL_checknumber(L, numArg+1);
        	for(int i = 2; i <= numRet; i++){
        		output_msg[i] = luaL_checkstring(L, numArg+i);
        	}
        }
        else if(cmd == "deleteRepo"){
        	lua_pushstring(L, ((std::string)payload[1]).c_str());

        	int numArg = 1;
        	int numRet = getContent(L);

        	output_msg[1] = luaL_checknumber(L, numArg+1);
        	for(int i = 2; i <= numRet; i++){
        		output_msg[i] = luaL_checkstring(L, numArg+i);
        	}
        }
        else if(cmd == "traverseTree"){
        	lua_pushstring(L, ((std::string)payload[1]).c_str());
        	lua_pushstring(L, ((std::string)payload[2]).c_str());

        	int numArg = 2;
        	int numRet = getContent(L);

        	output_msg[1] = luaL_checknumber(L, numArg+1);
        	for(int i = 2; i <= numRet; i++){
        		output_msg[i] = luaL_checkstring(L, numArg+i);
        	}
        }
        else{
        	lua_close(L);
        	L = luaL_newstate();
        	lua_pushnumber(L, InvalidCommand);
        	output_msg[1] = luaL_checknumber(L, 1);
        }

        lua_close(L);

        output_msg["cmd"] = "callback";
        output_msg["original_cmd"] = "git_cmd";
        std::string output;
        NPLInterface::NPLHelper::NPLTableToString("msg", output_msg, output);
        pState->activate(callback.c_str(), output.c_str(), output.size());
    }
}
