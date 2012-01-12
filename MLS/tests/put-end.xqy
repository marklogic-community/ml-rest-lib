xquery version "1.0-ml";

import module namespace rest="http://marklogic.com/appservices/rest"
       at "/ml-rest-lib/rest.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

let $request := <request xmlns="http://marklogic.com/appservices/rest"
                         uri="^/tests/put-end.xqy$" endpoint="/tests/put-end.xqy"
                         user-params="allow">
                  <http method="GET PUT POST"/>
                  <param name="one"/>
                  <param name="two"/>
                  <param name="three"/>
                </request>
let $params  := rest:process-request($request)
return
  <result>
    <as-xml>{$params}</as-xml>
    <type>{xdmp:get-request-header("content-type")}</type>
    <as-body>{xdmp:binary-decode(xdmp:get-request-body(),'US-ASCII')}</as-body>
  </result>
