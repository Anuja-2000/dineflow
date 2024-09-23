import ballerina/http;
import user.model;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - name as a string or nil
    # + return - string name with hello message or error
    resource function get greeting(string? name) returns string|error {
        // Send a response back to the caller.
        if name is () {
            return error("name should not be empty!");
        }
        return string `Hello, ${name}`;
    }

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
