import ballerina/http;
import user.model;


service / on new http:Listener(9091) {

    resource function post user(@http:Payload model:User user) returns string?|error {
        user.imgUrl = "";
        return signUp(user);
    }

    resource function post login(string email, string password) returns string?|error {
        string?|error res = login(email, password);

        if res == "Invalid password" {
            return error("Invalid credentials");
        } else {
            return res;
        }
    }

    @http:ResourceConfig {
        auth: [
            {
                jwtValidatorConfig: {
                    issuer: "wso2",
                    audience: ["ballerina"],
                    "expTime": 3600
                }
            }
        ]
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
