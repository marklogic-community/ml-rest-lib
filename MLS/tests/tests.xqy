xquery version "1.0-ml";

module namespace tests="https://github.com/marklogic/ml-rest-lib/tests";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace rest="http://marklogic.com/appservices/rest";
declare namespace xdmp-http="xdmp:http";

declare option xdmp:mapping "false";

declare variable $tests:unit-tests as element(tests:unit-tests) :=
<unit-tests xmlns="https://github.com/marklogic/ml-rest-lib/tests">
  <server-root>http://localhost:8021/tests</server-root>

  <test-group id="group001">
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

    <request-test>
      <url>/not/found</url>
    </request-test>
    <request-test>
      <url>/path/to/thing</url>
      <result>
        <entry key="base">path</entry>
        <entry key="qualifier">/to/thing</entry>
      </result>
    </request-test>
    <request-test method="POST" request="2">
      <url>/server/post/to/thing</url>
      <result>
        <entry key="uri">/server/post/to/thing</entry>
      </result>
    </request-test>
  </test-group>

  <test-group id="group002">
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

    <request-test>
      <url>/query1/1/10</url>
      <result>
        <entry key="start">1</entry>
        <entry key="end">10</entry>
      </result>
    </request-test>
    <request-test request="2">
      <url>/query2/1/10?a=b</url>
      <result>
        <entry key="start">1</entry>
        <entry key="end">10</entry>
      </result>
    </request-test>
    <request-test request="3">
      <url>/query3/1/10?a=b</url>
      <result>
        <entry key="start">1</entry>
        <entry key="end">10</entry>
        <entry key="a">b</entry>
      </result>
    </request-test>
    <request-test request="4">
      <url>/query4/1/10?a=b</url>
      <result>
        <entry key="start">1</entry>
        <entry key="end">10</entry>
        <entry key="a">b</entry>
      </result>
    </request-test>
    <request-test>
      <url>/query1/1/10?a=b</url>
    </request-test>
    <request-test request="2">
      <url>/query2/1/10?start=test&amp;a=b</url>
    </request-test>
    <request-test request="3">
      <url>/query3/1/10?start=test&amp;a=b</url>
    </request-test>
    <request-test request="4">
      <url>/query4/1/10?start=test&amp;a=b</url>
      <result>
        <entry key="start">
          <value>1</value>
          <value>test</value>
        </entry>
        <entry key="end">10</entry>
        <entry key="a">b</entry>
      </result>
    </request-test>
  </test-group>

  <test-group id="group003">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/tests/map/([A-Za-z0-9_-]+)(/)?$" endpoint="/tests/endpoint.xqy">
        <uri-param name="name" as="string">$1</uri-param>
        <http method="GET"/>
        <http method="POST">
          <param name="key" required="true"/>
          <param name="mode" required="true" values="contains|equality"/>
        </http>
        <http method="DELETE"/>
      </request>
    </options>

    <request-test method="POST" request="1">
      <url>/map/test?key=key&amp;mode=equality</url>
      <result>
        <entry key="name">test</entry>
        <entry key="key">key</entry>
        <entry key="mode">equality</entry>
      </result>
    </request-test>
  </test-group>

  <test-group id="group004">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="uri">/$1</uri-param>
        <http method="POST"/>
      </request>
    </options>

    <request-test>
      <url>/path/to/thing</url>
    </request-test>
    <request-test method="POST">
      <url>/path/to/thing</url>
      <result>
        <entry key="uri">/tests/path/to/thing</entry>
      </result>
    </request-test>
    <request-test>
      <url>/path/to/thing?foo=bar</url>
    </request-test>
  </test-group>

  <test-group id="group005">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request xmlns="http://marklogic.com/appservices/rest"
               uri="^/foo/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="uri">/$1</uri-param>
        <http method="GET"/>
      </request>
    </options>
    <request-test>
      <url>/path/to/thing</url>
    </request-test>
  </test-group>

  <test-group id="group006">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/tests/(path|foo)/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="base">$1</uri-param>
        <uri-param name="qualifier">/$2</uri-param>
      </request>
    </options>
    <request-test>
      <url>/path/to/thing</url>
      <result>
        <entry key="base">path</entry>
        <entry key="qualifier">/to/thing</entry>
      </result>
    </request-test>
  </test-group>

  <test-group id="group007">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="uri">/$1</uri-param>
        <param name="format" required="true"/>
      </request>
    </options>

    <request-test>
      <url>/path/to/thing</url>
    </request-test>
    <request-test>
      <url>/path/to/thing?bar=foo</url>
    </request-test>
    <request-test>
      <url>/path/to/thing?format=bar</url>
      <result>
        <entry key="format">bar</entry>
        <entry key="uri">/tests/path/to/thing</entry>
      </result>
    </request-test>
    <request-test>
      <url>/path/to/thing?format=foo&amp;bar=baz</url>
    </request-test>
  </test-group>

  <test-group id="group008">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="uri">/$1</uri-param>
         <param name="format" match="^application/(.*?)\+?xml$">qux-$1</param>
      </request>
    </options>
    <request-test>
      <url>/path/to/thing?format=application/bar%2bxml</url>
      <result>
        <entry key="format">qux-bar</entry>
        <entry key="uri">/tests/path/to/thing</entry>
      </result>
    </request-test>
  </test-group>

  <test-group id="group009">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="uri">/$1</uri-param>
         <param name="format" values="bar|baz" required="true"/>
      </request>
    </options>
    <request-test>
      <url>/path/to/thing</url>
    </request-test>
    <request-test>
      <url>/path/to/thing?qux=bar</url>
    </request-test>
    <request-test>
      <url>/path/to/thing?format=foo</url>
    </request-test>
    <request-test>
      <url>/path/to/thing?format=bar</url>
      <result>
        <entry key="format">bar</entry>
        <entry key="uri">/tests/path/to/thing</entry>
      </result>
    </request-test>
  </test-group>

  <test-group id="group010">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/(.*)$" endpoint="/tests/endpoint.xqy" user-params="allow">
        <uri-param name="uri">/$1</uri-param>
        <param name="format" values="qux-bar|qux-baz" match="^(.+)$">qux-$1</param>
      </request>
    </options>
    <request-test>
      <url>/path/to/thing?format=bar</url>
      <result>
        <entry key="format">qux-bar</entry>
        <entry key="uri">/tests/path/to/thing</entry>
      </result>
    </request-test>
    <request-test>
      <url>/path/to/thing?format=bar&amp;corge=grault</url>
      <result>
        <entry key="format">qux-bar</entry>
        <entry key="corge">grault</entry>
        <entry key="uri">/tests/path/to/thing</entry>
      </result>
    </request-test>
  </test-group>

  <test-group id="group011">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/(.*)$" endpoint="/tests/endpoint.xqy" user-params="ignore">
        <uri-param name="uri">/$1</uri-param>
      </request>
    </options>
    <request-test>
      <url>/path/to/thing?format=bar&amp;bar=baz</url>
      <result>
        <entry key="uri">/tests/path/to/thing</entry>
      </result>
    </request-test>
  </test-group>


  <test-group id="group012">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/(.*)$" endpoint="/tests/endpoint.xqy" user-params="ignore">
        <uri-param name="uri">/$1</uri-param>
        <param name="format"/>
      </request>
    </options>
    <request-test>
      <url>/path/to/thing?format=bar&amp;bar=baz</url>
      <result>
        <entry key="uri">/tests/path/to/thing</entry>
        <entry key="format">bar</entry>
      </result>
    </request-test>
  </test-group>

  <!-- default values -->
  <test-group id="group013">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="uri">/$1</uri-param>
        <param name="bar"/>
        <param name="format" default="foo"/>
      </request>
    </options>
    <request-test>
      <url>/path/to/thing?bar=baz</url>
      <result>
        <entry key="uri">/tests/path/to/thing</entry>
        <entry key="bar">baz</entry>
        <entry key="format">foo</entry>
      </result>
    </request-test>
    <request-test>
      <url>/path/to/thing?bar=baz&amp;format=bar</url>
      <result>
        <entry key="uri">/tests/path/to/thing</entry>
        <entry key="bar">baz</entry>
        <entry key="format">bar</entry>
      </result>
    </request-test>
  </test-group>

  <!-- default values with suppressed parameters -->
  <test-group id="group014">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/(.*)$" endpoint="/tests/endpoint.xqy" user-params="ignore">
        <uri-param name="uri">/$1</uri-param>
        <param name="format" default="foo"/>
      </request>
    </options>
    <request-test>
      <url>/path/to/thing?bar=baz</url>
      <result>
        <entry key="uri">/tests/path/to/thing</entry>
        <entry key="format">foo</entry>
      </result>
    </request-test>
  </test-group>

  <!-- default values with suppressed parameters -->
  <test-group id="group015">
    <options xmlns="http://marklogic.com/appservices/rest">
      <!-- In the rewriter, the first request will match -->
      <request uri="^/(tests/path.*)$" endpoint="/tests/endpoint.xqy?format=foo" user-params="ignore">
        <uri-param name="uri">/$1</uri-param>
        <param name="bar" default="baz"/>
      </request>
      <!-- But in the endpoint, we have to use the second request in order for
           the format parameter to go through. -->
      <request uri="^/(tests/path.*)$" endpoint="/tests/endpoint.xqy?format=foo" user-params="ignore">
        <uri-param name="uri">/$1</uri-param>
        <param name="bar" default="baz"/>
        <param name="format"/>
      </request>
    </options>
    <request-test request="2">
      <url>/path/to/thing?bar=baz</url>
      <result>
        <entry key="uri">/tests/path/to/thing</entry>
        <entry key="format">foo</entry>
        <entry key="bar">baz</entry>
      </result>
    </request-test>
  </test-group>

  <!-- unmatched privilege -->
  <test-group id="group016" not-role="admin">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="uri">/$1</uri-param>
        <auth>
          <privilege>http://marklogic.com/xdmp/privileges/infostudio</privilege>
        </auth>
      </request>
    </options>
    <request-test>
      <url>/this/test/is/expected/to/fail/if/you/run/as/admin</url>
    </request-test>
  </test-group>

  <!-- matched privilege -->
  <test-group id="group017" role="infostudio-user">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="uri">/$1</uri-param>
        <auth>
          <privilege>http://marklogic.com/xdmp/privileges/infostudio</privilege>
        </auth>
      </request>
    </options>
    <request-test>
      <url>/path/to/thing</url>
      <result>
        <entry key="uri">/tests/path/to/thing</entry>
      </result>
    </request-test>
  </test-group>

  <!-- user agent tests -->
  <test-group id="group018">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/tests/yes/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="uri">/$1</uri-param>
        <user-agent>.*</user-agent>
      </request>
      <request uri="^/tests/no/(.*)$" endpoint="/tests/endpoint.xqy">
        <uri-param name="uri">/$1</uri-param>
        <user-agent>There are no user agent strings that match this regex</user-agent>
      </request>
    </options>
    <request-test>
      <url>/yes/path/to/thing</url>
      <result>
        <entry key="uri">/path/to/thing</entry>
      </result>
    </request-test>
    <request-test>
      <url>/no/path/to/thing</url>
    </request-test>
  </test-group>

  <!-- test repeated parameters -->
  <test-group id="group019">
    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/tests/1/(.*)$" endpoint="/tests/endpoint.xqy">
        <param name="rep" repeatable="true"/>
      </request>
      <request uri="^/tests/2/(.*)$" endpoint="/tests/endpoint.xqy">
        <param name="view"/>
        <param name="rep" repeatable="true"/>
      </request>
    </options>
    <request-test>
      <url>/1/test?rep=1&amp;rep=2&amp;rep=3</url>
      <result>
        <entry key="rep">
          <value>1</value>
          <value>2</value>
          <value>3</value>
        </entry>
      </result>
    </request-test>
    <request-test request="2">
      <url>/2/test?rep=1&amp;rep=2&amp;rep=3</url>
      <result>
        <entry key="rep">
          <value>1</value>
          <value>2</value>
          <value>3</value>
        </entry>
      </result>
    </request-test>
  </test-group>

  <test-group id="group020">
    <content-type-test>
      <type>text/html</type>
      <type>application/xml</type>
      <result>
        <value>text/html</value>
        <value>application/xml</value>
      </result>
    </content-type-test>
    <content-type-test>
      <header>text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8</header>
    </content-type-test>
    <content-type-test/>
    <content-type-test>
      <type>application/xml</type>
      <header>text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8</header>
      <result>
        <value>application/xml</value>
      </result>
    </content-type-test>
    <content-type-test>
      <type>text/html</type>
      <type>application/xml</type>
      <header>text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8</header>
      <result>
        <value>text/html</value>
        <value>application/xml</value>
      </result>
    </content-type-test>
    <content-type-test>
      <type>text/plain</type>
      <type>application/xhtml+xml</type>
      <header>text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8</header>
      <result>
        <value>application/xhtml+xml</value>
        <value>text/plain</value>
      </result>
    </content-type-test>
    <content-type-test>
      <type>text/plain</type>
      <type>application/xhtml+xml</type>
      <header>text/html,text/*;q=0.9,*/*;q=0.8</header>
      <result>
        <value>text/plain</value>
        <value>application/xhtml+xml</value>
      </result>
    </content-type-test>
    <content-type-test>
      <type>text/plain</type>
      <header>text/html,application/xml;q=0.9,*/*;q=0.8</header>
      <result>
        <value>text/plain</value>
      </result>
    </content-type-test>
    <content-type-test>
      <type>text/html;level=1</type>
      <type>text/html;level=3</type>
      <type>text/html</type>
      <header>text/*;q=0.3, text/html;q=0.7, text/html;level=1, text/html;level=2;q=0.4, */*;q=0.5</header>
      <result>
        <value>text/html;level=1</value>
        <value>text/html</value>
        <value>text/html;level=3</value>
      </result>
    </content-type-test>
    <content-type-test>
      <type>text/json</type>
      <type>text/plain</type>
      <header>text/html, */*, text/json</header>
      <result>
        <value>text/json</value>
        <value>text/plain</value>
      </result>
    </content-type-test>
    <content-type-test>
      <type>application/xml</type>
      <type>text/plain</type>
      <type>application/json</type>
      <header>text/html, application/xml, application/json</header>
      <result>
        <value>application/xml</value>
        <value>application/json</value>
      </result>
    </content-type-test>
    <content-type-test>
      <type>application/json</type>
      <type>application/xml</type>
      <header>text/html;q=0.9,application/xml;q=0.9,application/json;q=0.8</header>
      <result>
        <value>application/xml</value>
        <value>application/json</value>
      </result>
    </content-type-test>
  </test-group>

  <test-group id="group021">
    <http-test>
      <request xmlns="http://marklogic.com/appservices/rest"/>
      <verb>POST</verb>
      <result>REST-UNSUPPORTEDMETHOD POST</result>
    </http-test>

    <http-test>
      <request xmlns="http://marklogic.com/appservices/rest"/>
      <verb>GET</verb>
      <result>true</result>
    </http-test>
    <http-test>
      <request xmlns="http://marklogic.com/appservices/rest">
        <http method="POST"/>
      </request>
      <verb>GET</verb>
      <result>REST-UNSUPPORTEDMETHOD GET</result>
    </http-test>
    <http-test>
      <request xmlns="http://marklogic.com/appservices/rest">
        <http method="POST"/>
      </request>
      <verb>POST</verb>
      <result>true</result>
    </http-test>
    <http-test>
      <request xmlns="http://marklogic.com/appservices/rest">
        <http method="POST"/>
        <http method="GET"/>
      </request>
      <verb>GET</verb>
      <result>true</result>
    </http-test>
    <http-test>
      <request xmlns="http://marklogic.com/appservices/rest">
        <http method="POST"/>
        <http method="GET"/>
      </request>
      <verb>OPTIONS</verb>
      <result>REST-UNSUPPORTEDMETHOD OPTIONS</result>
    </http-test>
  </test-group>
</unit-tests>;

declare function tests:server-root()
as xs:string
{
  $tests:unit-tests/tests:server-root
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
