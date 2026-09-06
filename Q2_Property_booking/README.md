# Property Listing & Booking System (gRPC + Ballerina)

Distributed platform for the Ministry of Tourism: Hosts manage property
listings, Guests browse/search/book them. Built on the same
`bal grpc` project layout used in the course template (`service/` and
`client/` are independent Ballerina packages that share the generated
`property_booking_pb.bal` stub).

## Files

- `property_booking.proto` — the contract (source of truth). Defines all
  8 required RPCs plus a few extra fields (`host_id`, `email`,
  `min_price`/`max_price` filters, `nights`, status/message fields) to
  make the system more useful end-to-end.
- `service/property_booking_pb.bal`, `client/property_booking_pb.bal` —
  the Ballerina stub generated from the `.proto` (client stub, server
  skeleton types, and the serialized `FileDescriptorProto` used by
  `@grpc:Descriptor`). Identical in both packages, as `bal grpc`
  produces.
- `service/property_booking_service.bal` — the server: in-memory
  `table`s for properties/users/cart/bookings, plus all 8 remote
  functions.
- `client/property_booking_service_client.bal` — an interactive CLI
  client exercising every RPC, including the client-streaming
  `create_users` call and the server-streaming
  `list_available_properties` call.

> Note: this environment has no `bal`/`protoc` toolchain available, so
> `property_booking_pb.bal` was produced by constructing the exact same
> `FileDescriptorProto` structure `bal grpc` would emit (via Python's
> `protobuf` library, matching field numbers/types/json_names against
> the `.proto` file) and hand-writing the client stub/record types that
> follow from it, using the reference `car_rental_pb.bal` in the
> starter template as the structural pattern. Regenerating this file
> with `bal grpc --input property_booking.proto --output <dir>` (once
> you have the Ballerina distribution installed) will produce an
> equivalent file and is the recommended way to refresh it after any
> `.proto` change.

## Design decisions worth knowing about

- **`add_property`**: if the caller leaves `property_id` empty, the
  server mints one (`PROP-<n>`). Status defaults to `AVAILABLE` if not
  supplied.
- **`update_property`**: the whole `Property` record (keyed by
  `property_id`) is sent and replaces the stored row — same pattern as
  the reference `update_car`.
- **`remove_property`**: "the host's region" is interpreted as the
  `location` of the property being removed; the response lists the
  properties still available in that same location after the delete.
- **`list_available_properties`**: only `AVAILABLE` properties are
  streamed; `location` is an exact-match filter and `min_price`/
  `max_price` are inclusive bounds, all optional (0/blank = no filter).
- **`book_property`**: validates the date format and that check-out is
  after check-in, confirms the property is currently available, then
  stages the request in a `cartTable` keyed by `(guest_id,
  property_id)` — one pending request per guest/property pair.
- **`confirm_booking`**: looks up the guest's cart entry, re-validates
  the property is available, checks for date-range overlaps against
  already-confirmed bookings for that property, computes
  `nights × price_per_night`, stores a `BookingConfirmation`, and
  removes the entry from the cart. Date math is done with a
  self-contained day-count function (Howard Hinnant's "days from
  civil" algorithm) so no external date library is required.
- **Concurrency**: all reads/writes of the shared `table`s are wrapped
  in `lock { ... }` blocks so concurrent gRPC calls (e.g. two guests
  booking at once) can't interleave a read-modify-write. Streaming
  responses are built into a plain array inside a `lock` and streamed
  to the client afterwards, so the lock isn't held for the lifetime of
  the stream.

## Running it

```bash
# terminal 1
cd service
bal run

# terminal 2
cd client
bal run
```

The server listens on `localhost:9090`. The client is an interactive
menu (Host / Guest) that exercises every operation, including a "bulk
register users" option that streams however many `User` records you
enter, and a "list available properties" option that consumes the
server-streamed results.
