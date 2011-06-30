xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare variable $redirected as xs:string? := xdmp:get-request-field("redirected");

<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>REST Library Unit Tests</title>
  </head>
  <body>
    <h1>REST Library Unit Tests</h1>
    { if (empty($redirected))
      then
        <div>
          <p>This directory contains the REST library unit tests.</p>
          <p>To run them:</p>
          <ol>
            <li>Change the <b>url rewriter</b> for this server.
            <ul>
              <li>Either:
              <ul>
                <li>Change the <b>url rewriter</b> for the server you're currently using
                to <code>/tests/rewriter.xqy</code></li>
              </ul>
              </li>
              <li>Or setup a second server for testing:
                <ul>
                  <li>Use any <b>server name</b> and <b>port</b> of your choosing.</li>
	          <li>Point the server <b>root</b> at the same place
                      (<em>your-repo-dir</em><code>/MLS</code>).</li>
                  <li>Make sure that the <b>url rewriter</b> is set to <code>/tests/rewriter.xqy</code></li>
                </ul>
              </li>
            </ul>
            The disadvantage of the first option is that it will break the slides and other examples.
            </li>
            <li>Edit <code>tests.xqy</code>:
            <ul>
              <li>In the declaration for <code>$tests:unit-tests</code>, change
              <code>&lt;server-root&gt;http://localhost:8021&lt;/server-root&gt;</code>
              so that it points at your server root. Note that the value <em>does not</em>
              end with a slash.</li>
              <li>Change the <code>username</code> and <code>password</code> elements as appropriate,
              or just delete them if you set <b>authentication</b> to <code>application-level</code> on
              the server.</li>
            </ul>
            </li>
            <li>Run the tests by point your browser at <em>server-root</em><code>/run-tests</code>.
            </li>
          </ol>
        </div>
      else
        <div>
          <p>This directory contains the REST library unit tests.</p>
          <p>Congratulations, your test server seems to be setup correctly.</p>
          <p>You can <a href="/tests/run-tests">run the tests</a> now.</p>
        </div>
    }
  </body>
</html>
