-----------------------------------------------------------------------------
-- Unified SMTP/FTP subsystem
-- LuaSocket toolkit.
-- Author: Diego Nehab
-- Conforming to: RFC 2616, LTN7
-- RCS ID: $Id$
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Load other required modules
-----------------------------------------------------------------------------
local socket = require("socket")

-----------------------------------------------------------------------------
-- Setup namespace
-----------------------------------------------------------------------------
tp = {}
setmetatable(tp, { __index = _G })
setfenv(1, tp)

TIMEOUT = 60

-- gets server reply (works for SMTP and FTP)
local function get_reply(control)
    local code, current, sep
    local line, err = control:receive()
    local reply = line
    if err then return nil, err end
    code, sep = socket.skip(2, string.find(line, "^(%d%d%d)(.?)"))
    if not code then return nil, "invalid server reply" end
    if sep == "-" then -- reply is multiline
        repeat
            line, err = control:receive()
            if err then return nil, err end
            current, sep = socket.skip(2, string.find(line, "^(%d%d%d)(.?)"))
            reply = reply .. "\n" .. line
        -- reply ends with same code
        until code == current and sep == " " 
    end
print(reply)
    return code, reply
end

-- metatable for sock object
local metat = { __index = {} }

function metat.__index:check(ok)
    local code, reply = get_reply(self.control)
    if not code then return nil, reply end
    if type(ok) ~= "function" then
        if type(ok) == "table" then 
            for i, v in ipairs(ok) do
                if string.find(code, v) then return tonumber(code), reply end
            end
            return nil, reply
        else
            if string.find(code, ok) then return tonumber(code), reply 
            else return nil, reply end
        end
    else return ok(tonumber(code), reply) end
end

function metat.__index:command(cmd, arg)
print(cmd, arg)
    if arg then return self.control:send(cmd .. " " .. arg.. "\r\n")
    else return self.control:send(cmd .. "\r\n") end
end

function metat.__index:sink(snk, pat)
    local chunk, err = control:receive(pat)
    return snk(chunk, err)
end

function metat.__index:send(data)
    return self.control:send(data)
end

function metat.__index:receive(pat)
    return self.control:receive(pat)
end

function metat.__index:getfd()
    return self.control:getfd()
end

function metat.__index:dirty()
    return self.control:dirty()
end

function metat.__index:getcontrol()
    return self.control
end

function metat.__index:source(source, step)
    local sink = socket.sink("keep-open", self.control)
    return ltn12.pump.all(source, sink, step or ltn12.pump.step)
end

-- closes the underlying control
function metat.__index:close()
    self.control:close()
	return 1
end

-- connect with server and return control object
function connect(host, port)
    local control, err = socket.connect(host, port)
    if not control then return nil, err end
    control:settimeout(TIMEOUT)
    return setmetatable({control = control}, metat)
end

return tp
