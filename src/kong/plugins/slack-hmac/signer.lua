local openssl_hmac = require("openssl.hmac")
local sha256 = require("resty.sha256")
local to_hex = require("resty.string").to_hex

local encode_base64 = ngx.encode_base64

local Signer = {}

function Signer:hexdigest256(content)
  local digest = sha256:new()
  digest:update(content)
  return to_hex(digest:final())
end

-- request table:
--   body: The raw Slack request body.
--   secret: The Slack secret.
--   version: The Slack API version such as v0.
function Signer:sign(request, secret)
  local payload = 'v0:' .. request.timestamp .. ':' .. request.body
  local hmac_signature = openssl_hmac.new(secret, "sha256"):final(payload)
  return 'v0=' .. Signer:hexdigest256(hmac_signature)
end

return Signer
