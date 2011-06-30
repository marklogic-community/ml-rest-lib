xquery version "1.0-ml";

module namespace tests="https://github.com/marklogic/ml-rest-lib/tests";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace rest="http://marklogic.com/appservices/rest";
declare namespace xdmp-http="xdmp:http";

declare option xdmp:mapping "false";

declare variable $tests:unit-tests as element(tests:unit-tests) :=
<unit-tests xmlns="https://github.com/marklogic/ml-rest-lib/tests">
  <server-root>http://localhost:8021/tests</server-root>
  <username>admin</username>
  <password>admin</password>
  <test-group id="group1">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/tests/(path|foo)/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="base">$1</uri-param>
        <uri-param name="qualifier">/$2</uri-param>
      </request>
      <request uri="^/tests/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="uri">/$1</uri-param>
        <http method="POST"/>
      </request>
    </options>

    <test code="404">
      <url>/not/found</url>
    </test>
    <test>
      <url>/path/to/thing</url>
      <result>
        <entry key="base">path</entry>
        <entry key="qualifier">/to/thing</entry>
      </result>
    </test>
    <test method="POST" request="2">
      <url>/server/post/to/thing</url>
      <result>
        <entry key="uri">/server/post/to/thing</entry>
      </result>
    </test>
  </test-group>

  <test-group id="group2">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/tests/query1/(\d*)/(\d+)$" endpoint="/tests/endpoint.xqy" user-params="forbid">
        <uri-param name="start" as="string">$1</uri-param>
        <uri-param name="end" as="string">$2</uri-param>
      </request>
      <request uri="^/tests/query2/(\d*)/(\d+)$" endpoint="/tests/endpoint.xqy" user-params="ignore">
        <uri-param name="start" as="string">$1</uri-param>
        <uri-param name="end" as="string">$2</uri-param>
      </request>
      <request uri="^/tests/query3/(\d*)/(\d+)$" endpoint="/tests/endpoint.xqy" user-params="allow">
        <uri-param name="start" as="string">$1</uri-param>
        <uri-param name="end" as="string">$2</uri-param>
      </request>
      <request uri="^/tests/query4/(\d*)/(\d+)$" endpoint="/tests/endpoint.xqy" user-params="allow-dups">
        <uri-param name="start" as="string">$1</uri-param>
        <uri-param name="end" as="string">$2</uri-param>
      </request>
    </options>

    <test>
      <url>/query1/1/10</url>
      <result>
        <entry key="start">1</entry>
        <entry key="end">10</entry>
      </result>
    </test>
    <test request="2">
      <url>/query2/1/10?a=b</url>
      <result>
        <entry key="start">1</entry>
        <entry key="end">10</entry>
      </result>
    </test>
    <test request="3">
      <url>/query3/1/10?a=b</url>
      <result>
        <entry key="start">1</entry>
        <entry key="end">10</entry>
        <entry key="a">b</entry>
      </result>
    </test>
    <test request="4">
      <url>/query4/1/10?a=b</url>
      <result>
        <entry key="start">1</entry>
        <entry key="end">10</entry>
        <entry key="a">b</entry>
      </result>
    </test>
    <test code="404">
      <url>/query1/1/10?a=b</url>
    </test>
    <test code="404" request="2">
      <url>/query2/1/10?start=test&amp;a=b</url>
    </test>
    <test code="404" request="3">
      <url>/query3/1/10?start=test&amp;a=b</url>
    </test>
    <test request="4">
      <url>/query4/1/10?start=test&amp;a=b</url>
      <result>
        <entry key="start">
          <value>1</value>
          <value>test</value>
        </entry>
        <entry key="end">10</entry>
        <entry key="a">b</entry>
      </result>
    </test>

  </test-group>

</unit-tests>;

declare function tests:server-root()
as xs:string
{
  $tests:unit-tests/tests:server-root
};

declare function tests:server-auth()
as element(xdmp-http:authentication)?
{
  if ($tests:unit-tests/tests:username)
  then
    <authentication xmlns="xdmp:http">
      { attribute { fn:QName("", "method") }
                  { if ($tests:unit-tests/tests:auth-method)
                    then string($tests:unit-tests/tests:auth-method)
                    else "digest" }
      }
      <username>{$tests:unit-tests/tests:username/string()}</username>
      <password>{$tests:unit-tests/tests:password/string()}</password>
    </authentication>
  else
    ()
};

declare function tests:unit-tests()
as element(tests:unit-tests)
{
  $tests:unit-tests
};

declare function tests:unit-tests(
  $group as xs:string
) as element(tests:test-group)?
{
  $tests:unit-tests/tests:test-group[@id=$group]
};

declare function tests:options(
  $group as xs:string
) as element(rest:options)?
{
  tests:unit-tests($group)/rest:options
};
