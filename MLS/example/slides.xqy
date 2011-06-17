xquery version "1.0-ml";

import module namespace rest="http://marklogic.com/appservices/rest"
       at "/MarkLogic/appservices/utils/rest.xqy";

import module namespace endpoint="http://marklogic.com/appservices/endpoints"
       at "/example/endpoints.xqy";

declare namespace h="http://www.w3.org/1999/xhtml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare function local:no-slides(
  $uri as xs:string)
as element(h:html)
{
  <html xmlns="http://www.w3.org/1999/xhtml">
  <head>
  <title>No slides</title>
  </head>
  <body>
  <h1>No slides</h1>
  <p>There is no slides document named {$uri}</p>
  </body>
  </html>
};

declare function local:not-slides(
  $uri as xs:string)
as element(h:html)
{
  <html xmlns="http://www.w3.org/1999/xhtml">
  <head>
  <title>Not slides</title>
  </head>
  <body>
  <h1>Not slides</h1>
  <p>The {$uri} document does not contain slides.</p>
  </body>
  </html>
};

declare function local:slides(
  $slides as element(h:html),
  $num as xs:decimal?,
  $toc as xs:boolean)
as element(h:html)
{
  <html xmlns="http://www.w3.org/1999/xhtml">
  { $slides/h:head }
  <body>
    <div class="nav">
      { let $prev := if (exists($num) and $num > 1)
                     then $num - 1 else ()
        let $next := if (exists($num) and count($slides//h:div[@class="slide"]) > $num)
                     then $num + 1
                     else if (empty($num)) then 1 else ()
        let $uri  := concat(substring-before(xdmp:node-uri($slides), "/slides.xml"), "/")
        return
          (<a href="{$uri}">Home</a>,
           " | ",
           if (exists($prev))
           then <a href="{$uri}{$prev}">Prev</a> else <span class="inactive">Prev</span>,
           " | ",
           if (exists($next))
           then <a href="{$uri}{$next}">Next</a> else <span class="inactive">Next</span>,
           " | ",
           <a href="{$uri}toc">TOC</a>)
       }
    </div>
    { if ($toc)
      then
        local:toc($slides)
      else
        if (empty($num))
        then
          $slides/h:body/h:div[@class="titlepage"]
        else
          ($slides/h:body//h:div[@class="slide"])[$num]
    }
  </body>
  </html>
};

declare function local:toc(
  $slides as element(h:html))
as element(h:html)
{
  let $uri := substring-before(xdmp:node-uri($slides), "/slides.xml")
  return
    <html xmlns="http://www.w3.org/1999/xhtml">
    { $slides/h:head }
    <body>
      <div class="slide">
        <h1>{ string($slides/h:head/h:title) }</h1>
        <h2>Table of Contents</h2>
        <ul>
          { for $slide at $count in $slides/h:body//h:div[@class="slide"]
            return
              <li>
                <a href="{$uri}/{$count}">
                  { string($slide/h:h1) }
                </a>
              </li>
          }
        </ul>
      </div>
    </body>
    </html>
};

let $params := rest:process-request(endpoint:request("/example/slides.xqy"))
let $slides := map:get($params, "slides")
let $num    := map:get($params, "num")
let $toc    := map:get($params, "toc")
let $doc    := doc($slides)
return
  if (empty($doc))
  then
    local:no-slides($slides)
  else
    if (empty($doc/h:html) or empty($doc//h:div[@class="slide"]))
    then
      local:not-slides($slides)
    else
      local:slides($doc/h:html, $num, $toc)
