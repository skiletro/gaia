{
  nixos =
    let
      domain = "warm.vodka";
      deployments = [
        "sso"
        "drasl"
        "wakapi"
        "knot"
        "miniflux"
      ];
    in
    {
      services.caddy = {
        enable = true;
        virtualHosts."${domain}" = {
          serverAliases = [ "www.${domain}" ];
          extraConfig =
            # caddyfile
            ''
              handle /.well-known/webfinger {
                header Content-Type application/jrd+json
                  respond `
                    {
                      "subject": "{query.resource}",
                      "links": [
                        {
                          "rel": "http://openid.net/specs/connect/1.0/issuer",
                          "href": "https://sso.${domain}"
                        }
                      ]
                    }
                  ` 200
              }

              handle {
                header Content-Type text/html
                respond `${
                # html
                ''
                  <!DOCTYPE html>
                  <html lang="en">
                    <head>
                      <meta charset="UTF-8" />
                      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                      <title>warm.vodka</title>
                      <style>
                        @media (prefers-color-scheme: dark) {
                          body {
                            color: white;
                            background-color: black;
                          }

                          a {
                            color: lightcoral !important;
                          }
                        }

                        body {
                          height: 100dvh;
                          width: 100dvw;
                          overflow: hidden;
                          display: flex;
                          justify-content: center;
                          align-items: center;
                        }

                        div {
                          font-family: sans-serif;

                          & * {
                            padding: 0;
                            margin: 0;
                          }

                          & a {
                            color: coral;
                            text-decoration: none;
                          }

                          & ul {
                            list-style-type: none;
                            text-align: center;
                          }
                        }
                      </style>
                    </head>
                    <body>
                      <div>
                        <h1>warm.vodka</h1>
                        <ul>
                          ${builtins.concatStringsSep "" (
                            map (
                              x:
                              # html
                              ''
                                <li><a href="https://${x}.warm.vodka/">${x}</a></li>
                              '') deployments
                          )}
                        </ul>
                      </div>
                    </body>
                  </html>
                ''}`
              }
            '';
        };
      };
    };
}
