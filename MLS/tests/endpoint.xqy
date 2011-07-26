xquery version "1.0-ml";

import module namespace rest="http://marklogic.com/appservices/rest"
    at "/ml-rest-lib/rest.xqy";

import module namespace tests="https://github.com/marklogic/ml-rest-lib/tests"
    at "/tests/tests.xqy";

declare namespace html="http://www.w3.org/1999/xhtml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare variable $test-group as xs:string? := xdmp:get-request-header("rest-unit-test-group");
declare variable $test-number as xs:decimal
  := if (empty(xdmp:get-request-header("rest-unit-test-number")))
     then 1
     else xs:decimal(xdmp:get-request-header("rest-unit-test-number"));

declare function local:errors(
  $test as element(tests:test),
  $params as map:map
) as element(html:dd)?
{
  let $result  := $test/tests:result
  let $keyerrs := (if (count($result/tests:entry) = count(map:keys($params)))
                   then ()
                   else concat("Expected ", count($result/tests:entry), " keys; got ", count(map:keys($params))),
                   for $key in map:keys($params)
                   where empty($result/tests:entry[@key = $key])
                   return
                     concat("No actual value for expected key: ", $key),
                   for $entry in $result/tests:entry
                   where not(string($entry/@key) = map:keys($params))
                   return
                     concat("Unexpected key: ", $entry/@key))

  let $valerrs := for $key in map:keys($params)
                  let $val := map:get($params, $key)
                  let $exp := $result/tests:entry[@key = $key]
                  return
                    if ($exp/tests:value)
                    then
                      local:seq-err($key, $exp/tests:value/string(), $val)
                    else
                      if (string($exp) = string($val))
                      then ()
                      else concat($key, ": expected '", $exp, "' got '", $val, "'")
  return
    if (empty($keyerrs) and empty($valerrs))
    then ()
    else
      <dd xmlns="http://www.w3.org/1999/xhtml">
        { for $msg in ($keyerrs, $valerrs)
          return
            (<span>{$msg}</span>, <br/>)
        }
      </dd>
};

declare function local:seq-err(
  $key as xs:string,
  $exp as xs:string*,
  $val as xs:string*
) as xs:string*
{
  (if (count($exp) = count($val))
   then ()
   else concat($key, ": expected ", count($exp), " values; got ", count($val)),
   for $e at $index in $exp
   let $v := $val[$index]
   where string($e) != string($v)
   return
     concat($key, " value ", $index, ": '", $e, "' != '", $v, "'"))
};

let $group   := tests:unit-tests($test-group)
let $options := tests:options($test-group)
let $test    := $group/tests:test[$test-number]
let $request := if ($test/@request)
                then $options/rest:request[xs:decimal($test/@request)]
                else $options/rest:request[1]
let $params  := rest:process-request($request)
let $errs    := local:errors($test,$params)
let $pf      := if (empty($errs)) then "PASS" else "FAIL"
return
  <dl xmlns="http://www.w3.org/1999/xhtml">
    <dt xmlns="http://www.w3.org/1999/xhtml" class="{lower-case($pf)}">
      { concat($pf, ": ", $test-group, ": ", $test-number, " of ", count($group/tests:test))
      }
   </dt>
   { $errs }
  </dl>

