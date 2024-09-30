import ballerina/http;
import user.model;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9091) {

    # A resource for generating greetings
    # + name - name as a string or nil
    # + return - string name with hello message or error

    resource function post user(@http:Payload model:User user) returns string?|error {
        user.imgUrl = "";
        return signUp(user);
    }

    resource  function get getAllUsers() returns model:User[]|error {
        return getAllUsers();  
    }

    resource function get getOneUser(string id) returns model:User|error {
        return getOneUser(id);
    }

    resource function put updateUser(@http:Payload model:User user) returns string {
        return updateUser(user);
    }
}
