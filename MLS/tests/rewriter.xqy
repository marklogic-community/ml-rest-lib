xquery version "1.0-ml";

import module namespace tests="https://github.com/marklogic/ml-rest-lib/tests"
    at "/tests/tests.xqy";

import module namespace rest="http://marklogic.com/appservices/rest"
    at "/ml-rest-lib/rest.xqy";

declare option xdmp:mapping "false";

declare variable $test-group as xs:string? := xdmp:get-request-header("rest-unit-test-group");
declare variable $test-number as xs:string? := xdmp:get-request-header("rest-unit-test-number");

let $uri    := xdmp:get-request-url()
let $tests  := tests:unit-tests()
let $trace  := xdmp:log(concat("rewriter starting on ", $uri))
return
  (: First a couple of special cases :)
  if ($uri = "/")
  then
    "/default.xqy"
  else
    if ($uri = "/tests" or $uri = "/tests/")
    then
      "/tests/default.xqy?redirected=true"
    else
      if (empty($test-group) and $uri = "/tests/run-tests")
      then
        "/tests/run-tests.xqy"
      else
        let $options := tests:options($test-group)
        let $result  := rest:rewrite($options)
        return
          if (empty($result))
          then
            (xdmp:log(concat(" rewrite: ", $uri, " => 404!")),
             xdmp:set-response-code(404, "Not found"),
             $uri)
          else
            (xdmp:log(concat(" rewrite: ", $uri, " => ", $result)),
             $result)
