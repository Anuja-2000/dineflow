import ballerinax/mysql.driver as _;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/uuid;
import ballerina/log;
import user.model;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

final mysql:Client dbClient = check new(
    host=HOST, user=USER, password=PASSWORD, port=PORT, database="dineflow_db"
);

isolated function signUp(model:User user) returns string?|error {
    if(isUserExists(user.email)) {
        return "User already exists";
    }
    string userId = uuid:createRandomUuid();
    sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO user (id, name, email, password, gender, imgUrl)
        VALUES (${userId}, ${user.name}, ${user.email}, ${user.password}, ${user.gender}, ${user.imgUrl})
    `);
    string? resultMsg = result.affectedRowCount == 1 ? "User added successfully" : "User addition failed";
    return resultMsg;
}

isolated function isUserExists(string email) returns boolean {
    do {
	    string? user = check dbClient->queryRow(
	        `SELECT email FROM user WHERE email = ${email}`
	    );
        if user is string {
        return true;
        }else {
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
        }else {
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

// isolated function updateEmployee(Employee emp) returns int|error {
//     sql:ExecutionResult result = check dbClient->execute(`
//         UPDATE Employees SET
//             first_name = ${emp.first_name}, 
//             last_name = ${emp.last_name},
//             email = ${emp.email},
//             phone = ${emp.phone},
//             hire_date = ${emp.hire_date}, 
//             manager_id = ${emp.manager_id},
//             job_title = ${emp.job_title}
//         WHERE employee_id = ${emp.employee_id}  
//     `);
//     int|string? lastInsertId = result.lastInsertId;
//     if lastInsertId is int {
//         return lastInsertId;
//     } else {
//         return error("Unable to obtain last insert ID");
//     }
// }

// isolated function removeEmployee(int id) returns int|error {
//     sql:ExecutionResult result = check dbClient->execute(`
//         DELETE FROM Employees WHERE employee_id = ${id}
//     `);
//     int? affectedRowCount = result.affectedRowCount;
//     if affectedRowCount is int {
//         return affectedRowCount;
//     } else {
//         return error("Unable to obtain the affected row count");
//     }
// }