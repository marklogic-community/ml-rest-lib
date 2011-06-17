xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

let $uris
  := try {
       cts:uris()[matches(., "^/slides/.+/slides.xml$")]
     } catch ($e) {
       for $doc in collection()
       let $uri := xdmp:node-uri($doc)
       where matches($uri, "^/slides/.+/slides.xml$")
       return
         $uri
     }
return
  if (empty($uris))
  then
    "No slides for you."
  else
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>You've got slides!</title>
        <link rel="stylesheet" type="text/css" href="/slides/slides.css" />
      </head>
      <body>
        <div class="slide">
          <p>You've got slides!</p>
          <ul>
            { for $uri in $uris
              let $deck := replace($uri, "^/slides/(.+)/slides.xml$", "$1")
              let $doc := doc($uri)
              return
                <li>
                  <a href="/slides/{$deck}">
                    { string($doc/html/body/div[@class='titlepage']/h1) }
                  </a>
                </li>
            }
          </ul>
        </div>
      </body>
    </html>