public type Restaurant record {|
    string id;
    string name;
    string address;
    string imgUrl;
    Food[] foods;
|};

public type Food record {|
    string id;
    string name;
    string description;
    string imgUrl;
    float price;
    string restaurantId;       
|};
