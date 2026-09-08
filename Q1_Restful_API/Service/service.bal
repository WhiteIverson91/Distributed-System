import ballerina/http;
import ballerina/time;

// Task record represents a small,
// specific job that's part of a WorkOrder
type Task record {
    string taskId;
    string description;
};

// Describes faulty assets, the problem they
// have, and their resolution
type WorkOrder record {
    string orderId;
    string description;
    string status;
    Task[] tasks;
};

// Schedule record represents a regular servicing plan
// or a room/lab booking.
type Schedule record {
    string scheduleId;
    string 'type; // MAINTENANCE, SERVICING, BOOKING, ...
    string dueDate;  // YYYY-MM-DD
    string description;
};

// Component record represents a part
// of an asset, like a hard drive in a
// server or a motor in a printer.
type Component record {
    string compId;
    string name;
    string description;
};

type Asset record {
    string assetTag;
    string name;
    string description;
    string institution;
    string site;
    string status; // AVAILABLE, LOANED_OUT, OCCUPIED, UNDER_MAINTENANCE, DISPOSED
    string dateAcquired;
    Component[] components;
    Schedule[] schedules;
    WorkOrder[] workOrders;
};

// "Component[] components" actually means:
// components is an array that can hold multiple Component records;
// Each element in the array must be a complete Component record (not individual strings);
// Each Component record contains 3 string fields: "compId", "name" and "description"

// Note: "map<Asset> MainDatabase" is a Map that can hold multiple "Asset" records.

// We create the MainDatabase as a Map data structure
// where keys are assetTags and values are Asset records
map<string> Institution= {};
map<Asset> MainDatabase = {
    "OQ-001": {
        assetTag: "OQ-001",
        name: "printer",
        description: "Departmental laser printer",
        institution: "Namibia University of Science and Technology",
        site: "Computing and Informatics - Cyber Security Lab",
        status: "AVAILABLE",
        dateAcquired: "2024-09-05",

        components: [
            {
                compId: "C-001",
                name: "Cartridge",
                description: "Black toner cartridge"
            },
            {
                compId: "C-002",
                name: "Sheet Feeder",
                description: "Automatic paper sheet feeder"
            }
        ],
        schedules: [
            {
                scheduleId: "SCH-001",
                'type: "MAINTENANCE",
                dueDate: "2024-09-06",
                description: "Routine Maintenance Check"
            }
        ],
        workOrders: []
    },
    "VA-002": {
        assetTag: "VA-002",
        name: "Toyota Hilux",
        description: "Departmental transport vehicle",
        institution: "Namibia University of Science and Technology",
        site: "Commerce, Human Sciences and Education - Transport",
        status: "AVAILABLE",
        dateAcquired: "2024-04-12",
        components: [],
        schedules: [],
        workOrders: []
    },
    "OE-003": {
        assetTag: "OE-003",
        name: "Bus",
        description: "Shuttle bus for campus transport",
        institution: "Namibia University of Science and Technology",
        site: "Commerce, Human Sciences and Education - Transport",
        status: "AVAILABLE",
        dateAcquired: "2024-06-12",
        components: [],
        schedules: [],
        workOrders: []
    }
};

service / on new http:Listener(8080) {

    resource function get getAllAssets() returns Asset[] {
        return MainDatabase.toArray();
    }

    resource function get getSpecificAsset(string assetTag) returns Asset?|http:NotFound {
        // Checking if the asset exists using the assetTag passed in the URL
        if MainDatabase.hasKey(assetTag) {
            return MainDatabase[assetTag];
        } else {
            // If the key is not found it returns null/nothing
            return http:NOT_FOUND;
        }
    }

    resource function post newAsset(@http:Payload Asset newAsset) returns Asset|http:Conflict {

        // Checking if asset already exists
        if MainDatabase.hasKey(newAsset.assetTag) {
            return http:CONFLICT;
        }

        // Adding asset to database
        MainDatabase[newAsset.assetTag] = newAsset;

        // Return the newly added asset
        return newAsset;
    }

    // Note on newAsset(): The line MainDatabase[newAsset.assetTag] = newAsset;
    // uses the assetTag as the unique key. It's taking the assetTag value (which
    // is just a small part of the newAsset record) and using it as the label or
    // address for where the entire newAsset record will be stored in the MainDatabase.

    // The dot "." as in newAsset.assetTag is used to access a field or property
    // of a structured data type.

    resource function put updateAsset(@http:Payload Asset updatedAsset) returns Asset|http:NotFound {
        // If updatedAsset has a key that also exists in MainDatabase
        if MainDatabase.hasKey(updatedAsset.assetTag) {
            MainDatabase[updatedAsset.assetTag] = updatedAsset;
            return updatedAsset;
        } else {
            return http:NOT_FOUND;
        }
    }

    // Start Here
    // curl "http://localhost:8080/getAssetsByInstitution?institution=Namibia%20University%20of%20Science%20and%20Technology"

    // Function definition: retrieves assets filtered by institution
    resource function get getAssetsByInstitution(@http:Query string institution) returns Asset[] {

        // Initialize an empty array to store assets belonging to the given institution
        Asset[] filteredAssets = [];
        foreach var [_, asset] in MainDatabase.entries() {
            if asset.institution == institution {
                filteredAssets.push(asset);
            }
        }
        // Return the array of filtered assets
        return filteredAssets;
    }

        resource function get getAssetsBySite(@http:Query string site) returns Asset[] {

        // We initialize an empty array to store assets belonging to the given site
        Asset[] filteredAssets = [];
        foreach var [_, asset] in MainDatabase.entries() {
            if asset.site == site {
                filteredAssets.push(asset);
            }
        }
        // Return the array of filtered assets
        return filteredAssets;
    }

    resource function delete deleteAsset(string assetTag) returns Asset|http:NotFound {
        if MainDatabase.hasKey(assetTag) {
            Asset removedAsset = MainDatabase.remove(assetTag);
            return removedAsset;
        } else {
            return http:NOT_FOUND;
        }
    }

    //retrieve all institutions in the database, for institution management
    resource function get allInstitutions() returns string[] {
       return Institution.toArray();
    }

    //Adding a new institution to the database, for instituion management
    resource function post addInstitution(@http:Payload string name) returns string|http:Conflict {
        if Institution.hasKey(name) {
            return http:CONFLICT;
        }
        Institution[name] = name;
        return name;
    }

    //remove an institution from the database, for institution management
    resource function delete removeInstitution(string name) returns string|http:NotFound{
        if Institution.hasKey(name){
            _ = Institution.remove(name);
            return name;
        } else {
            return http:NOT_FOUND;
        }
    }

    resource function post addComponentToAsset(string assetTag, @http:Payload Component newComponent)
            returns Asset|http:Conflict|http:NotFound {
        if MainDatabase.hasKey(assetTag) {
            Asset existingAsset = <Asset>MainDatabase[assetTag];
            // Checking if the component already exists to avoid duplicates

            foreach var component in existingAsset.components {
                if component.compId == newComponent.compId {
                    return http:CONFLICT; // Component with this compId already exists
                }
            }
            // Add the new component to the existing array
            existingAsset.components.push(newComponent);
            return existingAsset;
        } else {
            return http:NOT_FOUND;
        }
    }

    resource function delete removeComponentFromAsset(string assetTag, string compId)
            returns Component|http:NotFound {
        // First, we check if the asset with the given assetTag exists in the database.
        if MainDatabase.hasKey(assetTag) {
            // Retrieve the asset record from the map. The <Asset> cast is safe
            // because the hasKey() check confirms the key exists.
            Asset existingAsset = <Asset>MainDatabase[assetTag];

            // Initialize a variable to hold the index of the component to remove.
            // A value of -1 indicates the component has not been found yet.
            int indexToRemove = -1;

            // Find the index of the component to remove by iterating through the components array.
            foreach int i in 0 ..< existingAsset.components.length() {
                // If the compId of the current component matches the one provided,
                // we've found our target.
                if existingAsset.components[i].compId == compId {
                    // Store the index of the found component.
                    indexToRemove = i;
                    // Exit the loop immediately to save time.
                    break;
                }
            }
            // After the loop, check if a matching component was found.
            if indexToRemove != -1 {
                // If the component was found, remove it from the array at the stored index.
                Component removed = existingAsset.components.remove(indexToRemove);
                // Return the removed Component record to the client.
                return removed;
            } else {
                // If the component was not found in the asset, return a Not Found error.
                return http:NOT_FOUND; // Component not found
            }
        } else {
            // If the asset itself was not found in the database, return a Not Found error.
            return http:NOT_FOUND; // Asset not found
        }
    }

    resource function post addScheduleToAsset(string assetTag, @http:Payload Schedule newSchedule) returns Asset|error {
        if MainDatabase.hasKey(assetTag) {
            Asset existingAsset = <Asset>MainDatabase[assetTag];

            foreach var schl in existingAsset.schedules {
                if schl.scheduleId == newSchedule.scheduleId {
                    return error("Schedule with id " + newSchedule.scheduleId + " already exists");
                }
            }

            existingAsset.schedules.push(newSchedule);
            return existingAsset;
        } else {
            return error("Asset not found with tag: " + assetTag);
        }
    }

    resource function delete removeScheduleFromAsset(string assetTag, @http:Query string scheduleId) returns Schedule|error {
        if MainDatabase.hasKey(assetTag) {
            Asset existingAsset = <Asset>MainDatabase[assetTag];
            int indexToRemove = -1;

            foreach int i in 0 ..< existingAsset.schedules.length() {
                if existingAsset.schedules[i].scheduleId == scheduleId {
                    indexToRemove = i;
                    break;
                }
            }

            if indexToRemove != -1 {
                Schedule removed = existingAsset.schedules.remove(indexToRemove);
                return removed;
            } else {
                return error("Schedule not found with id: " + scheduleId);
            }
        } else {
            return error("Asset not found with tag: " + assetTag);
        }
    }

    resource function post addTaskToWorkOrder(string assetTag, string orderId, @http:Payload Task newTask)
            returns Asset|http:NotFound|http:Conflict {
        // Check if the asset exists first.
        if MainDatabase.hasKey(assetTag) {
            // Retrieve the asset record.
            Asset existingAsset = <Asset>MainDatabase[assetTag];

            // Find the specific work order using a foreach loop.
            foreach var workOrder in existingAsset.workOrders {
                if workOrder.orderId == orderId {
                    // Check for duplicate tasks (optional, but good practice).
                    foreach var task in workOrder.tasks {
                        if task.taskId == newTask.taskId {
                            return http:CONFLICT; // Task already exists in this work order.
                        }
                    }

                    // Add the new task to the 'tasks' array of the found work order.
                    workOrder.tasks.push(newTask);
                    return existingAsset;
                }
            }
            // If the loop finishes, the work order was not found.
            return http:NOT_FOUND;
        } else {
            // Asset not found.
            return http:NOT_FOUND;
        }
    }

    resource function delete removeTaskFromWorkOrder(string assetTag, string orderId, string taskId)
            returns Task|http:NotFound {
        // Check if the asset exists.
        if MainDatabase.hasKey(assetTag) {
            // Retrieve the asset record.
            Asset existingAsset = <Asset>MainDatabase[assetTag];

            // Find the correct work order.
            foreach var workOrder in existingAsset.workOrders {
                if workOrder.orderId == orderId {
                    // Once the work order is found, find the index of the task to remove.
                    int indexToRemove = -1;
                    foreach int i in 0 ..< workOrder.tasks.length() {
                        if workOrder.tasks[i].taskId == taskId {
                            indexToRemove = i;
                            break;
                        }
                    }

                    // If the task was found, remove it.
                    if indexToRemove != -1 {
                        Task removed = workOrder.tasks.remove(indexToRemove);
                        return removed;
                    } else {
                        // Task not found within the work order.
                        return http:NOT_FOUND;
                    }
                }
            }
            // If the loop finishes, the work order was not found.
            return http:NOT_FOUND;
        } else {
            // Asset not found.
            return http:NOT_FOUND;
        }
    }

    resource function post openNewWorkOrder(string assetTag, @http:Payload WorkOrder newWorkOrder)
            returns Asset|http:NotFound|http:Conflict {
        // Check if the asset exists.
        if MainDatabase.hasKey(assetTag) {
            Asset existingAsset = <Asset>MainDatabase[assetTag];

            // Set the initial status of the work order to "OPEN".
            newWorkOrder.status = "OPEN";

            // Check for a duplicate work order by orderId to prevent conflicts.
            foreach var wo in existingAsset.workOrders {
                if wo.orderId == newWorkOrder.orderId {
                    return http:CONFLICT;
                }
            }

            // Add the new work order to the asset's workOrders array.
            existingAsset.workOrders.push(newWorkOrder);

            // Update the asset's status since it's now faulty / being worked on.
            existingAsset.status = "UNDER_MAINTENANCE";

            return existingAsset;
        } else {
            // Asset not found.
            return http:NOT_FOUND;
        }
    }

    resource function put updateWorkOrderStatus(string assetTag, string orderId, @http:Query string newStatus)
            returns Asset|http:NotFound {
        // Find the asset.
        if MainDatabase.hasKey(assetTag) {
            Asset existingAsset = <Asset>MainDatabase[assetTag];

            // Find the specific work order to update.
            foreach var workOrder in existingAsset.workOrders {
                if workOrder.orderId == orderId {
                    // Update the status of the work order.
                    workOrder.status = newStatus;
                    return existingAsset;
                }
            }
            // Work order not found.
            return http:NOT_FOUND;
        } else {
            // Asset not found.
            return http:NOT_FOUND;
        }
    }

    resource function put closeWorkOrder(string assetTag, string orderId) returns Asset|http:NotFound {
        // Find the asset.
        if MainDatabase.hasKey(assetTag) {
            Asset existingAsset = <Asset>MainDatabase[assetTag];

            // Find the specific work order to close.
            foreach var workOrder in existingAsset.workOrders {
                if workOrder.orderId == orderId {
                    // Set the work order status to "CLOSED".
                    workOrder.status = "CLOSED";

                    // If nothing else is open, the asset goes back into service.
                    boolean anyOpen = false;
                    foreach var wo in existingAsset.workOrders {
                        if wo.status != "CLOSED" {
                            anyOpen = true;
                        }
                    }
                    if !anyOpen {
                        existingAsset.status = "AVAILABLE";
                    }
                    return existingAsset;
                }
            }
            // Work order not found.
            return http:NOT_FOUND;
        } else {
            // Asset not found.
            return http:NOT_FOUND;
        }
    }

    // Get all assets with overdue schedules
    resource function get overdueAssets() returns Asset[]|error {
        Asset[] overdue = [];
        string today = time:utcToString(time:utcNow()).substring(0, 10);

        foreach Asset asset in MainDatabase {
            foreach Schedule s in asset.schedules {
                if s.dueDate < today {
                    overdue.push(asset);
                    break; // Found one overdue schedule, no need to check others for this asset
                }
            }
        }

        return overdue;
    }
}
