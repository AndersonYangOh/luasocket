/*=========================================================================*\
* LuaSocket toolkit
* Networking support for the Lua language
* Diego Nehab
* 26/11/1999
*
* This library is part of an  effort to progressively increase the network
* connectivity  of  the Lua  language.  The  Lua interface  to  networking
* functions follows the Sockets API  closely, trying to simplify all tasks
* involved in setting up both  client and server connections. The provided
* IO routines, however, follow the Lua  style, being very similar  to the
* standard Lua read and write functions.
*
* RCS ID: $Id$
\*=========================================================================*/

/*=========================================================================*\
* Standard include files
\*=========================================================================*/
#include <lua.h>
#include <lauxlib.h>

/*=========================================================================*\
* LuaSocket includes
\*=========================================================================*/
#include "luasocket.h"

#include "auxiliar.h"
#include "base.h"
#include "timeout.h"
#include "buffer.h"
#include "inet.h"
#include "tcp.h"
#include "udp.h"
#include "select.h"

/*-------------------------------------------------------------------------*\
* Modules
\*-------------------------------------------------------------------------*/
static const luaL_reg mod[] = {
    {"auxiliar", aux_open},
    {"base", base_open},
    {"timeout", tm_open},
    {"buffer", buf_open},
    {"inet", inet_open},
    {"tcp", tcp_open},
    {"udp", udp_open},
    {"select", select_open},
    {NULL, NULL}
};

/*-------------------------------------------------------------------------*\
* Initializes all library modules.
\*-------------------------------------------------------------------------*/
LUASOCKET_API int luaopen_socket(lua_State *L) {
    int i;
    for (i = 0; mod[i].name; i++) mod[i].func(L);
    return 1;
}
