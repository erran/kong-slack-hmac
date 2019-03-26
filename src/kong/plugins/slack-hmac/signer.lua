local resty_hmac = require("resty.hmac")
local to_hex = require("resty.string").to_hex

local decode_base64 = ngx.decode_base64

local Signer = {}

local SIGNATURES_DID_NOT_MATCH_ERR = "Signature did not match expected."

function Signer:sign(request, secret)
  local payload = 'v0:' .. request.timestamp .. ':' .. request.body
  local hmac_signature, err = resty_hmac:new(secret):generate_signature("sha256", payload)
  if err then
    return nil, err
  end

  return 'v0=' .. to_hex(decode_base64(hmac_signature)), nil
end

function Signer:validate(request, secret)
  local payload = 'v0:' .. request.timestamp .. ':' .. request.body
  local expected = string.sub(request.signature, 4)
  local ok, err = resty_hmac:new(secret):check_signature("sha256", payload, nil, expected)
  if err then
    return nil, err
  elseif not ok then
    return nil, SIGNATURES_DID_NOT_MATCH_ERR
  end

  return true, nil
end

return Signer
