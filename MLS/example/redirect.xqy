xquery version "1.0-ml";

import module namespace rest="http://marklogic.com/appservices/rest"
       at "/MarkLogic/appservices/utils/rest.xqy";

import module namespace endpoint="http://marklogic.com/appservices/endpoints"
       at "/example/endpoints.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

let $params := rest:process-request(endpoint:request("/example/redirect.xqy"))
let $query  := string-join(
                 for $param in map:keys($params)
                 where $param != "__ml_redirect__"
                 return
                   for $value in map:get($params, $param)
                   return
                     concat($param, "=", string($value)),
                 "&amp;")
let $ruri   := concat(map:get($params, "__ml_redirect__"),
                      if ($query = "") then ""
                      else concat("?", $query))
return
  (xdmp:set-response-code(301, "Moved permanently"),
   xdmp:redirect-response($ruri))
