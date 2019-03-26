local Handler = require("kong.plugins.base_plugin"):extend()
local Signer = require("kong.plugins.slack-hmac.signer")
local responses = require("kong.tools.responses")

local X_SLACK_REQUEST_TIMESTAMP = "X-Slack-Request-Timestamp"
local X_SLACK_SIGNATURE = "X-Slack-Signature"

local function get_header(header_name)
  local header = ngx.req.get_headers()[header_name]
  if type(header) == "table" then
    return header[#header]
  end

  return header
end

function Handler:new()
  Handler.super.new(self, "slack-hmac")
end

function Handler:access(conf)
  Handler.super.access(self)

  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  if not body then
    return responses.send_HTTP_METHOD_NOT_ALLOWED()
  end

  local signature = get_header(X_SLACK_SIGNATURE)
  local timestamp = get_header(X_SLACK_REQUEST_TIMESTAMP)
  if not timestamp or not signature then
    return responses.send_HTTP_BAD_REQUEST("Missing required Slack headers.")
  end

  local ok, err = Signer:validate({
    body = body,
    signature = signature,
    timestamp = timestamp,
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
