xquery version "1.0-ml";

module namespace endpoints="http://marklogic.com/appservices/endpoints";

import module namespace rest="http://marklogic.com/appservices/rest"
       at "/ml-rest-lib/rest.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

(: The options here demonstrate a few of the features of the REST library.
   They don't all make perfect sense; for example, I'm not sure I'd let any
   user run arbitrary .xqy files on a real, production system. :)

declare variable $endpoints:ENDPOINTS as element(rest:options)
  := <options xmlns="http://marklogic.com/appservices/rest">
       {(: We don't serve anything else in this example, so redirect / to /slides/ :)}
       <request uri="^/$" endpoint="/example/redirect.xqy" user-params="allow">
         <uri-param name="__ml_redirect__">/slides/</uri-param>
       </request>

       {(: Display a list of all the presentations for /slides/ :)}
       <request uri="^/slides/$" endpoint="/example/default.xqy"/>

       {(: Handle /slides by redirecting to /slides/ 
           This isn't really necessary, but I'm fussy about my URIs
       :)}
       <request uri="^/slides$" endpoint="/example/redirect.xqy" user-params="allow">
         <uri-param name="__ml_redirect__">/slides/</uri-param>
       </request>

       {(: If a URI is requested and that URI exists, regardless of what else
           it might have matched, just return it.
       :)}
       <request uri="^(/.+)$" endpoint="/example/serve.xqy">
         <uri-param name="uri">$1</uri-param>
         <function ns="http://marklogic.com/appservices/endpoints" apply="doc-exists"
                   at="/example/endpoints.xqy"/>
       </request>

       {(: Handle /slides/deck/nn :)}
       <request uri="^/slides/(.+?)/(\d+)$" endpoint="/example/slides.xqy">
         <uri-param name="slides">/slides/$1/slides.xml</uri-param>
         <uri-param name="num" as="decimal">$2</uri-param>
         <param name="toc" as="boolean" default="false"/>
         <param name="theme" values="red|blue|green" required="false"/>
       </request>

       {(: Handle /slides/deck/toc :)}
       <request uri="^/slides/(.+?)/toc$" endpoint="/example/slides.xqy">
         <uri-param name="slides">/slides/$1/slides.xml</uri-param>
         <uri-param name="toc" as="boolean">true</uri-param>
         <param name="theme" values="red|blue|green" required="false"/>
       </request>

       {(: Handle /slides/deck by redirecting to /slides/deck/  :)}
       <request uri="^/slides/([^/]+)$" endpoint="/example/redirect.xqy" user-params="allow">
         <uri-param name="__ml_redirect__">/slides/$1/</uri-param>
       </request>

       {(: Handle /slides/deck/ :)}
       <request uri="^/slides/([^/]+?)/?$" endpoint="/example/slides.xqy">
         <uri-param name="slides">/slides/$1/slides.xml</uri-param>
         <http method="GET"/>
       </request>

       {(: Handle POST requests to /slides/deck/ :)}
       <request uri="^/slides/([^/]+?)/$" endpoint="/example/post.xqy">
         <uri-param name="slides">/slides/$1/slides.xml</uri-param>
         <http method="POST">
           <auth>
             <privilege>http://marklogic.com/xdmp/privileges/infostudio</privilege>
             <kind>execute</kind>
           </auth>
         </http>
       </request>

       {(: Handle POST requests to anywhere else :)}
       <request uri="^/slides/(.+)?$" endpoint="/example/post.xqy">
         <uri-param name="slides">/slides/$1</uri-param>
         <http method="POST">
           <auth>
             <privilege>http://marklogic.com/xdmp/privileges/infostudio</privilege>
             <kind>execute</kind>
           </auth>
         </http>
       </request>

       {(: Redirect /presentations/... to /slides/... :)}
       <request uri="^/presentations/(.+)$" endpoint="/example/redirect.xqy" user-params="allow">
         <uri-param name="__ml_redirect__">/slides/$1</uri-param>
       </request>

       {(: If the URI contains .xqy, assume we can just run it :)}
       <request uri="^(/.*\.xqy.*)$" endpoint="$1"/>

       {(: If we still haven't found it, try to serve it again. The serve.xqy script
           might find it through the path searching trick...
       :)}
       <request uri="^(/.+)$" endpoint="/example/serve.xqy">
         <uri-param name="uri">$1</uri-param>
       </request>

       {(: Handle OPTIONS requests :)}
       <request uri="^(.+)$" endpoint="/example/options.xqy" user-params="allow">
         <uri-param name="__ml_options__">$1</uri-param>
         <http method="OPTIONS"/>
       </request>
     </options>;

declare function endpoints:doc-exists(
  $uri as xs:string,
  $func as element(rest:function))
as xs:boolean
{
  doc-available($uri)
};

declare function endpoints:options()
as element(rest:options)
{
  let $check := rest:check-options($ENDPOINTS)
  return
    if (empty($check))
    then
      $ENDPOINTS
    else
      error(xs:QName("ERROR"), "Options are not valid in endpoints.xqy")
};

declare function endpoints:request(
  $module as xs:string)
as element(rest:request)?
{
  ($ENDPOINTS/rest:request[@endpoint = $module])[1]
};
