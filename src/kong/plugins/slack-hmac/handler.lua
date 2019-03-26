local Handler = require("kong.plugins.base_plugin"):extend()
local Signer = require("kong.plugins.slack-hmac.signer")

function Handler:new()
  Handler.super.new(self, "slack-hmac")
end

function Handler:access(conf)
  Handler.super.access(self)

  local ok, err = Signer.validate({
    body = kong.request.get_raw_body(),
    signature = kong.request.get_header("X-Slack-Signature"),
    timestamp = kong.request.get_header("X-Slack-Request-Timestamp"),
  }, conf.secret)

  if not ok then
    return kong.response.exit(400, { message = "Request failed signature verification." })
  elseif err then
    return kong.response.exit(400, { message = "Request failed signature verification." })
  end
end


Handler.PRIORITY = 1000
Handler.VERSION = "0.1.0"

return Handler
