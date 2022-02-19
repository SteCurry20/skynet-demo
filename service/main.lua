local skynet = require "skynet"
local s = require "service"

skynet.error(function()
    skynet.error("[start main]")
    skynet.newservice("gateway", "gateway", 1)
    skynet.exit()
end)