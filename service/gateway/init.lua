---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Curry.
--- DateTime: 2022/2/19 15:14
---

local skynet = require "skynet"
skynet.error("end")
local s = require "service"

function s.init()
    skynet.error("[start]" .. s.name .. "" .. s.id)
end

skynet.error("end")
s.start(...)