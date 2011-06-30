xquery version "1.0-ml";

import module namespace rest="http://marklogic.com/appservices/rest"
    at "/ml-rest-lib/rest.xqy";

import module namespace tests="https://github.com/marklogic/ml-rest-lib/tests"
    at "/tests/tests.xqy";

declare namespace xdmp-http="xdmp:http";
declare namespace html="http://www.w3.org/1999/xhtml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare function local:run-test(
  $test-group as xs:string,
  $test-number as xs:decimal
)
{
  let $group  := tests:unit-tests($test-group)
  let $test   := $group/tests:test[$test-number]
  let $uri    := concat(tests:server-root(), $test/tests:url)
  let $opts   := <options xmlns="xdmp:http">
                   <headers>
                     <rest-unit-test-group>{$test-group}</rest-unit-test-group>
                     <rest-unit-test-number>{$test-number}</rest-unit-test-number>
                   </headers>
                   { tests:server-auth() }
                 </options>
  let $trace  := xdmp:log(concat("Run test: ", $test-group, ": ", $test-number, ": ", $uri))
  let $result := if ($test/@method = "GET" or empty($test/@method))
                 then xdmp:http-get($uri, $opts)
                 else if ($test/@method = "POST")
                      then xdmp:http-post($uri, $opts)
                      else error((), "test method is not GET or POST?")
  return
    if ($test/@code and $test/@code != "200" and $test/@code = $result[1]/xdmp-http:code)
    then
      <dt class="pass">
        { concat("PASS: ", $test-group, ": ", $test-number, " of ", count($group/tests:test)) }
      </dt>
    else
      if ($result[1]/xdmp-http:code = 404)
      then
        <dt class="fail">
          { concat("FAIL: ", $test-group, ": ", $test-number, " of ", count($group/tests:test), " => 404") }
        </dt>
      else
        $result[2]/html:dl/*
};

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>REST Library Unit Test Results</title>
<style type="text/css">
.pass {{
  background-color: #AAFFAA;
}}

.fail {{
  background-color: #FFAAAA;
}}

dd {{
  color: #AAAAAA;
}}
</style>
</head>
<body>
{(:
  { local:run-test("group1", 2) }
:)}
  { for $group in tests:unit-tests()/tests:test-group
    return
      <div>
        <h3>Test group: "{string($group/@id)}"</h3>
        <p>{count($group/tests:test)} tests</p>
        <dl>
          { for $number at $index in $group/tests:test
            return
              local:run-test($group/@id, $index)
          }
        </dl>
      </div>
  }
</body>
</html>
