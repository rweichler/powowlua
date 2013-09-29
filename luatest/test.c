#include <lua.h>
#include <stdio.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdlib.h>

#include <dirent.h>
#include <errno.h>
#include <string.h>

#define true 1
#define false 0

void error(lua_State *L, const char *fmt, ...)
{
    va_list argp;
    va_start(argp, fmt);
    vfprintf(stderr, fmt, argp);
    va_end(argp);
    lua_close(L);
    exit(EXIT_FAILURE);
}

static int l_dir(lua_State *L)
{
    DIR *dir;
    struct dirent *entry;
    int i;
    const char *path = luaL_checkstring(L, 1);

    //open directory
    dir = opendir(path);
    if(dir == NULL) //error opening the dir
    {
        lua_pushnil(L); //return nil
        lua_pushstring(L, strerror(errno)); //and error message
        return 2; //number of results
    }

    //create result table
    lua_newtable(L);
    i = 1;
    while((entry = readdir(dir)) != NULL)
    {
        lua_pushnumber(L, i++); //push key
        lua_pushstring(L, entry->d_name); //push value
        lua_settable(L, -3);
    }

    closedir(dir);

    return 1; //table is already on top
}

int main(int argc, char **argv)
{
    const char *filename = argc > 1? argv[1] : "test.lua";
    double num = argc > 2? atof(argv[2]) : 5;

    lua_State *L = luaL_newstate(); //opens lua
    luaL_openlibs(L); //opens standard libs

    //load file
    if(luaL_loadfile(L, filename) || lua_pcall(L, 0, 0, 0))
    {
        error(L, "Lol couldnt open file %s: %s\n", filename, lua_tostring(L, -1));
    }

    lua_pushcfunction(L, l_dir);
    lua_setglobal(L, "dir");

    lua_getglobal(L, "f");
    lua_pushnumber(L, num);
    if(lua_pcall(L, 1, 1, 0) != LUA_OK)
        error(L, "error running function 'f': %s\n", lua_tostring(L, -1));

    const char *result = lua_tostring(L, -1);

    lua_pop(L, 1);

    printf("%s\n", result);

    lua_close(L);
    return 0;
}
