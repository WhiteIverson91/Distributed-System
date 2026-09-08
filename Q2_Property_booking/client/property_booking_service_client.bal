import ballerina/io;

Property_Booking_ServiceClient ep = check new ("http://localhost:9090");

// --- Host Menu ---
function hostMenu() {
    io:println("\n--- Host Menu ---");
    io:println("1. Add Property");
    io:println("2. Update Property");
    io:println("3. Remove Property");
    io:println("4. List Available Properties");
    io:println("5. Register Users (bulk, streaming)");
    io:println("6. Back to Main Menu");
}

// --- Guest Menu ---
function guestMenu() {
    io:println("\n--- Guest Menu ---");
    io:println("1. View Available Properties");
    io:println("2. Search Property by ID");
    io:println("3. Book a Property");
    io:println("4. Confirm Booking");
    io:println("5. Back to Main Menu");
}

// --- Main Function ---
public function main() returns error? {
    io:println("-----# Welcome to the Ministry of Tourism Property Booking Service #-----");

    while true {
        io:println("\nEnter your role: \na. Host\nb. Guest\nc. Exit");
        string userSelection = io:readln();

        if userSelection == "a" {
            check hostSelection();
        } else if userSelection == "b" {
            check guestSelection();
        } else if userSelection == "c" {
            io:println("Exiting Property Booking Service. Goodbye!");
            break;
        } else {
            io:println("Invalid response. Please enter a, b, or c.");
        }
    }
}

// --- Host Actions ---
function hostSelection() returns error? {
    while true {
        hostMenu();
        io:println("Enter your choice: ");
        int choice = check int:fromString(io:readln());

        match choice {
            1 => {
                check addProperty();
            }
            2 => {
                check updateProperty();
            }
            3 => {
                check removeProperty();
            }
            4 => {
                check listAvailableProperties();
            }
            5 => {
                check registerUsers();
            }
            6 => {
                io:println("Returning to Main Menu...");
                break;
            }
            _ => {
                io:println("Invalid choice. Try again.");
            }
        }

        return;
    }
}

// --- Guest Actions ---
function guestSelection() returns error? {
    while true {
        guestMenu();
        io:println("Enter your choice: ");
        int choice = check int:fromString(io:readln());

        match choice {
            1 => {
                check listAvailableProperties();
            }
            2 => {
                check searchProperty();
            }
            3 => {
                check bookProperty();
            }
            4 => {
                check confirmBooking();
            }
            5 => {
                io:println("Returning to Main Menu...");
                break;
            }
            _ => {
                io:println("Invalid choice. Try again.");
            }
        }

        return;
    }
}

// ============================================================
// Host Functions
// ============================================================

function addProperty() returns error? {
    io:println("Enter Property Details:");
    io:println("Host ID: ");
    string host_id = io:readln();
    io:println("Property Name: ");
    string property_name = io:readln();
    io:println("Location: ");
    string location = io:readln();
    io:println("Property Type (APARTMENT/VILLA/ROOM/STUDIO): ");
    string property_type = io:readln();
    io:println("Price Per Night: ");
    float price_per_night = check float:fromString(io:readln());
    io:println("Status (AVAILABLE/UNAVAILABLE): ");
    string status = io:readln();

    AddPropertyRequest req = {
        property: {property_id: "", host_id, property_name, location, property_type, price_per_night, status}
    };
    AddPropertyResponse res = check ep->add_property(req);
    io:println(res.message, " -> Property ID: ", res.property_id);
}

function updateProperty() returns error? {
    io:println("Enter Property ID to Update: ");
    string property_id = io:readln();
    io:println("Host ID: ");
    string host_id = io:readln();
    io:println("New Property Name: ");
    string property_name = io:readln();
    io:println("New Location: ");
    string location = io:readln();
    io:println("New Property Type: ");
    string property_type = io:readln();
    io:println("New Price Per Night: ");
    float price_per_night = check float:fromString(io:readln());
    io:println("New Status (AVAILABLE/UNAVAILABLE): ");
    string status = io:readln();

    UpdatePropertyRequest req = {
        property: {property_id, host_id, property_name, location, property_type, price_per_night, status}
    };
    UpdatePropertyResponse res = check ep->update_property(req);
    io:println(res.status, ": ", res.message);
}

function removeProperty() returns error? {
    io:println("Enter Property ID to Remove: ");
    string property_id = io:readln();
    io:println("Host ID: ");
    string host_id = io:readln();

    RemovePropertyRequest req = {property_id, host_id};
    RemovePropertyResponse res = check ep->remove_property(req);
    io:println("Remaining properties in that region:");
    foreach var p in res.properties {
        io:println(" - ", p.property_id, " | ", p.property_name, " | ", p.location, " | $", p.price_per_night);
    }
}

function registerUsers() returns error? {
    Create_usersStreamingClient streamingClient = check ep->create_users();

    io:println("How many users would you like to register? ");
    int n = check int:fromString(io:readln());

    int i = 0;
    while i < n {
        io:println("--- User ", i + 1, " ---");
        io:println("User ID: ");
        string user_id = io:readln();
        io:println("Name: ");
        string name = io:readln();
        io:println("Role (HOST/GUEST): ");
        string role = io:readln();
        io:println("Email: ");
        string email = io:readln();

        check streamingClient->sendUser({user_id, name, role, email});
        i += 1;
    }

    check streamingClient->complete();
    CreateUsersResponse? res = check streamingClient->receiveCreateUsersResponse();
    if res is CreateUsersResponse {
        io:println(res.message, " (", res.users_created, " users created)");
    }
}

// ============================================================
// Guest Functions
// ============================================================

function listAvailableProperties() returns error? {
    io:println("Filter by location (leave blank for any): ");
    string location = io:readln();
    io:println("Minimum price (0 for no minimum): ");
    float min_price = check float:fromString(io:readln());
    io:println("Maximum price (0 for no maximum): ");
    float max_price = check float:fromString(io:readln());

    ListAvailablePropertiesRequest req = {location, min_price, max_price};
    stream<Property, error?> propertyStream = check ep->list_available_properties(req);

    io:println("Available Properties:");
    check propertyStream.forEach(function(Property p) {
        io:println(" - ", p.property_id, " | ", p.property_name, " | ", p.location,
                " | ", p.property_type, " | $", p.price_per_night, "/night");
    });
}

function searchProperty() returns error? {
    io:println("Enter Property ID to Search: ");
    string property_id = io:readln();

    SearchPropertyRequest req = {property_id};
    SearchPropertyResponse res = check ep->search_property(req);

    io:println("Search Result: ", res.message);
    if res.message == "FOUND" {
        Property p = res.property;
        io:println(" - ", p.property_id, " | ", p.property_name, " | ", p.location,
                " | ", p.property_type, " | $", p.price_per_night, "/night | ", p.status);
    }
}

function bookProperty() returns error? {
    io:println("Enter Property ID: ");
    string property_id = io:readln();
    io:println("Enter Your Guest ID: ");
    string guest_id = io:readln();
    io:println("Check-in Date (YYYY-MM-DD): ");
    string check_in = io:readln();
    io:println("Check-out Date (YYYY-MM-DD): ");
    string check_out = io:readln();

    BookPropertyRequest req = {property_id, guest_id, check_in, check_out};
    BookPropertyResponse res = check ep->book_property(req);
    io:println(res.status, ": ", res.message);
}

function confirmBooking() returns error? {
    io:println("Enter Your Guest ID: ");
    string guest_id = io:readln();
    io:println("Enter Property ID to Confirm: ");
    string property_id = io:readln();

    ConfirmBookingRequest req = {guest_id, property_id};
    ConfirmBookingResponse res = check ep->confirm_booking(req);

    io:println(res.status, ": ", res.message);
    if res.status == "CONFIRMED" {
        BookingConfirmation b = res.booking;
        io:println("Booking ID: ", b.booking_id);
        io:println("Property: ", b.property_id, " | ", b.check_in, " -> ", b.check_out,
                " | ", b.nights, " night(s) | Total: $", b.total_cost);
    }
}
