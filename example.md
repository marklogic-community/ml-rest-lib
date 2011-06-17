# The Slides Example

To illustrate the points described above, this project includes a complete example.

FIXME: improve these docs

I've tried to arrange things so that the example gets in the way as little as possible.
Here's the setup:

1. Create a new HTTP application server in MarkLogic.
2. We're going to write some documents to `/slides/` in the database attached to that server, so point it at a database you don't care about, perhaps be creating a new one for it.
3. Make the `MLS` directory from this project the root of that server and put it on any port you'd like.
4. Set the URI rewriter for that server to /example/rewriter.xqy

If you load that server up in your browser, you should get a message
about having no slides. You can fix that by running
`/setup-database.xqy`.

The only other thing you need to do is copy `/Config/rest.xsd` into
your server's `Config` directory. Alternatively, load `rest.xsd` into
the Schemas database associated with your database.

If you reload the server now, you'll find a couple of slides examples
that contain some more documentation.
