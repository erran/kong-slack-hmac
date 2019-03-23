local typedefs = require "kong.db.schema.typedefs"

return {
  name = "slack-hmac",
  fields = {
    { consumer = typedefs.no_consumer },
    { run_on = typedefs.run_on_first },
    {
      config = {
        type = "record",
        fields = {
          { hide_credentials = { type = "boolean", default = false }, },
        },
      },
    },
  },
}
