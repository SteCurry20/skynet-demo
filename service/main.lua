local skynet = require "skynet"

skynet.error(function()
    skynet.error("[start main]")
    skynet.newservice("gateway", "gateway", 1)
    skynet.exit()
end)