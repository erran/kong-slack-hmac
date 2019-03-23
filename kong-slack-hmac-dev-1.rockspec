package = "kong-slack-hmac"
version = "dev-1"
rockspec_format = "3.0"

source = {
   url = "git+ssh://git@github.com/erran/kong-slack-hmac.git"
}

description = {
   detailed = [[
A Kong plugin for verifying requests from Slack.
]],
   homepage = "https://github.com/erran/kong-slack-hmac",
   license = "MIT"
}

build = {
   type = "builtin",
   modules = {
     ["kong.plugins.slack-hmac.handler"] = "src/handler.lua",
     ["kong.plugins.slack-hmac.signer"] = "src/signer.lua",
     ["kong.plugins.slack-hmac.schema"] = "src/schema.lua"
   }
}

dependencies = {
  "lua = 5.1"
}
