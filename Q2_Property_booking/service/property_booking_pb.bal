import ballerina/grpc;
import ballerina/protobuf;

public const string PROPERTY_BOOKING_DESC = "0A1670726F70657274795F626F6F6B696E672E70726F746F121070726F70657274795F626F6F6B696E6722EA010A0850726F7065727479121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F7374496412230A0D70726F70657274795F6E616D65180320012809520C70726F70657274794E616D65121A0A086C6F636174696F6E18042001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180520012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180620012801520D70726963655065724E6967687412160A067374617475731807200128095206737461747573225D0A045573657212170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D6512120A04726F6C651803200128095204726F6C6512140A05656D61696C1804200128095205656D61696C2285010A0F426F6F6B696E67436172744974656D121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412190A0867756573745F696418022001280952076775657374496412190A08636865636B5F696E1803200128095207636865636B496E121B0A09636865636B5F6F75741804200128095208636865636B4F757422F7010A13426F6F6B696E67436F6E6669726D6174696F6E121D0A0A626F6F6B696E675F69641801200128095209626F6F6B696E674964121F0A0B70726F70657274795F6964180220012809520A70726F7065727479496412190A0867756573745F696418032001280952076775657374496412190A08636865636B5F696E1804200128095207636865636B496E121B0A09636865636B5F6F75741805200128095208636865636B4F757412160A066E696768747318062001280552066E6967687473121D0A0A746F74616C5F636F73741807200128015209746F74616C436F737412160A067374617475731808200128095206737461747573224C0A1241646450726F70657274795265717565737412360A0870726F706572747918012001280B321A2E70726F70657274795F626F6F6B696E672E50726F7065727479520870726F706572747922500A1341646450726F7065727479526573706F6E7365121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412180A076D65737361676518022001280952076D65737361676522540A134372656174655573657273526573706F6E736512180A076D65737361676518012001280952076D65737361676512230A0D75736572735F63726561746564180220012805520C757365727343726561746564224F0A1555706461746550726F70657274795265717565737412360A0870726F706572747918012001280B321A2E70726F70657274795F626F6F6B696E672E50726F7065727479520870726F7065727479224A0A1655706461746550726F7065727479526573706F6E736512160A06737461747573180120012809520673746174757312180A076D65737361676518022001280952076D65737361676522510A1552656D6F766550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F7374496422540A1652656D6F766550726F7065727479526573706F6E7365123A0A0A70726F7065727469657318012003280B321A2E70726F70657274795F626F6F6B696E672E50726F7065727479520A70726F7065727469657322760A1E4C697374417661696C61626C6550726F7065727469657352657175657374121A0A086C6F636174696F6E18012001280952086C6F636174696F6E121B0A096D696E5F707269636518022001280152086D696E5072696365121B0A096D61785F707269636518032001280152086D6178507269636522380A1553656172636850726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F70657274794964226A0A1653656172636850726F7065727479526573706F6E736512360A0870726F706572747918012001280B321A2E70726F70657274795F626F6F6B696E672E50726F7065727479520870726F706572747912180A076D65737361676518022001280952076D6573736167652289010A13426F6F6B50726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412190A0867756573745F696418022001280952076775657374496412190A08636865636B5F696E1803200128095207636865636B496E121B0A09636865636B5F6F75741804200128095208636865636B4F757422480A14426F6F6B50726F7065727479526573706F6E736512160A06737461747573180120012809520673746174757312180A076D65737361676518022001280952076D65737361676522530A15436F6E6669726D426F6F6B696E675265717565737412190A0867756573745F6964180120012809520767756573744964121F0A0B70726F70657274795F6964180220012809520A70726F70657274794964228B010A16436F6E6669726D426F6F6B696E67526573706F6E7365123F0A07626F6F6B696E6718012001280B32252E70726F70657274795F626F6F6B696E672E426F6F6B696E67436F6E6669726D6174696F6E5207626F6F6B696E6712160A06737461747573180220012809520673746174757312180A076D65737361676518032001280952076D65737361676532C9060A1850726F70657274795F426F6F6B696E675F53657276696365125F0A0C6164645F70726F706572747912242E70726F70657274795F626F6F6B696E672E41646450726F7065727479526571756573741A252E70726F70657274795F626F6F6B696E672E41646450726F7065727479526573706F6E73652800300012510A0C6372656174655F757365727312162E70726F70657274795F626F6F6B696E672E557365721A252E70726F70657274795F626F6F6B696E672E4372656174655573657273526573706F6E73652801300012680A0F7570646174655F70726F706572747912272E70726F70657274795F626F6F6B696E672E55706461746550726F7065727479526571756573741A282E70726F70657274795F626F6F6B696E672E55706461746550726F7065727479526573706F6E73652800300012680A0F72656D6F76655F70726F706572747912272E70726F70657274795F626F6F6B696E672E52656D6F766550726F7065727479526571756573741A282E70726F70657274795F626F6F6B696E672E52656D6F766550726F7065727479526573706F6E736528003000126D0A196C6973745F617661696C61626C655F70726F7065727469657312302E70726F70657274795F626F6F6B696E672E4C697374417661696C61626C6550726F70657274696573526571756573741A1A2E70726F70657274795F626F6F6B696E672E50726F70657274792800300112680A0F7365617263685F70726F706572747912272E70726F70657274795F626F6F6B696E672E53656172636850726F7065727479526571756573741A282E70726F70657274795F626F6F6B696E672E53656172636850726F7065727479526573706F6E73652800300012620A0D626F6F6B5F70726F706572747912252E70726F70657274795F626F6F6B696E672E426F6F6B50726F7065727479526571756573741A262E70726F70657274795F626F6F6B696E672E426F6F6B50726F7065727479526573706F6E73652800300012680A0F636F6E6669726D5F626F6F6B696E6712272E70726F70657274795F626F6F6B696E672E436F6E6669726D426F6F6B696E67526571756573741A282E70726F70657274795F626F6F6B696E672E436F6E6669726D426F6F6B696E67526573706F6E736528003000620670726F746F33";

public isolated client class Property_Booking_ServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, PROPERTY_BOOKING_DESC);
    }

    isolated remote function add_property(AddPropertyRequest|ContextAddPropertyRequest req) returns AddPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyRequest message;
        if req is ContextAddPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("property_booking.Property_Booking_Service/add_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddPropertyResponse>result;
    }

    isolated remote function add_propertyContext(AddPropertyRequest|ContextAddPropertyRequest req) returns ContextAddPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyRequest message;
        if req is ContextAddPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("property_booking.Property_Booking_Service/add_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function create_users() returns Create_usersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("property_booking.Property_Booking_Service/create_users");
        return new Create_usersStreamingClient(sClient);
    }

    isolated remote function update_property(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns UpdatePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("property_booking.Property_Booking_Service/update_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UpdatePropertyResponse>result;
    }

    isolated remote function update_propertyContext(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns ContextUpdatePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("property_booking.Property_Booking_Service/update_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UpdatePropertyResponse>result, headers: respHeaders};
    }

    isolated remote function remove_property(RemovePropertyRequest|ContextRemovePropertyRequest req) returns RemovePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("property_booking.Property_Booking_Service/remove_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RemovePropertyResponse>result;
    }

    isolated remote function remove_propertyContext(RemovePropertyRequest|ContextRemovePropertyRequest req) returns ContextRemovePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("property_booking.Property_Booking_Service/remove_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RemovePropertyResponse>result, headers: respHeaders};
    }

    isolated remote function list_available_properties(ListAvailablePropertiesRequest|ContextListAvailablePropertiesRequest req) returns stream<Property, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailablePropertiesRequest message;
        if req is ContextListAvailablePropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("property_booking.Property_Booking_Service/list_available_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return new stream<Property, grpc:Error?>(outputStream);
    }

    isolated remote function list_available_propertiesContext(ListAvailablePropertiesRequest|ContextListAvailablePropertiesRequest req) returns ContextPropertyStream|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailablePropertiesRequest message;
        if req is ContextListAvailablePropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("property_booking.Property_Booking_Service/list_available_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return {content: new stream<Property, grpc:Error?>(outputStream), headers: respHeaders};
    }

    isolated remote function search_property(SearchPropertyRequest|ContextSearchPropertyRequest req) returns SearchPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("property_booking.Property_Booking_Service/search_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchPropertyResponse>result;
    }

    isolated remote function search_propertyContext(SearchPropertyRequest|ContextSearchPropertyRequest req) returns ContextSearchPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("property_booking.Property_Booking_Service/search_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function book_property(BookPropertyRequest|ContextBookPropertyRequest req) returns BookPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("property_booking.Property_Booking_Service/book_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <BookPropertyResponse>result;
    }

    isolated remote function book_propertyContext(BookPropertyRequest|ContextBookPropertyRequest req) returns ContextBookPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("property_booking.Property_Booking_Service/book_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <BookPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function confirm_booking(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ConfirmBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("property_booking.Property_Booking_Service/confirm_booking", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ConfirmBookingResponse>result;
    }

    isolated remote function confirm_bookingContext(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ContextConfirmBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("property_booking.Property_Booking_Service/confirm_booking", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ConfirmBookingResponse>result, headers: respHeaders};
    }

}

public isolated client class Create_usersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUser(User message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUser(ContextUser message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveCreateUsersResponse() returns CreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <CreateUsersResponse>payload;
        }
    }

    isolated remote function receiveContextCreateUsersResponse() returns ContextCreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <CreateUsersResponse>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class PropertyStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Property value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Property value;|} nextRecord = {value: <Property>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public isolated client class Property_Booking_ServiceAddPropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendAddPropertyResponse(AddPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextAddPropertyResponse(ContextAddPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class Property_Booking_ServiceCreateUsersResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCreateUsersResponse(CreateUsersResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCreateUsersResponse(ContextCreateUsersResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class Property_Booking_ServiceUpdatePropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendUpdatePropertyResponse(UpdatePropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextUpdatePropertyResponse(ContextUpdatePropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class Property_Booking_ServiceRemovePropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendRemovePropertyResponse(RemovePropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextRemovePropertyResponse(ContextRemovePropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class Property_Booking_ServicePropertyCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendProperty(Property response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextProperty(ContextProperty response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class Property_Booking_ServiceSearchPropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendSearchPropertyResponse(SearchPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextSearchPropertyResponse(ContextSearchPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class Property_Booking_ServiceBookPropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendBookPropertyResponse(BookPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextBookPropertyResponse(ContextBookPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class Property_Booking_ServiceConfirmBookingResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendConfirmBookingResponse(ConfirmBookingResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextConfirmBookingResponse(ContextConfirmBookingResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextUserStream record {|
    stream<User, error?> content;
    map<string|string[]> headers;
|};

public type ContextPropertyStream record {|
    stream<Property, error?> content;
    map<string|string[]> headers;
|};

public type ContextAddPropertyRequest record {|
    AddPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextAddPropertyResponse record {|
    AddPropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextUser record {|
    User content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersResponse record {|
    CreateUsersResponse content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyRequest record {|
    UpdatePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyResponse record {|
    UpdatePropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextRemovePropertyRequest record {|
    RemovePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextRemovePropertyResponse record {|
    RemovePropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextListAvailablePropertiesRequest record {|
    ListAvailablePropertiesRequest content;
    map<string|string[]> headers;
|};

public type ContextProperty record {|
    Property content;
    map<string|string[]> headers;
|};

public type ContextSearchPropertyRequest record {|
    SearchPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchPropertyResponse record {|
    SearchPropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextBookPropertyRequest record {|
    BookPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextBookPropertyResponse record {|
    BookPropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextConfirmBookingRequest record {|
    ConfirmBookingRequest content;
    map<string|string[]> headers;
|};

public type ContextConfirmBookingResponse record {|
    ConfirmBookingResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type Property record {|
    readonly string property_id = "";
    string host_id = "";
    string property_name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type User record {|
    readonly string user_id = "";
    string name = "";
    string role = "";
    string email = "";
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type BookingCartItem record {|
    readonly string property_id = "";
    readonly string guest_id = "";
    string check_in = "";
    string check_out = "";
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type BookingConfirmation record {|
    readonly string booking_id = "";
    string property_id = "";
    string guest_id = "";
    string check_in = "";
    string check_out = "";
    int nights = 0;
    float total_cost = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type AddPropertyRequest record {|
    Property property = {};
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type AddPropertyResponse record {|
    string property_id = "";
    string message = "";
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type CreateUsersResponse record {|
    string message = "";
    int users_created = 0;
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type UpdatePropertyRequest record {|
    Property property = {};
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type UpdatePropertyResponse record {|
    string status = "";
    string message = "";
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type RemovePropertyRequest record {|
    string property_id = "";
    string host_id = "";
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type RemovePropertyResponse record {|
    Property[] properties = [];
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type ListAvailablePropertiesRequest record {|
    string location = "";
    float min_price = 0.0;
    float max_price = 0.0;
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type SearchPropertyRequest record {|
    string property_id = "";
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type SearchPropertyResponse record {|
    Property property = {};
    string message = "";
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type BookPropertyRequest record {|
    string property_id = "";
    string guest_id = "";
    string check_in = "";
    string check_out = "";
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type BookPropertyResponse record {|
    string status = "";
    string message = "";
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type ConfirmBookingRequest record {|
    string guest_id = "";
    string property_id = "";
|};

@protobuf:Descriptor {value: PROPERTY_BOOKING_DESC}
public type ConfirmBookingResponse record {|
    BookingConfirmation booking = {};
    string status = "";
    string message = "";
|};
