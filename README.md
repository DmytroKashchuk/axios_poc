# axios_poc
PoC of axios supply chain attack!

# Architecture
[Verdaccio locale :4873]              [my-app]
  ├── axios@1.14.1-evil    ←──────── npm install axios
  └── plain-crypto-js@4.2.1                │
                                            ▼
                                    postinstall hook
                                            │
                                            ▼
                                  /tmp/pwned.txt  (payload non dangerous)

Verdaccio is a local npm registry


