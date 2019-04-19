# kong-slack-hmac
![erran/kong-slack-hmac luarocks badge][] ![tested with badge][]

**Tested with Kong v0.12.3.**

A [Kong][] plugin for [verifying requests from Slack][].

## Development
The following can be used to setup your environment on Mac:
```sh
brew install openresty
```

1. Follow the steps at [OpenResty's Using LuaRocks guide](https://openresty.org/en/using-luarocks.html) to setup LuaRocks with Resty.
2. Place the LuaRocks bin from resty in your PATH.
3. Install Lua dependencies:
    ```
    luarocks-5.1 install busted
    ```

[Kong]: https://konghq.com/kong/
[verifying requests from Slack]: https://api.slack.com/docs/verifying-requests-from-slack
[erran/kong-slack-hmac luarocks badge]: https://img.shields.io/luarocks/v/erran/kong-slack-hmac/0.12.3-0.svg
[tested with badge]: https://img.shields.io/badge/kong-v0.12.3-9cf.svg
