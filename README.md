# kong-slack-hmac
A [Kong][] plugin for [verifying requests from Slack][].

## Development
The following can be used to setup your environment on Mac:
```sh
brew install openresty
```

Lua dependencies:
```
luarocks-5.1 install busted
#luarocks-5.1 install luaossl CRYPTO_INCDIR=/usr/local/opt/openssl/include/ OPENSSL_DIR=/usr/local/opt/openssl/
```

[Kong]: https://konghq.com/kong/
[verifying requests from Slack]: https://api.slack.com/docs/verifying-requests-from-slack
