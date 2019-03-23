local kong = kong

local SIGNATURE_NOT_VALID = "HMAC signature cannot be verified"
local SIGNATURE_NOT_SAME = "HMAC signature does not match"

local function do_authentication(conf)
  local authorization = kong.request.get_header(AUTHORIZATION)

  -- If both headers are missing, return 401
  if not authorization then
    return false, { status = 401, message = "Unauthorized" }
  end

  -- validate clock skew
  if not (validate_clock_skew(X_DATE, conf.clock_skew) or
          validate_clock_skew(DATE, conf.clock_skew)) then
    return false, {
      status = 403,
      message = "HMAC signature cannot be verified, a valid date or " ..
                "x-date header is required for HMAC Authentication"
    }
  end

  hmac_params = retrieve_hmac_fields(authorization)
  if hmac_params and conf.hide_credentials then
    kong.service.request.clear_header(AUTHORIZATION)
  end

  local ok, err = validate_params(hmac_params, conf)
  if not ok then
    kong.log.debug(err)
    return false, { status = 403, message = SIGNATURE_NOT_VALID }
  end

  -- validate signature
  local credential = load_credential(hmac_params.username)
  if not credential then
    kong.log.debug("failed to retrieve credential for ", hmac_params.username)
    return false, { status = 403, message = SIGNATURE_NOT_VALID }
  end

  hmac_params.secret = credential.secret

  if not validate_signature(hmac_params) then
    return false, { status = 403, message = SIGNATURE_NOT_SAME }
  end

  -- If request body validation is enabled, then verify digest.
  if conf.validate_request_body and not validate_body() then
    kong.log.debug("digest validation failed")
    return false, { status = 403, message = SIGNATURE_NOT_SAME }
  end

  -- Retrieve consumer
  local consumer_cache_key, consumer
  consumer_cache_key = kong.db.consumers:cache_key(credential.consumer.id)
  consumer, err      = kong.cache:get(consumer_cache_key, nil,
                                      load_consumer_into_memory,
                                      credential.consumer.id)
  if err then
    kong.log.err(err)
    return kong.response.exit(500, { message = "An unexpected error occurred" })
  end

  set_consumer(consumer, credential)

  return true
end

local _M = {}

function _M.execute(conf)
  if conf.anonymous and kong.client.get_credential() then
    -- we're already authenticated, and we're configured for using anonymous,
    -- hence we're in a logical OR between auth methods and we're already done.
    return
  end

  local ok, err = do_authentication(conf)
  if not ok then
    if conf.anonymous then
      -- get anonymous user
      local consumer_cache_key = kong.db.consumers:cache_key(conf.anonymous)
      local consumer, err      = kong.cache:get(consumer_cache_key, nil,
                                                load_consumer_into_memory,
                                                conf.anonymous, true)
      if err then
        kong.log.err(err)
        return kong.response.exit(500, { message = "An unexpected error occurred" })
      end

      set_consumer(consumer, nil)

    else
      return kong.response.exit(err.status, { message = err.message }, err.headers)
    end
  end
end

return _M
