local Handler = require("kong.plugins.base_plugin"):extend()
local Signer = require("kong.plugins.slack-hmac.signer")

local X_SLACK_SIGNATURE = "X-Slack-Signature"
local X_SLACK_REQUEST_TIMESTAMP = "X-Slack-Request-Timestamp"

function Handler:new()
  Handler.super.new(self, "slack-hmac")
end

function Handler:access(conf)
  Handler.super.access(self)

  local headers = ngx.req.get_headers()
  local ok, err = Signer.validate({
    body = kong.request.get_raw_body(),
    signature = headers[X_SLACK_SIGNATURE] or "",
    timestamp = headers[X_SLACK_REQUEST_TIMESTAMP] or "",
  }, conf.secret)

  if not ok then
    return responses.send_HTTP_BAD_REQUEST("Request failed signature verification.")
  elseif err then
    ngx.log(ngx.ERR, "[slack-hmac]: Failed to verify signature due to error: "..err)
    return responses.send_HTTP_BAD_REQUEST("Request failed signature verification due to an unexpected error.")
  end

  if conf.hide_credentials then
    ngx.req.clear_header(X_SLACK_SIGNATURE)
  end
end


Handler.PRIORITY = 1000
Handler.VERSION = "0.1.0"

return Handler
