local resty_hmac = require("resty.hmac")
local to_hex = require("resty.string").to_hex

local decode_base64 = ngx.decode_base64

local Signer = {}

-- request table:
--   body: The raw Slack request body.
--   secret: The Slack secret.
--   version: The Slack API version such as v0.
function Signer:sign(request, secret)
  local payload = 'v0:' .. request.timestamp .. ':' .. request.body
  local hmac_signature, err = resty_hmac:new(secret):generate_signature("sha256", payload)
  if err then
    return nil, err
  end

  return 'v0=' .. to_hex(decode_base64(hmac_signature)), nil
end

return Signer
