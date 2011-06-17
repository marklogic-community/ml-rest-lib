# The REST endpoint library

(Are you anxious and impatient? Do you want to just *see it work*?
Then you might prefer to skip down to the <a href="#slides">slides example</a>).

The REST endpoint library is a set of [XQuery][10] modules designed to
make the development and deployment of [RESTful web services][9] on
MarkLogic server easier. It consists of two parts, an XML vocabulary
for describing web service endpoints and a library module.

The XML vocabulary is used to write declarative descriptions of the
endpoints. These description include the mapping of URI parts to
parameters, additonal parameters, and conditions that must be met in
order for the incoming request to match.

The library module contains functions that simplify:

1. A [URL rewriter][1] for mapping incoming requests to endpoints
2. The parsing of parameters within the endpoint itself

The XML vocabulary has been designed so that same description can be
used for both the rewriter and the endpoint. One motivation for this
approach was to assure that *the same code* is used for both choosing
a rewrite and validating an endpoint; this minimizes the possibility
of semantic drift between the two halves of the task.

## REST endpoint markup

The REST endpoint markup is designed to facilitate writing
services in MarkLogic server. To that end, it provides a single,
declarative style for describing the URI, parameters, and other
aspects of an "endpoint". The [URI rewriter][1] uses a list of these
endpoint descriptions to dispatch to the right main module. The main
module in turn uses the same description to validate its parameters.

In other words, by writing a single description you get a rewriter for
free and validated, typed parameters in a single function call.

The simplest example just maps the URI to a module:

    <request uri="/" endpoint="/default.xqy"/>

If the incoming request is for "/", it is rewritten to "/default.xqy".
The `uri` is a regular expression, so you could also support requests
for `index.html` like this:

    <request uri="^/(index\.html)?$" endpoint="/default.xqy"/>

### Extracting parameters from the URI

But if all your rewrites were that simple, you'd hardly need a library
to simplify them. A more common sort of example is one that involves
translating parts of a URI into parameters. Suppose, for example, that
we have an endpoint for displaying slides from a presentation. The endpoint
needs the name of the slide deck to display and the number of the slide.
We could just slap those on as parameters, but getting URIs right is
[an important part][2] of building a REST interface.

Instead, we want to expose them through URIs of this form:
`/slides/`_deck_`/`_number_. So the third slide of the "uc11" deck would
be referenced with the URI `/slides/uc11/3`. That endpoint can be described
as follows:

    <request uri="^/slides/(.+?)/(\d+)$" endpoint="/slides.xqy">
      <uri-param name="deck">$1.xml</uri-param>
      <uri-param name="num">$2</uri-param>
    </request>

As before, the rewriter starts by comparing the request URI with the
specified `uri` regex. If it doesn't match, we don't have to go
further. But let's say the request URI is `/slides/uc11/3`, which
does match.

For each `uri-param`, the rewriter will construct a parameter with
the specified name using `fn:replace()` to compute the value. So the
`deck` parameter will have the value `uc11.xml` because
`fn:replace('/slides/uc11/3', '^/slides/(.+?)/(\d+)$', '$1.xml')` is
`uc11.xml`.

These parameters are passed to the specified endpoint by constructing
this rewrite:

    /slides.xqy?decl=uc11.xml&num=3

### Decoding parameters in the endpoint

So far so good. But inside the `slides.xqy` module, we've got to decode
all those parameters. In the simplest cases, like this one, it's not too
hard to call `xdmp:get-request-field()` for each parameter, but as endpoints
become more complicated with optional parameters and repeated parameters it
quickly becomes quite tedious.

Since we *have* a description of the endpoint, we can let a single library
function deal with all the complexity for us. Assuming we have the relevant
`request` element in `$request`, this simple call

    $params := rest:parse-options($request)

will return a map of the parameters. That still may not look too compelling,
but we can immediately begin to expose additional benefits "for free".

The first benefit you get is error detection. If someone manages to call this
endpoint with the wrong options, the `rest:parse-options()`
method will automatically raise an error. This means you (a) don't have to write
the error checking code and (2) don't have to worry about bugs that might be
introduced by failing to check for those errors.

#### Parameter types

Another problem you may already have encountered in dealing with endpoint
parameters is their type. Consider this simple implementation of the slides
endpoint:

    let $deck := xdmp:get-request-field("deck")
    let $slideno := xdmp:get-request-field("num")
    return
      doc($deck)/slides/slide[$slideno]

Even if you get the right document with `$deck`, you're still going to
get a type error because `$slideno` is a string. Rather than trying to
remember to do all of the type casting in your endpoint, and
addressing the errors potentially raised by those casts, we can
augment the description:

<pre>&lt;request uri="^/slides/(.+?)/(\d+)$" endpoint="/slides.xqy">
  &lt;uri-param name="deck">$1.xml&lt;/uri-param>
  &lt;uri-param name="num" <b>as="decimal"</b>>$2&lt;/uri-param>
&lt;/request></pre>

Now consider the analagous simple implementation:

    let $params := rest:parse-options($request)
    let $deck := map:get($params, "deck")
    let $slideno := map:get($params, "num")
    return
      doc($deck)/slides/slide[$slideno]

This code *will* work because `$slideno` will be a decimal. As before, you
get error detection for free. If someone manages to call this endpoint with a
`num` parameter that isn't a decimal, the `rest:parse-options()` call will
raise the error for you.

### Supporting additional parameters

You aren't limited to just parameters parsed from the URI. Suppose we augment
the `slides.xqy` module to support a "`theme`" parameter. We can simply add that
to the description:

    <request uri="^/slides/(.+?)/(\d+)$" endpoint="/slides.xqy">
      <uri-param name="deck">$1.xml</uri-param>
      <uri-param name="num" as="decimal">$2</uri-param>
      <param name="theme"/>
    </request>

Now the rewriter and the endpoint will both allow a `theme` parameter.

#### Required parameters

You can make the theme parameter required:

      <param name="theme" required="true"/>

in which case a request URI that doesn't have a `theme` will not match, and an
attempt to call the endpoint without a `theme` will raise an error.

#### Default values

Alternatively, you can provide a default value:

      <param name="theme" default="hires"/>

#### Specifying a list of values

For parameters like `theme`, you may want to specify a delimited list of values
rather than a type. You can do that too:

      <param name="theme" values="hires|lowres|mobile|bw" default="hires"/>

#### Repeatable parameters

Finally, to round out the options on parameter handling, you can also mark
a parameter as repeatable. Without stretching our running "slides" example too far,
let's say you wanted to allow a `css` parameter to specify additional stylesheets
for a particular slide. You might want to allow more than one, so you could add
a `css` parameter like this:

      <param name="css" repeatable="true"/>

In the rewriter, this would allow any number of `css` parameters. In the endpoint,
there'd be a single `css` key in the parameters map but its value would be a list.

#### Matching in parameters

We have one more trick up our sleeves with respect to parameters. Sometimes it's
useful to be able to perform the sort of match and replace operations on parameter
values that we can perform on parts of the URI. Suppose, for example, that you've
got a parameter that will contain an internet media type, you can extract part of
that value using `match`:

    <param name="format" match="^application/(.*?)(\+xml)?$">$1</param>

This will translate the `format=application/xslt+xml` to `format=xslt`.

You can use this feature to rename parameters as well:

    <param name="lang" from="format" match="^application/(.*?)(\+xml)?$">$1</param>

This will translate the `format=application/xslt+xml` to `lang=xslt`.

There's no facility for more complex processing, combining multiple parameters and
such.

N.B. If you combine matching in parameters with validation, make sure that you
validate against the *transformed* value. For example, this parameter will
*never* match:

    <param name="test" values="foo|bar" match="^(.+)$">baz-$1</param>

Instead, write it this way:

    <param name="test" values="baz-foo|baz-bar" match="^(.+)$">baz-$1</param>

In other words, the value that is validated is the *transformed* value.

### Matching multiple URIs

There's no rule in the URI rewriter that says only a single request can be specified
for a given endpoint. In the rules we've looked at so far for the "slides" example,
we're only matching a request for a single slide. Suppose we wanted another rule for
presenting the "title page" slide. One reasonable format for that URI would be to simply
leave off the trailing slide number. So `/slides/uc11` would display the title page
slide. We can support that with two rules:

    <options xmlns="http://marklogic.com/appservices/rest">
      <request uri="^/slides/(.+?)/(\d+)$" endpoint="/slides.xqy">
        <uri-param name="slides">$1.xml</uri-param>
        <uri-param name="num" as="decimal">$2</uri-param>
      </request>
      <request uri="^/slides/(.+?)/?$" endpoint="/slides.xqy">
        <uri-param name="slides">$1.xml</uri-param>
      </request>
    </options>

If the request doesn't have a number, it won't match the first request, but will
match the second. In this case, you simply have to make sure that the `/slides.xqy` endpoint
uses a `request` that will validate all of the possible rewrites.

To simplify earlier examples, I omitted the `<options>` element. In practice the rewriter
will have many `request`s to consider and they're grouped in an `options` element.

### Other HTTP Verbs

A `request` that doesn't specify any verbs only matches HTTP `GET` requests. If you
want to match other verbs, simply list them:

      <request uri="^/slides/(.+?)/?$" endpoint="/slides.xqy">
        <uri-param name="slides">$1.xml</uri-param>
        <http method="GET"/>
        <http method="POST"/>
      </request>

This request will match (and validate) if the request method is either an HTTP `GET` or
an HTTP `POST`.

### <span id='conditions'>Adding conditions</span>

Adding support for `POST` is a good place to talk about adding conditions. Just because
you want to display slides for anyone doesn't mean you want anyone to be able to change
them.

You can add additional conditions, either in the body of the `request`, in which case they
apply to all verbs, or within a particular verb:

      <request uri="^/slides/(.+?)/?$" endpoint="/slides.xqy">
        <uri-param name="slides">$1.xml</uri-param>
        <http method="GET"/>
        <http method="POST">
          <auth>
            <privilege>http://example.com/privs/editor</privilege>
            <kind>execute</kind>
          </auth>
        </http>
      </request>

With this `request`, only users with the specifed execute privilege can `POST` to
that URI. If a user without that privilege attempts to post, this request won't match
and control will fall through to the next request. In this way, you can provide fallbacks
if you wish.

In a rewriter, failing to match a condition causes the request not to match. In an endpoint,
failing to match a condition raises an error.

#### Authentication

As shown in the example above, the `auth` condition tests for the specified privilege:

<pre>&lt;auth>
  &lt;privilege><em>privilege-uri</em>&lt;/privilege>
  &lt;kind><em>kind</em>&lt;/kind>
&lt;/auth></pre>

The privilege can be any specified [execute or URI privilege][3]. If unspecified,
`kind` defaults to `execute`.

#### <span id="accept-headers">Accept headers</span>

When a user agent requests a URI, it can also specify the kinds of responses that it is
able to accept. These are specified in terms of [media types][4]. You can specify the
media type(s) that are acceptable with the `accept` header:

<pre>&lt;accept>application/json&lt;/accept></pre>

A `request` that specifies the `accept` shown above will only match user agent
requests that can accept JSON responses.

#### User agent

You can also match on the [user agent][5] string:

<pre>&lt;user-agent>ELinks&lt;/user-agent></pre>

A `request` that specifies the `user-agent` shown above will only match user agents
that identify as the [ELinks][6] browser.

#### User-defined functions

The `function` condition gives you the ability to test for arbitrary
conditions. By specifying the namespace, localname, and module of a
function, you can execute arbitrary code:

<pre>&lt;function ns="http://example.com/module" apply="my-function" at="utils.xqy"/></pre>

A `request` that specifies the `function` shown above will only match requests
for which the specified function returns `true`. The function will be passed
the URI string and the `function` condition element.

#### And

An `and` condition must contain only conditions. It returns true if
and only if all of its child conditions return `true`.

    <and>
      ...conditions...
    </and>

There is no guarantee that conditions will be evaluated in any
particular order or that all conditions will be evaluated.

If more than one condition is present at the top level in a `request`, they
are treated as they occurred in an `and`.

#### Or

An `or` condition must contain only conditions. It returns true if and
only if at least one of its child conditions return `true`.

    <or>
      ...conditions...
    </or>

There is no guarantee that conditions will be evaluated in any
particular order or that all conditions will be evaluated.

### User extensibility

By default, the rewriter and endpoint parser will reject any request that
includes additional, user-specified parameters. Sometimes you may want to
write an endpoint that allows arbitrary parameters specified by the user.
To enable this behavior, you can specify `user-params="allow"` on
the `request` (or on the `http` method or even the parent `options` element).
The value inherits down, but can be overridden at any level.

If you specify the value `"ignore"`, then extra parameters will be silently
ignored.

The only other legal value, `"forbid"`, is the default.

# REST endpoint library

The REST endpoint library is accessed by importing it:

    import module namespace rest="http://marklogic.com/appservices/rest"
           at "/MarkLogic/appservices/utils/rest.xqy";

It contains the functions described in the sections below.

Because it's convenient to reuse the endpoint description in both the rewriter
and the individual modules, it's often convenient to describe them in a separate
module, like this:

    xquery version "1.0-ml";
    
    module namespace endpoints="http://example.com/ns/endpoints";
    
    declare namespace rest="http://marklogic.com/appservices/rest";
    
    declare default function namespace "http://www.w3.org/2005/xpath-functions";
    
    declare option xdmp:mapping "false";
    
    declare variable $endpoints:ENDPOINTS as element(rest:options)
      := <options xmlns="http://marklogic.com/appservices/rest">
           ... your endpoint descriptions go here ...
         </options>;
    
    declare function endpoints:options()
    as element(rest:options)
    {
      $endpoints:ENDPOINTS
    };
    
    declare function endpoints:request(
      $module as xs:string)
    as element(rest:request)?
    {
      ($endpoints:ENDPOINTS/rest:request[@endpoint = $module])[1]
    };

The examples below follow this pattern, but you're not required to do so.
If you prefer, you can simply put the `options` in your rewriter and individual
`request` elements in your endpoints.

## rest:rewrite()

The `rest:rewrite()` function is used in the URL rewriter to map the incoming
request to the endpoint that supports it. A typical `rewriter.xqy` module looks
like this:

    xquery version "1.0-ml";
    
    import module namespace rest="http://marklogic.com/appservices/rest"
           at "/MarkLogic/appservices/utils/rest.xqy";
    
    import module namespace endpoints="http://example.com/ns/endpoints"
           at "endpoints.xqy";
    
    declare default function namespace "http://www.w3.org/2005/xpath-functions";
    
    declare option xdmp:mapping "false";
    
    let $rewrite := rest:rewrite(endpoints:options())
    return
      if (empty($rewrite))
      then
        $uri
      else
        $rewrite

The default, one-argument form of `rest:rewrite()` takes all of the relevant
parameters (URI, HTTP request method, accept headers, and user parameters) from
the environment. There are other entry points that provide more control if that's
desirable.

## rest:process-request()

The `rest:process-request()` function is used in the endpoint main
module to parse the incoming request against the options. It returns a
map that contains all of the parameters as typed values. Processing
the request also checks all of the assocaited conditions and will
raise an error if any condition is not met.

A typical main module looks like this:

    xquery version "1.0-ml";
    
    import module namespace rest="http://marklogic.com/appservices/rest"
           at "/MarkLogic/appservices/utils/rest.xqy";
    
    import module namespace endpoints="http://example.com/ns/endpoints"
           at "endpoints.xqy";
    
    declare default function namespace "http://www.w3.org/2005/xpath-functions";
    
    declare option xdmp:mapping "false";
    
    try {
      let $params := rest:process-request(endpoints:request('/thismodule.xqy'))
      return
        ...your endpoint code goes here...
    } catch ($e) {
      rest:report-error($e)
    }

If the request is processed successfully, you know that all of the conditions have
been met and the `$params` map contains all of the parameters. If not, an error
will occur which you can catch and process. See [Handling errors](#errors).

## rest:check-options()

Proper functioning of the REST endpoint library *depends on* the correctness of the
descriptions used. The `rest:check-options()` method takes an `options` node and returns
a report of the problems found. If this function *does not* return an empty sequence,
you have made a mistake and the library will not perform reliably.

## rest:check-request()

Proper functioning of the REST endpoint library *depends on* the correctness of the
descriptions used. The `rest:check-request()` method takes a `request` node and returns
a report of the problems found. If this function *does not* return an empty sequence,
you have made a mistake and the library will not perform reliably.

## rest:report-error()

The `rest:report-error()` function is a convenience function for transforming
`error:error` nodes into HTML. See [Handling errors](#errors).

## Low level functionality

The REST endpoint library exposes a few additional, low-level functions. These may
be useful in more complex applications that need to perform sophisticated processing
on requests or implement their own rewriting strategies.

### rest:matching-request()

Unlike, `rest:rewrite()` which returns the rewrite URI, `rest:matching-request()` returns
the `request` element that matches.

Note that the rewrite URI is composed from both the `request` element and the request
environment, including additional parameters, so it's not possible to construct the rewrite
URI solely from the `request`.

### rest:test-request-method()

The `rest:test-request-method()` function tests a `request` against
the `xdmp:get-request-method()`. It returns an empty sequence if the
test passes and raises an error otherwise.

### rest:test-conditions()

The `rest:test-conditions()` function tests all of the
[conditions](#conditions) of a request. It returns an empty sequence
if the test passes and raises an error otherwise.

### rest:get-acceptable-types()

The `rest:get-acceptable-types()` function returns a list of [media types](#accept-headers).
These are the media types that are the intersection of what the endpoint description
claims it can produce and what the user agent claimed it could accept.
They're returned in preference order.

### rest:get-raw-query-params()

The `rest:get-raw-query-params()` function returns a map of all the
query parameters. This *does not* include the parameters that would be
derived from matching the URI string. The parameters returned by this
function are all strings, they have not been type checked.

## <span id="errors">Handling errors</span>

The REST endpoint library includes a `rest:report-error()` function
that performs a simple translation of MarkLogic Server error markup to
HTML. You can invoke it in a module to report errors:

    try {
      let $params := rest:process-request($request)
      return
        ...the non-error case...
    } catch ($e) {
      rest:report-error($e)
    }

If the user agent making the request accepts `text/html`, a simple HTML-formatted
response is returned. Otherwise, the raw error XML is returned.

You can also use this function in [an error handler][7] to process all of the
errors for a particular application.

## Handling redirects

The URL rewriter translates the requested URI into a new URI for
dispatching *within the server*. The user agent making the request is totally
unaware of this translation.
As REST APIs mature and expand, it's sometimes useful to respond to a
request by telling the user agent to reissue the request at a new URI.
This is called redirection.

For example, suppose we decide to change the URI pattern for slides from
`/slides/`_deck_`/`_number_ to `/presentations/`_deck_`/`_number_. If someone
makes a request for a `/slides/` URI, we want to use redirection to tell the
user agent they're using to reissue the request to the equivalent `/presentations/` URI.
(Browser users can tell this has happened because the URI in their address bar
will change; this means if they bookmark the URI, they'll be bookmarking the new,
correct URI, not the old, incorrect one.)

You can support redirects by adding a `redirect.xqy` module like this one to
your application:

    xquery version "1.0-ml";
    
    import module namespace rest="http://marklogic.com/appservices/rest"
           at "/MarkLogic/appservies/utils/rest.xqy";
    
    declare default function namespace "http://www.w3.org/2005/xpath-functions";
    
    declare option xdmp:mapping "false";
    
    declare variable $request as element(rest:request)
      := <request xmlns="http://marklogic.com/appservices/rest" user-params="allow">
           <param name="__ml_redirect__" as="string" required="true"/>
         </request>;
    
    try {
      let $params  := rest:process-request($request)
      let $rparams := for $key in map:keys($params)
                      where $key != "__ml_redirect__"
                      return
                        for $value in map:get($params, $key)
                        return
                          concat($key,"=",$value)
      let $ruri    := map:get($params, "__ml_redirect__")
      return
        if (empty($rparams))
        then
          $ruri
        else
          concat($ruri, "?", string-join($rparams, "&amp;"))
    } catch ($e) {
      rest:report-error($e)
    }

and then using `request` elements like this to perform the redirect:

    <request uri="^/slides/(.*)$" endpoint="/redirect.xqy" user-params="allow">
      <uri-param name="__ml_redirect__">/presentations/$1</uri-param>
    </request>

You can employ as many redirects as you want through the same `redirect.xqy` module
by changing the value of the `__ml_redirect__` parameter. (In the unlikely event that
your application needs a parameter with that name, simple change it to something else
in both the module and each request.)

## Handling OPTIONS

One of the nice things about having a declarative syntax for endpoint
descriptions is the ability to interrogate those definitions for other
purposes. For example, one could imagine automating some aspects of
unit testing based on the ability to find the description for an
endpoint.

You can implement this using the REST endpoint library by supporting the
OPTIONS method. Here's a very simple `options.xqy` module that will return
the `request` associated with a particular URI.

    xquery version "1.0-ml";
    
    import module namespace rest="http://marklogic.com/appservices/rest"
           at "rest.xqy";
    
    import module namespace endpoints="http://example.com/ns/endpoints"
           at "endpoints.xqy";
    
    declare default function namespace "http://www.w3.org/2005/xpath-functions";
    
    declare option xdmp:mapping "false";
    
    declare variable $request as element(rest:request)
      := <request xmlns="http://marklogic.com/appservices/rest"
                  uri="^(.*)$" endpoint="/options.xqy" user-params="allow">
           <uri-param name="__ml_options__">$1</uri-param>
           <http method="OPTIONS"/>
         </request>;
    
    try {
      let $params  := rest:process-request($request)
      let $ruri    := map:get($params, "__ml_options__")
      return
        <options xmlns="http://marklogic.com/appservices/rest">
          { if ($ruri = "/")
            then
              endpoints:options()/rest:request
            else
              rest:matching-request(endpoints:options(), $ruri, "GET")
          }
        </options>
    } catch ($e) {
      rest:report-error($e)
    }

Note that if the request URI is `/`, this module will return the entire
`options` element, exposing the complete set of endpoints. For consistency, even
a single request is therefore wrapped in an `options` node.

Because a single description can match different HTTP methods, possibly with different
parameters, when the URI is not `/`, the request is treated as a `GET` for the purposes
of finding the `request`.

You can use it by adding the following request to the *end* of your options:

    <request uri="^(.+)$" endpoint="/options.xqy" user-params="allow">
      <uri-param name="__ml_options__">$1</uri-param>
      <http method="OPTIONS"/>
    </request>

Obviously, if some earlier request directly supports `OPTIONS` then it will have
priority for that resource.

Translating the `options` node dynamically into something more widely used, such as
[WADL][8], is an exercise left to the reader for the moment.

<div id="slides">
<hr>
</div>

# The Slides Example

To illustrate the points described above, this project includes a complete example.

[1]: http://docs.marklogic.com/4.2doc/docapp.xqy#display.xqy?fname=http://pubs/4.2doc/xml/dev_guide/appserver-control.xml%2313050
[2]: http://www.jenitennison.com/blog/node/151
[3]: http://docs.marklogic.com/4.2doc/docapp.xqy#display.xqy?fname=http://pubs/4.2doc/xml/dev_guide/appserver-control.xml%2313050
[4]: http://en.wikipedia.org/wiki/Internet_media_type
[5]: http://en.wikipedia.org/wiki/User_agent
[6]: http://en.wikipedia.org/wiki/ELinks
[7]: http://docs.marklogic.com/4.2doc/docapp.xqy#display.xqy?fname=http://pubs/4.2doc/xml/dev_guide/appserver-control.xml%2313050
[8]: http://en.wikipedia.org/wiki/Web_Application_Description_Language
[9]: http://en.wikipedia.org/wiki/RESTful#RESTful_web_services
[10]: http://en.wikipedia.org/wiki/XQuery
