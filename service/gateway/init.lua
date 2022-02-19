---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Curry.
--- DateTime: 2022/2/19 15:14
---

local skynet = require "skynet"
local s = require "service"
local runconfig = require "runconfig"
local socket = require "skynet.socket"

conns = {} --[fd]=conn
players = {} -- [playerid] = gateplayer

function s.init()
    local node = skynet.getenv("node")
    local nodecfg = runconfig[node]
    local port = nodecfg.gateway[s.id].port
    local listenfd = socket.listen("0.0.0.0", port)
    skynet.error("listen socket:", "0.0.0.0", port)
    socket.start(listenfd, function(fd, addr)
        print("connect from " .. addr .. " " .. fd)
        local c = conn()
        conns[fd] = c
        skynet.fork(recv_loop, fd)
    end
    )
end

-- 每一条连接接收数据处理
-- 协议格式 cmd,arg1,arg2,...#
local recv_loop = function(fd)
    socket.start(fd)
    skynet.error("socket: connect" .. fd)
    local readbuff = ""
    while true do
        local recvstr = socket.read(fd)
        if recvstr then
            readbuff = readbuff .. recvstr
            readbuff = process_buff(fd, readbuff)
        else
            skynet.error("socket close" .. fd)
            disconnect(fd)
            socket.close(fd)
            return
        end
    end
end

local process_buff = function(fd, readbuff)
    while true do
        local msgstr, rest = string.match(readbuff, "(.-)\r\n(.*)")
        if msgstr then
            readbuff = rest
            process_buff(fd, msgstr)
        end
        return readbuff
    end
end

-- 连接类
function conn()
    local m = {
        fd = nil,
        playerid = nil,
    }
    return m
end

--玩家类
function gateplayer()
    local m = {
        playerid = nil,
        agent = nil,
        conn = nil
    }
    return m
end

local str_unpack = function(msgstr)
    local msg = {}
    while true do
        local arg, rest = string.match(msgstr, "(.-),(.*)")
        if arg then
            msgstr = rest
            table.insert(msg, msgstr)
        else
            table.insert(msg, msgstr)
            break
        end
    end
    return msg[1], msg
end

local str_pack = function(cmd, msg)
    return table.concat(msg, ",") .. "\r\n"

end

local process_msg = function(fd, msgstr)
    local cmd, msg = str_unpack(msgstr)
    skynet.error("recv " .. fd .. " [" .. cmd .. "[ }" .. table.concat(msg, ",") .. "}")
    local conn = conns[fd]
    local playerid = conn.playerid
    --尚未完成登录流程
    if not playerid then
        local node = skynet.getenv("node")
        local nodecfg = runconfig[node]
        local loginid = math.random(1, #nodecfg.login)
        skynet.send(login, "lua", "client", fd, cmd, msg)
        --完成登录流程
    else
        local gplayer = players[playerid]
        local agent = gplayer.agent
        skynet.send(agent, "lua", "client", cmd, msg)
    end
end

s.start(...)