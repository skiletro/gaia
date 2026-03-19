{
  nixos =
    let
      domain = "warm.vodka";
      deployments = [
        # keep-sorted start
        "drasl"
        "miniflux"
        "wakapi"
        # keep-sorted end
      ];
      listElem =
        subdomain: text:
        # html
        ''
          <li><a href="https://${subdomain}.warm.vodka/">${text}</a></li>
        '';
      listBreak =
        # html
        ''
          <li>&ZeroWidthSpace;</li>
        '';
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
                        body { color: #fff; background: #000; }
                        a { color: lightcoral !important; }
                      }
                      
                      body {
                        height: 100dvh; width: 100dvw;
                        overflow: hidden;
                        display: flex; justify-content: center; align-items: center;
                      }
                      
                      div { font-family: sans-serif }
                      div * { margin: 0; padding: 0 }
                      div a { color: coral; text-decoration: none }
                      div ul { list-style: none; text-align: center }
                      </style>
                    </head>
                    <body>
                      <div>
                        <h1>warm.vodka</h1>
                        <ul>
                          ${listElem "sso" "sign in with methanol"}
                          ${listBreak}
                          ${builtins.concatStringsSep "" (map (x: listElem x x) deployments)}
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
