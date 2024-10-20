import user.model;

import ballerina/crypto;
import ballerina/jwt;
import ballerina/log;
import ballerina/sql;
import ballerina/uuid;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

final mysql:Client dbClient = check new (
    host = HOST, user = USER, password = PASSWORD, port = PORT, database = "dineflow_db"
);

function signUp(model:User user) returns string?|error {
    if (isUserExists(user.email)) {
        return "User already exists";
    }
    string userId = uuid:createRandomUuid();
    // Encrypt the user's password before storing it in the database
    string encryptedPassword = check encryptPassword(user.password);
    user.password = encryptedPassword;
    sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO user (id, name, email, password, gender, imgUrl)
        VALUES (${userId}, ${user.name}, ${user.email}, ${user.password}, ${user.gender}, ${user.imgUrl})
    `);
    if result.affectedRowCount == 1 {
        // Generate JWT token
        string jwtToken = check generateJwtToken(user.email);
        return jwtToken;
    } else {
        return "User addition failed";
    }
}

function generateJwtToken(string email) returns string|error {
    // jwt:IssuerSignatureConfig jwtConfig = {
    //     config: {
    //         keyFile: "path/to/private.key",
    //         keyPassword: "your-key-password"
    //     }
    // };
    jwt:IssuerConfig issuerConfig = {
        issuer: "wso2",
        audience: ["ballerina"],
        expTime: 3600
    };

    string jwtToken = check jwt:issue(issuerConfig);
    return jwtToken;

}

function encryptPassword(string password) returns string|error {
    byte[] key = "your-secret-key".toBytes();
    byte[] passwordBytes = password.toBytes();
    byte[] encryptedBytes = check crypto:hmacSha256(passwordBytes, key);
    return encryptedBytes.toBase16();
}

function login(string email, string password) returns string|error {
    model:User? user = check dbClient->queryRow(
        `SELECT * FROM user WHERE email = ${email}`
    );
    if user is () {
        return "User not found";
    }
    // Decrypt the user's password from the database and compare it with the provided password
    string encryptedPassword = check encryptPassword(password);
    if encryptedPassword == user.password {
        // Generate JWT token
        string jwtToken = check generateJwtToken(email);
        return jwtToken;
    } else {
        return "Invalid password";
    }
}

isolated function isUserExists(string email) returns boolean {
    do {
        string? user = check dbClient->queryRow(
        `SELECT email FROM user WHERE email = ${email}`
        );
        if user is string {
            return true;
        } else {
            return false;
        }
    } on fail var e {
        log:printError(e.message());
        return false;
    }

}

isolated function getOneUser(string id) returns model:User|error {
    do {
        model:User? user = check dbClient->queryRow(
        `SELECT * FROM user WHERE id = ${id}`
        );
        if user is () {
            return error("User not found");
        } else {
            return user;
        }
    } on fail var e {
        log:printError(e.message());
        return error("User not found");
    }

}

isolated function getAllUsers() returns model:User[]|error {
    model:User[] users = [];
    stream<model:User, error?> resultStream = dbClient->query(
        `SELECT * FROM user`
    );
    check from model:User user in resultStream
        do {
            users.push(user);
        };
    check resultStream.close();
    return users;
}

isolated function updateUser(model:User user) returns string {
    do {
        sql:ExecutionResult result = check dbClient->execute(
        `UPDATE user SET 
            name = ${user.name}, 
            email = ${user.email}, 
            password = ${user.password}, 
            gender = ${user.gender}, 
            imgUrl = ${user.imgUrl} 
            WHERE id = ${user.id}`
        );

        return string `User updated successfully ${result.affectedRowCount ?: 0} rows updated`;
    } on fail var e {
        log:printError(e.message());
        return "User update failed" + e.message();
    }
}
