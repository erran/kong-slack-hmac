# kong-slack-hmac
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
