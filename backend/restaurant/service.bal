import ballerina/http;
import restaurant.model;

service / on new http:Listener(9092) {

    resource function post restaurant(@http:Payload model:Restaurant restaurant) returns string?|error {
        restaurant.imgUrl = "";
        return addRestaurant(restaurant);
    }

    resource function get getAllRestaurants() returns model:Restaurant[]|error {
        return getAllRestaurants();  
    }

    resource function get getOneRestaurant(string id) returns model:Restaurant|error {
        return getOneRestaurant(id);
    }

    resource function put updateRestaurant(@http:Payload model:Restaurant restaurant) returns string {
        return updateRestaurant(restaurant);
    }

    resource function delete removeRestaurant(string id) returns string {
        return removeRestaurant(id);
    }

    resource function post addFood(@http:Payload model:Food food) returns string?|error {
        return addFood(food);
    }

    resource function put updateFood(@http:Payload model:Food food) returns string {
        return updateFood(food);
    }
}
