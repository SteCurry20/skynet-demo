local skynet=require "skynet"
local runconfig=require "runconfig"
skynet.start(
        function()
            skynet.error(runconfig.agentmgr.node)
            skynet.exit()
        end
)