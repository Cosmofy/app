# GraphQL geometry `id` field

The Nature service returns geometry objects without an `id` field, and the
deployed Livia GraphQL schema currently defines `Geometry` without `id`.

The app's events query must therefore omit `geometry.id` until the schema is
intentionally expanded and the Nature contract supplies a real identifier.
`GQLGeometry.id` remains optional for compatibility with a future schema
change, but it is not selected by the current query.
