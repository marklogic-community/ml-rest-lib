(: Run once to setup the database with some example content. :)

let $deck1 := <html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Introduction</title>
<link rel="stylesheet" type="text/css" href="slides.css" />
</head>
<body>

<div class="titlepage">
<h1>Introduction</h1>
<p>A Rewriter Example</p>
<p>17 June 2011</p>
</div>

<div class="slide">
<h1>Why</h1>
<ul>
<li>An example rewriter.</li>
<li>Trimmed down from a real-world example that uses DocBook for the slide content.</li>
<li>Demonstrates the REST endpoint library.</li>
</ul>
</div>

<div class="slide">
<h1>What</h1>
<ul>
<li>Presentations are HTML documents.</li>
<li>Each “slide” is a <code>div</code> with a <code>class</code> of “<code>slide</code>”. (The
title page comes from a <code>div</code> with the class “<code>titlepage</code>”).</li>
<li>They're stored in the server with the URI convention <code>/slides/<em>deckname</em>/slides.xml</code>.</li>
</ul>
</div>

<div class="slide">
<h1>How</h1>

<p>A URI of the form:</p>

<ul>
<li>“<code>/slides/<em>deckname</em></code>” is redirected to
“<code>/slides/<em>deckname</em>/</code> (this demonstrates redirection and makes relative
URIs on the title page work correctly).
</li>
<li>“<code>/slides/<em>deckname</em>/</code>” shows the title page.
</li>
<li>“<code>/slides/<em>deckname</em>/<em>nn</em></code>” shows slide “<em>nn</em>” where
“<em>nn</em>” is the decimal slide number (1, 2, 3, …)
</li>
<li>“<code>/slides/<em>deckname</em>/toc</code>” shows an agenda.</li>
</ul>

<p>Any other URI (e.g., for stylesheets, graphics, scripts, etc.) is assumed to
identify a document in the database and that document is returned if
it exists.</p>

<p>As a convenience, completely unrelated to the rewriter, the server
will search “up” the path for documents. For example, a request for
<code>/slides/deck/background.png</code> will be satisfied by the first of
<code>/slides/deck/background.png</code>, or <code>/slides/background.png</code>,
or <code>/background.png</code> that exists.</p>
</div>

</body>
</html>

let $deck2 := <html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Overview</title>
<link rel="stylesheet" type="text/css" href="slides.css" />
</head>
<body>

<div class="titlepage">
<h1>Overview</h1>
<p>Behind the Scenes</p>
<p>17 June 2011</p>
</div>

<div class="slide">
<h1>Introduction</h1>
<p>The following slides briefly describe each of the documents in the example.</p>
</div>

<div class="slide">
<h1><code>default.xqy</code></h1>
<ul>
<li>Handles “<code>/</code>”</li>
<li>Provides a list of available presentations.</li>
</ul>
</div>

<div class="slide">
<h1><code>endpoints.xqy</code></h1>
<ul>
<li>Encapsulates the REST “options” node.</li>
<li>Provides functions to return the options or a particular request</li>
<li>The mechanism for finding the particular request is a bit crude</li>
</ul>

<p>By placing the options node in its own module, we can be sure that the rewriter
and the endpoint will both use the same <code>request</code> elements.</p>
</div>

<div class="slide">
<h1><code>options.xqy</code></h1>
<ul>
<li>Supports the HTTP <code>OPTIONS</code> method</li>
<li>Intended as an example of handling other method</li>
<li>Doesn't actually return anything particularly useful or interesting</li>
</ul>
</div>

<div class="slide">
<h1><code>post.xqy</code></h1>
<ul>
<li>Handles the HTTP <code>POST</code> method</li>
<li>Allows users to upload new presentations or other files</li>
</ul>
</div>

<div class="slide">
<h1><code>redirect.xqy</code></h1>
<ul>
<li>Handles redirection</li>
<li>Requests for “<code>/slides/<em>deckname</em></code>” are redirected to
“<code>/slides/<em>deckname</em>/</code> in order to make relative URIs behave
in the expected way</li>
<li>Requests for “<code>/presentations/<em>deckname</em>…</code>” are redirected to
“<code>/slides/<em>deckname</em>…</code> as another example of redirection
</li>
</ul>
</div>

<div class="slide">
<h1><code>rewriter.xqy</code></h1>
<ul>
<li>The URI rewriter</li>
</ul>
</div>

<div class="slide">
<h1><code>serve.xqy</code></h1>
<ul>
<li>The module that serves up “ordinary” files from the database</li>
</ul>
</div>

<div class="slide">
<h1><code>slides.xqy</code></h1>
<ul>
<li>Handles slide decks</li>
<li>Returns a title page or individual slide depending on parameters</li>
</ul>
</div>

<div class="slide">
<h1><code>setup-database.xqy</code></h1>
<ul>
<li>Loads a couple of presentations and a CSS file into the database</li>
<li>You only have to run this once</li>
<li>Make sure you edit <code>$root</code> at the top of the file before running it</li>
</ul>
</div>

</body>
</html>

let $css := text { "div.nav {
    position: absolute;
    top: 5px;
    right: 5px;
    font-size: 80%;
    height: 0px;
}

div.slide {
    font-size: 200%;
}

div.titlepage {
    font-size: 200%;
}

div.nav a,
div.nav a:visited {
    text-decoration: none;
    color: blue;
}

span.inactive {
    color: #aaaaaa;
}

a,
a:visited {
    color: blue;
}" }

return
  (xdmp:document-insert("/slides/intro/slides.xml", $deck1),
   xdmp:document-insert("/slides/overview/slides.xml", $deck2),
   xdmp:document-insert("/slides/slides.css", $css),
   xdmp:redirect-response("/slides"))
