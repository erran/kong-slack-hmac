local Access = require("kong.plugins.slack-hmac.access")
local Handler = require("kong.plugins.base_plugin"):extend()

function Handler:new()
  Handler.super.new(self, "slack-hmac")
end

function Handler:access(conf)
  Handler.super.access(self)
  Access.execute(conf)
end


Handler.PRIORITY = 1000
Handler.VERSION = "0.1.0"

return Handler
