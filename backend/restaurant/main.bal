import ballerinax/mysql.driver as _;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/uuid;
import ballerina/log;
import restaurant.model;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

final mysql:Client dbClient = check new(
    host=HOST, user=USER, password=PASSWORD, port=PORT, database="dineflow_db"
);

isolated function addRestaurant(model:Restaurant restaurant) returns string?|error {
    string restaurantId = uuid:createRandomUuid();
    sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO restaurant (id, name, address, imgUrl)
        VALUES (${restaurantId}, ${restaurant.name}, ${restaurant.address}, ${restaurant.imgUrl})
    `);
    string? resultMsg = result.affectedRowCount == 1 ? "Restaurant added successfully" : "Restaurant addition failed";
    return resultMsg;
}


isolated function getOneRestaurant(string id) returns model:Restaurant|error {
    do {
	    sql:ExecutionResult result = check dbClient->queryRow(
	        `SELECT * FROM restaurant
            Where id =  ${id}`
	    );
            model:Restaurant restaurant = {
                id: result.get("id").toString(),
                name: result.get("name").toString(),
                address: result.get("address").toString(),
                imgUrl: result.get("imgUrl").toString(),
                foods: []
            };
            stream<record{}, error?> foodStream = dbClient->query(
                `SELECT * FROM food WHERE restaurantId = ${id}`
            );
            check from record{} foodRow in foodStream
                do {
                    model:Food food = {
                        id: foodRow.get("id").toString(),
                        name: foodRow.get("name").toString(),
                        description: foodRow.get("description").toString(),
                        imgUrl: foodRow.get("imgUrl").toString(),
                        price: <float>foodRow.get("price"),
                        restaurantId: foodRow.get("restaurantId").toString()
                    };
                    restaurant.foods.push(food);
                };
            check foodStream.close();
            return restaurant;
    } on fail var e {
        log:printError(e.message());
    	return error("Restaurant not found");
    }
    
}


isolated function getAllRestaurants() returns model:Restaurant[]|error {
    model:Restaurant[] restaurants = [];
    model:Restaurant restaurant = {
                id: "",
                name: "",
                address: "",
                imgUrl: "",
                foods: []
            };
    stream<record {}, error?> resultStream = dbClient->query(
        `SELECT * FROM restaurant`
    );
    check from record {} result in resultStream
        do {
            restaurant = {
                id: result.get("id").toString(),
                name: result.get("name").toString(),
                address: result.get("address").toString(),
                imgUrl: result.get("imgUrl").toString(),
                foods: []
            };
            stream<record{}, error?> foodStream = dbClient->query(
                `SELECT * FROM food WHERE restaurantId = ${restaurant.id}`
            );
            check from record{} foodRow in foodStream
                do {
                    model:Food food = {
                        id: foodRow.get("id").toString(),
                        name: foodRow.get("name").toString(),
                        description: foodRow.get("description").toString(),
                        imgUrl: foodRow.get("imgUrl").toString(),
                        price: <float>foodRow.get("price"),
                        restaurantId: foodRow.get("restaurantId").toString()
                    };
                    restaurant.foods.push(food);
                };
            check foodStream.close();
            restaurants.push(restaurant);
        };
    check resultStream.close();
    return restaurants;
}

isolated function updateRestaurant(model:Restaurant restaurant) returns string {
    do {
	    sql:ExecutionResult result = check dbClient->execute(
	        `UPDATE restaurant SET 
            name = ${restaurant.name}, 
            address = ${restaurant.address}, 
            imgUrl = ${restaurant.imgUrl}
            WHERE id = ${restaurant.id}`
	    );
        
        return string `Restaurant updated successfully ${result.affectedRowCount ?: 0} rows updated`;
    } on fail var e {
        log:printError(e.message());
    	return "Restaurant update failed" + e.message();
    }
}

isolated function removeRestaurant(string id) returns string {
    do {
        sql:ExecutionResult result = check dbClient->execute(
            `DELETE FROM restaurant WHERE id = ${id}`
        );
        
        return string `Restaurant deleted successfully ${result.affectedRowCount ?: 0} rows deleted`;
    } on fail var e {
        log:printError(e.message());
    	return "Restaurant deletion failed" + e.message();
    }
}

isolated function addFood(model:Food food) returns string?|error {
    string foodId = uuid:createRandomUuid();
    sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO food (id, name, description, imgUrl, price, restaurantId)
        VALUES (${foodId}, ${food.name}, ${food.description}, ${food.imgUrl}, ${food.price}, ${food.restaurantId})
    `);
    string? resultMsg = result.affectedRowCount == 1 ? "Food added successfully" : "Food addition failed";
    return resultMsg;
}

isolated function updateFood(model:Food food) returns string {
    do {
        sql:ExecutionResult result = check dbClient->execute(
            `UPDATE food SET 
            name = ${food.name}, 
            description = ${food.description}, 
            imgUrl = ${food.imgUrl},
            price = ${food.price},
            restaurantId = ${food.restaurantId}
            WHERE id = ${food.id}`
        );
        
        return string `Food updated successfully ${result.affectedRowCount ?: 0} rows updated`;
    } on fail var e {
        log:printError(e.message());
    	return "Food update failed" + e.message();
    }
}
