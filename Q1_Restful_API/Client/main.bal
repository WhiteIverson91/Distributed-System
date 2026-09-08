import ballerina/http;
import ballerina/io;

public type Task record {
    string taskId;
    string description;
};

public type WorkOrder record {
    string orderId;
    string description;
    string status;
    Task[] tasks;
};

public type Schedule record {
    string scheduleId;
    string 'type;
    string dueDate;
    string description;
};

public type Component record {
    string compId;
    string name;
    string description;
};

public type Asset record {
    string assetTag;
    string name;
    string description;
    string institution;
    string site;
    string status;
    string dateAcquired;
    Component[] components;
    Schedule[] schedules;
    WorkOrder[] workOrders;
};

public client class AssetDatabaseClient {
    // The underlying HTTP client.
    private final http:Client httpClient;

    // Constructor to initialize the client with the service's URL.
    function init(string url) returns error? {
        self.httpClient = check new (url);
    }

    // Corresponds to 'resource function get getAllAssets()'
    remote function getAllAssets() returns Asset[]|error {
        return self.httpClient->get("/getAllAssets");
    }

    // Corresponds to 'resource function get getSpecificAsset(string assetTag)'
    // Returns an 'Asset' or '()' if not found.
    remote function getSpecificAsset(string assetTag) returns Asset|error|() {
        return self.httpClient->get(string `/getSpecificAsset?assetTag=${assetTag}`);
    }

    remote function newAsset(Asset newAsset) returns Asset|error {
        return self.httpClient->post("/newAsset", newAsset);
    }

    // Corresponds to 'resource function put updateAsset(@http:Payload Asset updatedAsset)'
    remote function updateAsset(Asset updatedAsset) returns Asset|error {
        return self.httpClient->put("/updateAsset", updatedAsset);
    }

    //corresponds to 'resource function get allInstitutions()'
    remote function getInstitutions() returns string[]|error {
        return self.httpClient->get("/allInstitutions");
    }

    //corresponds to 'resource function post addInstitution(@http:Payload string name)'
    remote function addInstitution(string name) returns string|error {
            return self.httpClient->post("/addInstitution", name);
        }

    //corresponds to 'resource function delete removeInstitution(string name)'
    remote function removeInstitution(string name) returns string|error {
        return self.httpClient->delete(string `/removeInstitution?name=${name}`);
    }

    // Corresponds to 'resource function get getAssetsByInstitution(@http:Query string institution)'
    remote function getAssetsByInstitution(string institution) returns Asset[]|error {
        return self.httpClient->get(string `/getAssetsByInstitution?institution=${institution}`);
    }

    //This one corresponds to 'resource function get getAssetsBySite(@http:Query string site)'
    remote function getAssetsBySite(string site) returns Asset[]|error {
        return self.httpClient->get(string `/getAssetsBySite?site=${site}`);
    }



    // Corresponds to 'resource function delete deleteAsset(string assetTag)'
    remote function deleteAsset(string assetTag) returns Asset|error {
        return self.httpClient->delete(string `/deleteAsset?assetTag=${assetTag}`);
    }

    // Corresponds to 'resource function post addComponentToAsset(string assetTag, @http:Payload Component newComponent)'
    remote function addComponentToAsset(string assetTag, Component newComponent) returns Asset|error {
        return self.httpClient->post(string `/addComponentToAsset?assetTag=${assetTag}`, newComponent);
    }

    // Corresponds to 'resource function delete removeComponentFromAsset(string assetTag, string compId)'
    // Returns the removed Component.
    remote function removeComponentFromAsset(string assetTag, string compId) returns Component|error {
        return self.httpClient->delete(string `/removeComponentFromAsset?assetTag=${assetTag}&compId=${compId}`);
    }

    remote function addScheduleToAsset(string assetTag, Schedule newSchedule) returns Asset|error {
        return self.httpClient->post(string `/addScheduleToAsset?assetTag=${assetTag}`, newSchedule);
    }

    // Returns the removed Schedule.
    remote function removeScheduleFromAsset(string assetTag, string scheduleId) returns Schedule|error {
        return self.httpClient->delete(string `/removeScheduleFromAsset?assetTag=${assetTag}&scheduleId=${scheduleId}`);
    }

    remote function addTaskToWorkOrder(string assetTag, string orderId, Task newTask) returns Asset|error {
        return self.httpClient->post(string `/addTaskToWorkOrder?assetTag=${assetTag}&orderId=${orderId}`, newTask);
    }

    // Returns the removed Task.
    remote function removeTaskFromWorkOrder(string assetTag, string orderId, string taskId) returns Task|error {
        return self.httpClient->delete(string `/removeTaskFromWorkOrder?assetTag=${assetTag}&orderId=${orderId}&taskId=${taskId}`);
    }

    remote function openNewWorkOrder(string assetTag, WorkOrder newWorkOrder) returns Asset|error {
        return self.httpClient->post(string `/openNewWorkOrder?assetTag=${assetTag}`, newWorkOrder);
    }

    remote function updateWorkOrderStatus(string assetTag, string orderId, string newStatus) returns Asset|error {
        return self.httpClient->put(string `/updateWorkOrderStatus?assetTag=${assetTag}&orderId=${orderId}&newStatus=${newStatus}`, ());
    }

    remote function closeWorkOrder(string assetTag, string orderId) returns Asset|error {
        return self.httpClient->put(string `/closeWorkOrder?assetTag=${assetTag}&orderId=${orderId}`, ());
    }

    // Corresponds to 'resource function get overdueAssets()'
    remote function getOverdueAssets() returns Asset[]|error {
        return self.httpClient->get("/overdueAssets");
    }
}

// Main function to demonstrate using the client.
public function main() returns error? {
    AssetDatabaseClient assetDatabaseClient = check new ("http://localhost:8080");
    
    while true {
        io:println("\n1. Update an asset");
        io:println("2. Add schedule to an asset");
        io:println("3. View all assets");
        io:println("4. Filter assets by institution");
        io:println("5. Filter assets by site");
        io:println("6. Get Overdue assets");

        io:println("7. Remove schedule from an asset");
        io:println("8. Get Specific asset");
        io:println("9. Add a new asset");
        io:println("10. Delete an asset");
        io:println("11. Add a component to an asset");
        io:println("12. Open a new work order for an asset");
        io:println("13. Add a task to a work order");
        io:println("14. Update work order status");
        io:println("15. Close a work order");
        io:println("16. Exit the program");
        string choice = io:readln("Enter your choice (1-15) or 16 to quit: ");
        
    

        if choice == "1"{
            io:println("Enter the asset tag of the asset you want to update: ");
            string assetTag = io:readln();
            Asset? assetToUpdate = check assetDatabaseClient->getSpecificAsset(assetTag);

            if assetToUpdate is Asset {
                string status = io:readln("Enter the new status (AVAILABLE, LOANED_OUT, OCCUPIED, UNDER_MAINTENANCE, DISPOSED): ");
                assetToUpdate.status = status;
                Asset updatedAsset = check assetDatabaseClient->updateAsset(assetToUpdate);
                io:println("Asset updated successfully: " , updatedAsset);
            }else {
                io:println("Asset not found.");
            }
            
        }else if choice == "2" {
                string tag = io:readln("Enter the asset tag to add a schedule to: ");
                string scheduleId = io:readln("Enter the new schedule ID: ");
                string typeT = io:readln("Enter the schedule type: ");
                string dueDate = io:readln("Enter the due date (YYYY-MM-DD):");
                string description = io:readln("Enter the schedule description: ");

                Schedule newSchedule = {
                    scheduleId: scheduleId,
                    'type: typeT,
                    dueDate: dueDate,
                    description: description
                };
                io:println("Adding schedule to asset...");
                Asset assetWithNewSchedule = check assetDatabaseClient->addScheduleToAsset(tag, newSchedule);
                io:println("Updated Asset with new schedule: ", assetWithNewSchedule.schedules);
            
        }else if choice == "3" {
                io:println("Fetching all assets...");
                Asset[] allAssets = check assetDatabaseClient->getAllAssets();
                io:println(allAssets);
            
        } else if choice == "4" {
                string institution = io:readln("Enter the institution name to filter assets: ");
                Asset[] institutionAssets = check assetDatabaseClient->getAssetsByInstitution(institution);
                io:println("Assets for institution '" + institution + "': ", institutionAssets);
            
        } else if choice == "5" {
                string site = io:readln("Enter the site name to filter assets: ");
                Asset[] siteAssets = check assetDatabaseClient->getAssetsBySite(site);
                io:println("Assets for site '" + site + "': ", siteAssets);
            
        } else if choice == "6" {
                io:println("Fetching all overdue assets...");
                Asset[]|error overdueAssetsResult = assetDatabaseClient->getOverdueAssets();
                if overdueAssetsResult is error {
                    // The service returns an error if no overdue assets are found.
                    io:println("Error: " + overdueAssetsResult.message());
                } else {
                    io:println("Overdue assets found: ", overdueAssetsResult);
                }
            
        } else if choice == "7" {
                string tag = io:readln("Enter the asset tag to remove a schedule from: ");
                string scheduleId = io:readln("Enter the schedule ID to remove: ");
                Schedule removedSchedule = check assetDatabaseClient->removeScheduleFromAsset(tag, scheduleId);
                io:println("Removed schedule: ", removedSchedule);
            
        } else if choice == "8" {
                string assetTag = io:readln("Enter the asset tag to fetch: ");
                Asset? specificAsset = check assetDatabaseClient->getSpecificAsset(assetTag);
                io:println(specificAsset);
            
        } else if choice == "9" {
                string assetTag = io:readln("Enter the new asset tag: ");
                string name = io:readln("Enter the asset name: ");
                string description = io:readln("Enter the asset description: ");
                string institution = io:readln("Enter the institution: ");
                string site = io:readln("Enter the site: ");
                string status = io:readln("Enter the asset status: ");
                string dateAcquired = io:readln("Enter the date acquired (YYYY-MM-DD): ");
                
                Asset newAssetRecord = {
                    assetTag: assetTag,
                    name: name,
                    description: description,
                    institution: institution,
                    site: site,
                    status: status,
                    dateAcquired: dateAcquired,
                    components: [],
                    schedules: [],
                    workOrders: []
                };
                io:println("Adding a new asset...");
                Asset createdAsset = check assetDatabaseClient->newAsset(newAssetRecord);
                io:println("Created asset: " + createdAsset.assetTag);
            

        }else if choice == "10" {
                string tagToDelete = io:readln("Enter the asset tag to delete: ");
                Asset deletedAsset = check assetDatabaseClient->deleteAsset(tagToDelete);
                io:println(string `Deleted asset: '${deletedAsset.assetTag}'`);
            
        } else if choice == "11" {
                string componentAssetTag = io:readln("Enter the asset tag to add a component to: ");
                string compId = io:readln("Enter the new component ID: ");
                string name = io:readln("Enter the component name: ");
                string description = io:readln("Enter the component description: ");

                Component newComponent = {
                    compId: compId,
                    name: name,
                    description: description
                };
                io:println(string `Adding component to asset '${componentAssetTag}'...`);
                Asset assetWithComponent = check assetDatabaseClient->addComponentToAsset(componentAssetTag, newComponent);
                io:println("Updated Asset with new component: ", assetWithComponent.components);
            
        } else if choice == "12" {
                string assetTagForWorkOrder = io:readln("Enter the asset tag to open a work order for: ");
                string orderId = io:readln("Enter the new work order ID: ");
                string description = io:readln("Enter the work order description: ");

                WorkOrder newWorkOrder = {
                    orderId: orderId,
                    description: description,
                    status: "", // Status is set by the service
                    tasks: []
                };
                io:println(string `Opening new work order '${newWorkOrder.orderId}' for asset '${assetTagForWorkOrder}'...`);
                Asset assetWithNewWorkOrder = check assetDatabaseClient->openNewWorkOrder(assetTagForWorkOrder, newWorkOrder);
                io:println("Asset status after opening work order: " + assetWithNewWorkOrder.status);
        }else  if choice == "13"{
                string assetTagForWorkOrder = io:readln("Enter the asset tag for the work order: ");
                string orderIdForTask = io:readln("Enter the work order ID to add a task to: ");
                string taskId = io:readln("Enter the new task ID: ");
                string description = io:readln("Enter the task description: ");

                Task newTask = {taskId: taskId, description: description};
                Asset taskAddedAsset = check assetDatabaseClient->addTaskToWorkOrder(assetTagForWorkOrder, orderIdForTask, newTask);

                foreach WorkOrder wo in taskAddedAsset.workOrders {
                    if wo.orderId == orderIdForTask {
                        io:println("Work order tasks: ", wo.tasks);
                    }
                }
        } else if choice == "14" {
                string assetTagForWorkOrder = io:readln("Enter the asset tag for the work order: ");
                string orderIdForStatusUpdate = io:readln("Enter the work order ID to update status for: ");
                string newStatus = io:readln("Enter the new status (e.g., IN_PROGRESS): ");

                Asset statusUpdatedAsset = check assetDatabaseClient->updateWorkOrderStatus(
                        assetTagForWorkOrder, orderIdForStatusUpdate, newStatus);
                foreach WorkOrder wo in statusUpdatedAsset.workOrders {
                    if wo.orderId == orderIdForStatusUpdate {
                        io:println("Updated work order status: ", wo.status);
                    }

                }
        } else if choice == "15" {
                string assetTagForWorkOrder = io:readln("Enter the asset tag for the work order: ");
                string orderIdToClose = io:readln("Enter the work order ID to close: ");

                io:println(string `Closing work order '${orderIdToClose}' for asset '${assetTagForWorkOrder}'...`);
                Asset closedWorkOrderAsset = check assetDatabaseClient->closeWorkOrder(assetTagForWorkOrder, orderIdToClose);
                io:println("Asset status after closing work order: ", closedWorkOrderAsset.status);
        }
        
        else if choice == "16" {
                break;
            }


    }
}