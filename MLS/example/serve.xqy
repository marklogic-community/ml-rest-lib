xquery version "1.0-ml";

import module namespace rest="http://marklogic.com/appservices/rest"
       at "/ml-rest-lib/rest.xqy";

import module namespace endpoint="http://marklogic.com/appservices/endpoints"
       at "/example/endpoints.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

(: This is a funny case. We don't want to apply the <rest:function> test
   in the endpoint because it tests the URI and by the time we get here,
   the URI string has changed. To work around this, we simply copy the
   request and drop an rest:function tests on the floor.
:)
let $epreq  := endpoint:request("/example/serve.xqy")
let $req    := <rest:request>
                 { $epreq/@*, $epreq/*[not(self::rest:function)] }
               </rest:request>

let $params := rest:process-request($req)
let $uri    := map:get($params, "uri")
let $segs   := tokenize($uri, "/")
let $fn     := $segs[count($segs)]
let $uris   := for $seg at $index in $segs
               where $index < count($segs)
               return string-join(($segs[1 to $index], $fn), "/")
let $duris  := for $uri in reverse($uris)
               where doc-available($uri)
               return $uri
return
  if ($uri eq "/favicon.ico") (: this case bugs me, so make it go away :)
  then
    ()
  else
    if (empty($duris))
    then
      xdmp:log(concat("Cannot serve ", $uri))
    else
      doc($duris[1])
