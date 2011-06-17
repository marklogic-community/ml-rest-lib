xquery version "1.0-ml";

import module namespace rest="http://marklogic.com/appservices/rest"
       at "/MarkLogic/appservices/utils/rest.xqy";

import module namespace endpoint="http://marklogic.com/appservices/endpoints"
       at "/example/endpoints.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

let $params  := rest:process-request(endpoint:request("/example/post.xqy"))
let $posturi := map:get($params, "slides")
let $type    := xdmp:get-request-header('Content-Type')
let $format
  := if ($type = 'application/xml' or ends-with($type, '+xml'))
     then
       "xml"
     else
       if (contains($type, "text/"))
       then "text"
       else "binary"
let $body := xdmp:get-request-body($format)
return
  (xdmp:document-insert($posturi, $body),
   concat("Successfully uploaded: ", $posturi, "&#10;"))
