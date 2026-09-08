import ballerina/grpc;
import ballerina/io;

// ============================================================
// In-memory data store (Ballerina tables keyed by natural id)
// ============================================================

table<Property> key(property_id) propertiesTable = table [
    {property_id: "PROP-001", host_id: "host01", property_name: "Ocean Breeze Apartment", location: "Windhoek", property_type: "APARTMENT", price_per_night: 75.0, status: "AVAILABLE"},
    {property_id: "PROP-002", host_id: "host01", property_name: "Desert View Studio", location: "Windhoek", property_type: "STUDIO", price_per_night: 45.0, status: "AVAILABLE"},
    {property_id: "PROP-003", host_id: "host02", property_name: "Coastal Villa", location: "Swakopmund", property_type: "VILLA", price_per_night: 150.0, status: "AVAILABLE"},
    {property_id: "PROP-004", host_id: "host02", property_name: "Dune Lodge Room", location: "Swakopmund", property_type: "ROOM", price_per_night: 60.0, status: "UNAVAILABLE"}
];

table<User> key(user_id) usersTable = table [
    {user_id: "host01", name: "Anna Nghipangelwa", role: "HOST", email: "anna@example.com"},
    {user_id: "host02", name: "Josef Amutenya", role: "HOST", email: "josef@example.com"},
    {user_id: "guest01", name: "Maria Shikongo", role: "GUEST", email: "maria@example.com"}
];

// Temporary "booking cart" - one pending request per (guest, property) pair.
table<BookingCartItem> key(guest_id, property_id) cartTable = table [];

// Finalized bookings.
table<BookingConfirmation> key(booking_id) bookingsTable = table [];

// Simple counters used to mint new ids.
int propertyCounter = 100;
int bookingCounter = 1000;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: PROPERTY_BOOKING_DESC}
service "Property_Booking_Service" on ep {

    // ------------------------------------------------------------------
    // ADD PROPERTY (simple RPC) - Host registers a new listing
    // ------------------------------------------------------------------
    remote function add_property(AddPropertyRequest req) returns AddPropertyResponse|error {
        Property incoming = req.property;
        string newId = incoming.property_id;

        lock {
            if newId == "" {
                propertyCounter += 1;
                newId = "PROP-" + propertyCounter.toString();
            }
            Property toStore = {
                property_id: newId,
                host_id: incoming.host_id,
                property_name: incoming.property_name,
                location: incoming.location,
                property_type: incoming.property_type,
                price_per_night: incoming.price_per_night,
                status: incoming.status == "" ? "AVAILABLE" : incoming.status
            };
            if propertiesTable.hasKey(newId) {
                propertiesTable.put(toStore);
            } else {
                propertiesTable.add(toStore);
            }
        }

        io:println("Property added: ", newId);
        return {property_id: newId, message: "Property registered successfully"};
    }

    // ------------------------------------------------------------------
    // CREATE USERS (client-side streaming) - bulk-register Hosts/Guests
    // ------------------------------------------------------------------
    remote function create_users(stream<User, error?> clientStream) returns CreateUsersResponse|error {
        int count = 0;

        error? e = clientStream.forEach(function(User user) {
            lock {
                if usersTable.hasKey(user.user_id) {
                    usersTable.put(user.clone());
                } else {
                    usersTable.add(user.clone());
                }
            }
            count += 1;
            io:println("User registered: ", user.name, " (", user.role, ")");
        });

        if e is error {
            return e;
        }
        return {message: "All users registered successfully", users_created: count};
    }

    // ------------------------------------------------------------------
    // UPDATE PROPERTY (simple RPC) - Host edits price/status/etc.
    // ------------------------------------------------------------------
    remote function update_property(UpdatePropertyRequest req) returns UpdatePropertyResponse|error {
        Property updated = req.property;
        boolean found = false;

        lock {
            if propertiesTable.hasKey(updated.property_id) {
                propertiesTable.put(updated.clone());
                found = true;
            }
        }

        if found {
            io:println("Property updated: ", updated.property_id);
            return {status: "UPDATED", message: "Property updated successfully"};
        }
        return {status: "NOT_FOUND", message: "No property found with id " + updated.property_id};
    }

    // ------------------------------------------------------------------
    // REMOVE PROPERTY (simple RPC) - Host deletes a listing
    // Returns the properties remaining in that host's region (location).
    // ------------------------------------------------------------------
    remote function remove_property(RemovePropertyRequest req) returns RemovePropertyResponse|error {
        Property[] remaining = [];

        lock {
            if propertiesTable.hasKey(req.property_id) {
                Property removed = propertiesTable.get(req.property_id);
                _ = propertiesTable.remove(req.property_id);

                string region = removed.location;
                foreach var p in propertiesTable {
                    if p.location == region {
                        remaining.push(p.clone());
                    }
                }
            }
        }

        io:println("Property removed: ", req.property_id);
        return {properties: remaining};
    }

    // ------------------------------------------------------------------
    // LIST AVAILABLE PROPERTIES (server-side streaming)
    // Optionally filtered by location and/or price range.
    // ------------------------------------------------------------------
    remote function list_available_properties(ListAvailablePropertiesRequest req) returns stream<Property, error?>|error {
        Property[] results = [];

        lock {
            foreach var p in propertiesTable {
                if p.status != "AVAILABLE" {
                    continue;
                }
                boolean matchesLocation = req.location == "" || p.location == req.location;
                boolean matchesMin = req.min_price <= 0.0 || p.price_per_night >= req.min_price;
                boolean matchesMax = req.max_price <= 0.0 || p.price_per_night <= req.max_price;
                if matchesLocation && matchesMin && matchesMax {
                    results.push(p.clone());
                }
            }
        }

        return results.toStream();
    }

    // ------------------------------------------------------------------
    // SEARCH PROPERTY (simple RPC) - lookup by id
    // ------------------------------------------------------------------
    remote function search_property(SearchPropertyRequest req) returns SearchPropertyResponse|error {
        Property? found = ();

        lock {
            if propertiesTable.hasKey(req.property_id) {
                found = propertiesTable.get(req.property_id).clone();
            }
        }

        if found is Property {
            return {property: found, message: "FOUND"};
        }
        return {message: "Not Available"};
    }

    // ------------------------------------------------------------------
    // BOOK PROPERTY (simple RPC) - validate dates & stage in the cart
    // ------------------------------------------------------------------
    remote function book_property(BookPropertyRequest req) returns BookPropertyResponse|error {
        int|error checkInDays = toEpochDays(req.check_in);
        if checkInDays is error {
            return {status: "REJECTED", message: "Invalid check-in date: " + req.check_in};
        }
        int|error checkOutDays = toEpochDays(req.check_out);
        if checkOutDays is error {
            return {status: "REJECTED", message: "Invalid check-out date: " + req.check_out};
        }
        if checkOutDays <= checkInDays {
            return {status: "REJECTED", message: "Check-out date must be after check-in date"};
        }

        boolean propertyAvailable = false;
        lock {
            if propertiesTable.hasKey(req.property_id) {
                Property p = propertiesTable.get(req.property_id);
                propertyAvailable = p.status == "AVAILABLE";
            }
        }
        if !propertyAvailable {
            return {status: "REJECTED", message: "Property does not exist or is not available"};
        }

        lock {
            cartTable.put({
                property_id: req.property_id,
                guest_id: req.guest_id,
                check_in: req.check_in,
                check_out: req.check_out
            });
        }

        io:println("Booking staged in cart for guest ", req.guest_id, " -> ", req.property_id);
        return {status: "ADDED_TO_CART", message: "Booking request added to your cart. Call confirm_booking to finalize."};
    }

    // ------------------------------------------------------------------
    // CONFIRM BOOKING (simple RPC) - finalize a cart entry
    // Re-checks availability + date overlaps, computes cost, clears cart.
    // ------------------------------------------------------------------
    remote function confirm_booking(ConfirmBookingRequest req) returns ConfirmBookingResponse|error {
        BookingCartItem? cartItem = ();
        lock {
            if cartTable.hasKey([req.guest_id, req.property_id]) {
                cartItem = cartTable.get([req.guest_id, req.property_id]).clone();
            }
        }
        if cartItem is () {
            return {status: "REJECTED", message: "No pending booking request found for this property"};
        }
        BookingCartItem item = <BookingCartItem>cartItem;

        int inDays = check toEpochDays(item.check_in);
        int outDays = check toEpochDays(item.check_out);

        Property? propOpt = ();
        lock {
            if propertiesTable.hasKey(item.property_id) {
                propOpt = propertiesTable.get(item.property_id).clone();
            }
        }
        if propOpt is () {
            return {status: "REJECTED", message: "Property no longer exists"};
        }
        Property property = <Property>propOpt;
        if property.status != "AVAILABLE" {
            return {status: "REJECTED", message: "Property is currently unavailable"};
        }

        boolean overlaps = false;
        lock {
            foreach var b in bookingsTable {
                if b.property_id != item.property_id {
                    continue;
                }
                int|error existingIn = toEpochDays(b.check_in);
                int|error existingOut = toEpochDays(b.check_out);
                if existingIn is int && existingOut is int {
                    if inDays < existingOut && existingIn < outDays {
                        overlaps = true;
                    }
                }
            }
        }
        if overlaps {
            return {status: "REJECTED", message: "Property is already booked for overlapping dates"};
        }

        int nights = outDays - inDays;
        float totalCost = <float>nights * property.price_per_night;

        string newBookingId = "";
        lock {
            bookingCounter += 1;
            newBookingId = "BKG-" + bookingCounter.toString();
        }

        BookingConfirmation confirmation = {
            booking_id: newBookingId,
            property_id: item.property_id,
            guest_id: item.guest_id,
            check_in: item.check_in,
            check_out: item.check_out,
            nights: nights,
            total_cost: totalCost,
            status: "CONFIRMED"
        };

        lock {
            bookingsTable.add(confirmation.clone());
            _ = cartTable.remove([item.guest_id, item.property_id]);
        }

        io:println("Booking confirmed: ", newBookingId, " total=", totalCost);
        return {booking: confirmation, status: "CONFIRMED", message: "Booking confirmed successfully"};
    }
}

// ============================================================
// Date helpers (pure integer arithmetic, no external dependency)
// Converts an ISO "YYYY-MM-DD" date into a day count since the
// epoch so ranges can be compared/subtracted safely.
// ============================================================

function toEpochDays(string date) returns int|error {
    if date.length() != 10 || date.substring(4, 5) != "-" || date.substring(7, 8) != "-" {
        return error("Invalid date format, expected YYYY-MM-DD: " + date);
    }
    int year = check int:fromString(date.substring(0, 4));
    int month = check int:fromString(date.substring(5, 7));
    int day = check int:fromString(date.substring(8, 10));
    if month < 1 || month > 12 || day < 1 || day > 31 {
        return error("Invalid date value: " + date);
    }
    return daysFromCivil(year, month, day);
}

// Howard Hinnant's "days from civil" algorithm - proleptic Gregorian
// calendar day count relative to 1970-01-01.
function daysFromCivil(int yearIn, int month, int day) returns int {
    int y = month <= 2 ? yearIn - 1 : yearIn;
    int era = (y >= 0 ? y : y - 399) / 400;
    int yoe = y - era * 400;
    int mAdj = month > 2 ? month - 3 : month + 9;
    int doy = (153 * mAdj + 2) / 5 + day - 1;
    int doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    return era * 146097 + doe - 719468;
}
