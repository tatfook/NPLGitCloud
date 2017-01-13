#include <string.h>
#include <time.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <git2.h>

#include "gitcore.h"
#include "util.h"




/**
 * param: repo name, file path
 * return: error code, content string
 *
 **/
static int getContent(lua_State* L){
	const char* repoStr = luaL_checkstring(L,1);
	const char* branchStr = luaL_checkstring(L, 2);
    const char* pathStr = luaL_checkstring(L,3);

    git_repository* repo;
    git_blob *file_blob;
    git_object *file_obj;
    git_tree_entry *file_entry;
    git_commit *commit;
    git_object *commit_obj;
    git_tree *commit_tree;

    git_libgit2_init();

    checkError(git_repository_open(&repo, repoStr), RepoNotFound, L);
   	checkError(git_revparse_single(&commit_obj, repo, branchStr), BranchNotFound, L);
   	git_commit_lookup(&commit, repo, git_object_id(commit_obj));
   	git_commit_tree(&commit_tree, commit);
   	checkError(git_tree_entry_bypath(&file_entry, commit_tree, pathStr), FileNotFound, L);
   	git_tree_entry_to_object(&file_obj, repo, file_entry);
    git_blob_lookup(&file_blob, repo, git_object_id(file_obj));
    const void* content_pointer = git_blob_rawcontent(file_blob);
    unsigned long content_length = (unsigned long)git_blob_rawsize(file_blob);

    char file_content[content_length+1];
    memset(file_content, 0, content_length+1);
    memcpy(file_content, content_pointer, content_length);

    git_blob_free(file_blob);
    git_object_free(file_obj);
    git_object_free(commit_obj);
    git_commit_free(commit);
    git_tree_free(commit_tree);
    git_repository_free(repo);

    git_libgit2_shutdown();

    lua_pushnumber(L, OK);
    lua_pushstring(L, file_content);
    return 2;
}


/**
 * param: repo name, isBare
 * return: error code
 *
 **/
static int repoInit(lua_State* L){
	const char* repoStr = luaL_checkstring(L, 1);
	unsigned int isBare = luaL_checknumber(L, 2);

	git_repository *repo;
	git_libgit2_init();

	git_repository_init(&repo, repoStr, isBare);
	git_repository_free(repo);

	git_libgit2_shutdown();

	lua_pushnumber(L, OK);
	return 1;
}

/**
 * param: repo, path, commit msg, branch name, original sha, content length, content
 * return: error code
 *
 **/
static int updateFile(lua_State* L){
	const char* repoStr = luaL_checkstring(L, 1);
	const char* pathStr = luaL_checkstring(L, 2);
	const char* commitMsg = luaL_checkstring(L, 3);
	const char* branchStr = luaL_checkstring(L, 4);
	//const char* sha = luaL_checkstring(L, 5);
	const unsigned long contentLength = luaL_checknumber(L, 6);
	const char* content = luaL_checkstring(L, 7);

	git_repository* repo;
	git_object *curr_commit_obj;
	git_commit *curr_commit;
	git_tree *curr_tree;
	git_tree *new_tree;
	git_oid new_tree_id;
	git_oid new_commit_id;
	git_signature *author;
	git_index *curr_index;
	const git_index_entry *curr_file_index;

	git_libgit2_init();

	checkError(git_repository_open(&repo, repoStr), RepoNotFound, L);
   	checkError(git_revparse_single(&curr_commit_obj, repo, branchStr), BranchNotFound, L);
   	git_commit_lookup(&curr_commit, repo, git_object_id(curr_commit_obj));
   	git_commit_tree(&curr_tree, curr_commit);

   	git_repository_index(&curr_index, repo);
   	checkError(git_index_read_tree(curr_index, curr_tree), IndexReadTreeFailure, L);
   	curr_file_index = git_index_get_bypath(curr_index, pathStr, 0);
    if(curr_file_index == NULL){
        lua_pushnumber(L, FileNotFound);
        return 1;
    }
   	checkError(git_index_add_frombuffer(curr_index, curr_file_index, content, contentLength), IndexAddFailure, L);
   	git_index_write_tree(&new_tree_id, curr_index);

   	checkError(git_signature_now(&author, "API", "yli@y-l.me"), SignatureInvalid, L);
   	git_tree_lookup(&new_tree, repo, &new_tree_id);

   	const git_commit *parent[] = {curr_commit};
   	git_commit_create(&new_commit_id, repo, "HEAD", author, author, "UTF-8", commitMsg, new_tree, 1, parent);

    git_object_free(curr_commit_obj);
    git_commit_free(curr_commit);
    git_tree_free(curr_tree);
    git_tree_free(new_tree);
    git_index_free(curr_index);
    git_repository_free(repo);

	git_libgit2_shutdown();

	lua_pushnumber(L, OK);
	return 1;
}

/**
 * param: repo, path, commit msg, branch name, original sha, content length, content
 * return: error code
 *
 **/
//Unresolved Problem: when the bare git repo is empty
static int addFile(lua_State* L){
    const char* repoStr = luaL_checkstring(L, 1);
    const char* pathStr = luaL_checkstring(L, 2);
    const char* commitMsg = luaL_checkstring(L, 3);
    const char* branchStr = luaL_checkstring(L, 4);
    //const char* sha = luaL_checkstring(L, 5);
    const unsigned long contentLength = luaL_checknumber(L, 6);
    const char* content = luaL_checkstring(L, 7);

    git_repository* repo;
    git_object *curr_commit_obj;
    git_commit *curr_commit;
    git_tree *curr_tree;
    git_tree *new_tree;
    git_oid new_tree_id;
    git_oid new_commit_id;
    git_signature *author;
    git_index *curr_index;
    git_index_entry *curr_file_index;

    git_libgit2_init();

    checkError(git_repository_open(&repo, repoStr), RepoNotFound, L);
    if(git_revparse_single(&curr_commit_obj, repo, branchStr) == OK){
        git_commit_lookup(&curr_commit, repo, git_object_id(curr_commit_obj));
        git_commit_tree(&curr_tree, curr_commit);

        git_repository_index(&curr_index, repo);
        checkError(git_index_read_tree(curr_index, curr_tree), IndexReadTreeFailure, L);
        curr_file_index = (git_index_entry *)malloc(sizeof(git_index_entry));
        curr_file_index -> mode = GIT_FILEMODE_BLOB;
        curr_file_index -> path = pathStr;
        checkError(git_index_add_frombuffer(curr_index, curr_file_index, content, contentLength), IndexAddFailure, L);
        git_index_write_tree(&new_tree_id, curr_index);

        checkError(git_signature_now(&author, "API", "yli@y-l.me"), SignatureInvalid, L);
        git_tree_lookup(&new_tree, repo, &new_tree_id);

        const git_commit *parent[] = {curr_commit};
        git_commit_create(&new_commit_id, repo, "HEAD", author, author, "UTF-8", commitMsg, new_tree, 1, parent);

        git_object_free(curr_commit_obj);
        git_commit_free(curr_commit);
        git_tree_free(curr_tree);
        git_tree_free(new_tree);
        git_index_free(curr_index);
        git_repository_free(repo);
    }
    else{
        git_repository_index(&curr_index, repo);
        curr_file_index = (git_index_entry *)malloc(sizeof(git_index_entry));
        curr_file_index -> mode = GIT_FILEMODE_BLOB;
        curr_file_index -> path = pathStr;
        checkError(git_index_add_frombuffer(curr_index, curr_file_index, content, contentLength), IndexAddFailure, L);
        git_index_write_tree(&new_tree_id, curr_index);

        checkError(git_signature_now(&author, "API", "yli@y-l.me"), SignatureInvalid, L);
        git_tree_lookup(&new_tree, repo, &new_tree_id);

        git_commit_create(&new_commit_id, repo, "HEAD", author, author, "UTF-8", commitMsg, new_tree, 0, NULL);

        git_object_free(curr_commit_obj);
        git_tree_free(new_tree);
        git_index_free(curr_index);
        git_repository_free(repo);
    }

    git_libgit2_shutdown();

    lua_pushnumber(L, OK);
    return 1;

}

/**
 * param: repo, path, commit msg, branch name, original sha
 * return: error code
 *
 **/
static int deleteFile(lua_State *L){
    const char* repoStr = luaL_checkstring(L, 1);
    const char* pathStr = luaL_checkstring(L, 2);
    const char* commitMsg = luaL_checkstring(L, 3);
    const char* branchStr = luaL_checkstring(L, 4);
    //const char* sha = luaL_checkstring(L, 5);

    git_repository* repo;
    git_object *curr_commit_obj;
    git_commit *curr_commit;
    git_tree *curr_tree;
    git_tree *new_tree;
    git_oid new_tree_id;
    git_oid new_commit_id;
    git_signature *author;
    git_index *curr_index;

    git_libgit2_init();

    checkError(git_repository_open(&repo, repoStr), RepoNotFound, L);
    checkError(git_revparse_single(&curr_commit_obj, repo, branchStr), BranchNotFound, L);
    git_commit_lookup(&curr_commit, repo, git_object_id(curr_commit_obj));
    git_commit_tree(&curr_tree, curr_commit);

    git_repository_index(&curr_index, repo);
    checkError(git_index_read_tree(curr_index, curr_tree), IndexReadTreeFailure, L);
    
    checkError(git_index_remove(curr_index, pathStr, 0), FileNotFound, L);
    git_index_write_tree(&new_tree_id, curr_index);

    checkError(git_signature_now(&author, "API", "yli@y-l.me"), SignatureInvalid, L);
    git_tree_lookup(&new_tree, repo, &new_tree_id);

    const git_commit *parent[] = {curr_commit};
    git_commit_create(&new_commit_id, repo, "HEAD", author, author, "UTF-8", commitMsg, new_tree, 1, parent);

    git_object_free(curr_commit_obj);
    git_commit_free(curr_commit);
    git_tree_free(curr_tree);
    git_tree_free(new_tree);
    git_index_free(curr_index);
    git_repository_free(repo);

    git_libgit2_shutdown();

    lua_pushnumber(L, OK);
    return 1;
}

/**
 * param: repo
 * return: error code
 *
 **/
static int deleteRepo(lua_State *L){
    const char* repoStr = luaL_checkstring(L, 1);

    git_repository* repo;

    git_libgit2_init();
    checkError(git_repository_open(&repo, repoStr), RepoNotFound, L);
    git_repository_free(repo);
    git_libgit2_shutdown();

    char cmd[512] = "rm -rf ";
    strncat(cmd, repoStr, 500);
    popen(cmd, "r");
    lua_pushnumber(L, OK);
    return 1;
}

/**
 * tree traverse callback
 *
 **/
int tree_walk_cb(const char *root, const git_tree_entry *entry, void *payload){
    struct tree_traversal_cb_data* cb_data = (struct tree_traversal_cb_data *)payload;
    cb_data -> cb_times++;
    const char* filename = git_tree_entry_name(entry);
    //char* path_buffer = (char *)malloc(strlen(root)+strlen(filename)+1);
    char path_buffer[strlen(root)+strlen(filename)+1];
    memset(path_buffer, 0, strlen(root)+strlen(filename)+1);
    memcpy(path_buffer, root, strlen(root));
    strncat(path_buffer, filename, strlen(filename));
    lua_pushstring(cb_data -> L, path_buffer);
    //free(path_buffer);
    lua_pushnumber(cb_data -> L, git_tree_entry_filemode(entry));

    char oid_hex_string[41];
    memset(oid_hex_string, 0, sizeof(oid_hex_string));
    buffer2hexstring(git_tree_entry_id(entry)->id, 20, oid_hex_string);
    lua_pushstring(cb_data -> L, oid_hex_string);

    return 0;
}

/**
 * param: repo, tree spec
 * return: error code, tree oid, entry1 path, entry1 filemode, entry1 oid, entry2 ...
 *
 **/
static int traverseTree(lua_State *L){
    const char* repoStr = luaL_checkstring(L, 1);
    const char* tree_spec = luaL_checkstring(L, 2);

    git_repository* repo;
    git_object* spec_obj;
    git_commit* curr_commit;
    git_tree* curr_tree;

    git_libgit2_init();
    checkError(git_repository_open(&repo, repoStr), RepoNotFound, L);
    checkError(git_revparse_single(&spec_obj, repo, tree_spec), BranchNotFound, L);
    switch(git_object_type(spec_obj)){
        case GIT_OBJ_COMMIT:
            git_commit_lookup(&curr_commit, repo, git_object_id(spec_obj));
            git_commit_tree(&curr_tree, curr_commit);
            break;
        default:
            git_commit_lookup(&curr_commit, repo, git_object_id(spec_obj));
            git_commit_tree(&curr_tree, curr_commit);
            break;
    }

    lua_pushnumber(L, OK);

    char oid_hex_string[41];
    memset(oid_hex_string, 0, sizeof(oid_hex_string));
    buffer2hexstring(git_tree_id(curr_tree)->id, 20, oid_hex_string);
    lua_pushstring(L, oid_hex_string);

    struct tree_traversal_cb_data cb_data;
    cb_data.cb_times = 0;
    cb_data.L = L;
    git_tree_walk(curr_tree, GIT_TREEWALK_PRE, tree_walk_cb, (void *)&cb_data);

    git_tree_free(curr_tree);
    git_object_free(spec_obj);
    git_repository_free(repo);
    git_libgit2_shutdown();

    return cb_data.cb_times * 3+2;
}



int luaopen_gitcore (lua_State *L) {

    lua_register(L, "getContent", getContent);
    lua_register(L, "repoInit", repoInit);
    lua_register(L, "updateFile", updateFile);
    lua_register(L, "addFile", addFile);
    lua_register(L, "deleteFile", deleteFile);
    lua_register(L, "deleteRepo", deleteRepo);
    lua_register(L, "traverseTree", traverseTree);
    return 1;
}

