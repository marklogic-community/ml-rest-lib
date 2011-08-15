xquery version "1.0-ml";

import module namespace rest="http://marklogic.com/appservices/rest"
       at "/ml-rest-lib/rest.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

let $request
  := <request xmlns="http://marklogic.com/appservices/rest"
              uri="^/tests/post$" endpoint="/tests/post.xqy" user-params="allow">
       <http method="POST"/>
     </request>
let $params := rest:process-request($request)
return
  for $name in map:keys($params)
  for $value in map:get($params, $name)
  return
    concat($name, "=", $value)
