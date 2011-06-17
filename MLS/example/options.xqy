xquery version "1.0-ml";

import module namespace rest="http://marklogic.com/appservices/rest"
       at "/MarkLogic/appservices/utils/rest.xqy";

import module namespace endpoint="http://marklogic.com/appservices/endpoints"
       at "/example/endpoints.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

let $params  := rest:process-request(endpoint:request("/example/options.xqy"))
let $uri     := map:get($params, "__ml_options__")
let $trace   := xdmp:log($uri)
let $accept  := xdmp:get-request-header("Accept")
let $params  := map:map()
let $request := rest:matching-request(endpoint:options(), $uri, "GET", $accept, $params)
return
  if ($uri = "/")
  then
    endpoint:options()
  else
    $request


