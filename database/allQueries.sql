    CREATE SCHEMA `shopee_db` ;
    USE `shopee_db`;
    
    CREATE TABLE IF NOT EXISTS users (
      user_name varchar(100),
      password varchar(50),
      mode varchar(20),
      PRIMARY KEY (user_name)
    );

    CREATE TABLE IF NOT EXISTS store (
      store_name varchar(30),
      address_line1 text,
      address_line2 text,
      PRIMARY KEY (store_name)
    );

    CREATE TABLE IF NOT EXISTS train (
      train_id int ,
      train_capacity numeric(5,2),
      PRIMARY KEY (train_id)
    );

    CREATE TABLE IF NOT EXISTS train_schedule (
      train_session_id int NOT NULL AUTO_INCREMENT,
      train_id int,
      departure_time time,
      departure_date date,
      available_capacity numeric(5,2),
      PRIMARY KEY (train_session_id),
      FOREIGN KEY (train_id) REFERENCES train(train_id)
    );

    CREATE TABLE IF NOT EXISTS arrival_station (
      train_session_id int ,
      arrival_station varchar(30) ,
      PRIMARY KEY (train_session_id, arrival_station),
      FOREIGN KEY (train_session_id) REFERENCES train_schedule(train_session_id),
      FOREIGN KEY (arrival_station) REFERENCES store(store_name)
    );

    CREATE TABLE IF NOT EXISTS customer_type (
      customer_type varchar(10),
      discount_rate numeric(3,2),
      min_number_of_items int,
      PRIMARY KEY (customer_type)
    );

    CREATE TABLE IF NOT EXISTS customer (
      customer_id int AUTO_INCREMENT,
      name varchar(50),
      address_number text,
      address_line_1 text,
      address_line_2 text,
      contact_number varchar(20),
      customer_type varchar(10),
      user_name varchar(100) UNIQUE NOT NULL,
      PRIMARY KEY (customer_id),
      FOREIGN KEY (customer_type) REFERENCES customer_type(customer_type),
      FOREIGN KEY (user_name) REFERENCES users(user_name)
    );

    CREATE TABLE IF NOT EXISTS route (
      route_id int ,
      store_name varchar(30),
      time_taken int,
      PRIMARY KEY (route_id),
      FOREIGN KEY (store_name) REFERENCES store(store_name)
    );

    CREATE TABLE IF NOT EXISTS order_table (
      order_id int NOT NULL AUTO_INCREMENT,
      customer_id int,
      number_of_items int,
      order_date date,
      order_time time,
      expected_delivery_date date,
      total_price numeric(10,2),
      discount numeric(10,2),
      total_capacity numeric(5,2),
      route_id int,
      delivery_state varchar(10),
      address_number text,
      address_line_1 text,
      address_line_2 text,
      PRIMARY KEY (order_id),
      FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
      FOREIGN KEY (route_id) REFERENCES route(route_id)
    );

    CREATE TABLE IF NOT EXISTS truck (
      truck_id int NOT NULL AUTO_INCREMENT,
      truck_capacity numeric(5,2),
      used_hours numeric(8,2),
      store_name varchar(30),
      PRIMARY KEY (truck_id),
      FOREIGN KEY (store_name) REFERENCES store(store_name)
    );

    CREATE TABLE IF NOT EXISTS driver (
      driver_id int NOT NULL AUTO_INCREMENT,
      driver_name varchar(50),
      NIC varchar(15),
      address_line1 text,
      address_line2 text,
      store_name varchar(30),
      PRIMARY KEY (driver_id),
      FOREIGN KEY (store_name) REFERENCES store(store_name)
    );

    CREATE TABLE IF NOT EXISTS driver_assistant (
      driver_assistant_id int NOT NULL AUTO_INCREMENT,
      driver_assistant_name varchar(50),
      NIC varchar(15),
      address_line1 text,
      address_line2 text,
      store_name varchar(30),
      PRIMARY KEY (driver_assistant_id),
      FOREIGN KEY (store_name) REFERENCES store(store_name)
    );

    CREATE TABLE IF NOT EXISTS truck_schedule (
      truck_session_id int NOT NULL AUTO_INCREMENT,
      truck_id int,
      driver_id int,
      driver_assistant_id int,
      route_id int,
      departure_date date,
      departure_time time,
      arrival_time time,
      available_capacity numeric(5,2),
      year_number int,
      week_number int,
      PRIMARY KEY (truck_session_id),
      FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
      FOREIGN KEY (route_id) REFERENCES route(route_id),
      FOREIGN KEY (truck_id) REFERENCES truck(truck_id),
      FOREIGN KEY (driver_assistant_id) REFERENCES driver_assistant(driver_assistant_id)
    );

    CREATE TABLE IF NOT EXISTS order_truck_schedule (
      order_id int,
      truck_session_id int,
      PRIMARY KEY (order_id, truck_session_id),
      FOREIGN KEY (truck_session_id) REFERENCES truck_schedule(truck_session_id),
      FOREIGN KEY (order_id) REFERENCES order_table(order_id)
    );

    CREATE TABLE IF NOT EXISTS order_train_schedule (
      order_id int,
      train_session_id int,
      PRIMARY KEY (order_id, train_session_id),
      FOREIGN KEY (train_session_id) REFERENCES train_schedule(train_session_id),
      FOREIGN KEY (order_id) REFERENCES order_table(order_id)
    );

    CREATE TABLE IF NOT EXISTS items (
      item_id int NOT NULL AUTO_INCREMENT,
      item_name varchar(30),
      capacity numeric(4,2),
      price numeric(8,2),
      description text,
      PRIMARY KEY (item_id)
    );

    CREATE TABLE IF NOT EXISTS cart (
      customer_id int ,
      item_id int,
      item_quantity int,
      PRIMARY KEY (customer_id, item_id),
      FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
      FOREIGN KEY (item_id) REFERENCES items(item_id)
    );



    CREATE TABLE IF NOT EXISTS order_items (
      order_id int NOT NULL AUTO_INCREMENT,
      item_id int,
      order_items_quantity int,
      PRIMARY KEY (order_id, item_id),
      FOREIGN KEY (order_id) REFERENCES order_table(order_id),
      FOREIGN KEY (item_id) REFERENCES items(item_id)
    );


    CREATE TABLE IF NOT EXISTS store_manager (
      manager_id int NOT NULL AUTO_INCREMENT,
      name varchar(50),
      user_name varchar(100) NOT NULL UNIQUE ,
      NIC varchar(15),
      telephone_no varchar(20),
      store varchar(30),
      PRIMARY KEY (manager_id),
      FOREIGN KEY (user_name) REFERENCES users(user_name),
      FOREIGN KEY (store) REFERENCES store(store_name)
    );

    CREATE TABLE IF NOT EXISTS main_manager (
      manager_id int  NOT NULL AUTO_INCREMENT,
      name varchar(50),
      user_name varchar(100) NOT NULL UNIQUE,
      NIC varchar(15),
      telephone_no varchar(20),
      PRIMARY KEY (manager_id),
      FOREIGN KEY (user_name) REFERENCES users(user_name)
    );





    DELIMITER //


    CREATE procedure InsertItem ( IN item_name varchar(30) , IN capacity numeric(4,2) , IN price numeric(8,2),IN descriptions TEXT )
    BEGIN
        insert into items(item_name,capacity,price,description) values (item_name,capacity,price,descriptions);
    END //


    CREATE procedure BuyCart ( IN customerID int , IN route_id int ,IN address_number TEXT, IN address_line_1 TEXT,IN address_line_2 TEXT, IN deliveryDate DATE)
    BEGIN
        declare ItemCount int default 0;
        declare totalPrice DECIMAL(10,2) default 0;
        declare totalCapacity DECIMAL(5,2) default 0;
        declare NumOfItems int default 0;
        declare quantity int default 0;
        declare OrderDate date ;
        declare OrderTime time;
        declare itemID int;
        declare discount decimal(10,2) default 0;
        declare iTemp int default 0;
        declare OrderID int;

        select count(Item_id) into ItemCount from cart where customer_id = customerID;


        set OrderDate = current_date();
        set OrderTime = current_time() ;

        insert into order_table values (null, customerID ,null,OrderDate,OrderTime,deliveryDate,null,null,null,route_id,'new',address_number,address_line_1,address_line_2);
        select order_id into OrderID from order_table where customer_id = customerID and order_date = OrderDate and order_time = OrderTime ;


        while ItemCount > 0 DO
            select item_id into itemID from cart where customer_id = customerID limit 1;
            select item_quantity into quantity from cart where customer_id = customerID and
            item_id = itemID;
            set NumOfItems = NumOfItems + quantity;
            set TotalPrice = TotalPrice + quantity * ( select price from items where item_id = itemID);
            set TotalCapacity = TotalCapacity + quantity * ( select capacity from items where item_id =
            itemID);
            insert into order_items values (OrderID,itemID,quantity);
            delete from cart where customer_id = customerID and item_id = itemID;
            set ItemCount = ItemCount -1;
        end while;

        call GetDiscount(totalPrice,customerID,@discount);
        select @discount into discount ;
        set totalPrice = totalPrice-discount;

        update order_table set number_of_items = NumOfItems , total_price = TotalPrice ,total_capacity = TotalCapacity , discount = discount where order_id = OrderID;


    END //


    CREATE PROCEDURE GetDiscount (IN price int , IN customer_id int ,OUT discount numeric(10,2))
    BEGIN
        declare discount_rate numeric(3,2);
        SELECT customer_type.discount_rate INTO discount_rate from customer_type ,
        customer where customer.customer_id = customer_id AND customer.customer_type =
        customer_type.customer_type ;
        set discount = price * discount_rate;
    END //


    CREATE PROCEDURE OrderAssignToTrain (in orderID int , in train_sessionID int)
    BEGIN
        declare order_capacity decimal(5,2);
        select total_capacity into order_capacity from order_table where order_id = orderID;
        insert into order_train_schedule values (orderID,train_sessionID);
        update train_schedule set available_capacity = available_capacity - order_capacity where train_session_id = train_sessionID;
        update order_table set delivery_state = "InTrain" where order_id = orderID;
    END //


    create procedure DeleteFromCart(in input_id int, in item_id_in int)
    begin
        delete from cart where customer_id=input_id and item_id=item_id_in;
    end//


    create procedure DeleteQuantityFromCart(in input_id int ,in item_id_in int)
    begin
        update cart
        set item_quantity=item_quantity-1 where
        customer_id=input_id and item_id=item_id_in;
    end //


    create procedure RegisterCustomer(in customer_id int, in name varchar(50) ,in address_number varchar(10), in address_line_1 varchar(30), in address_line_2 varchar(30), in contact_number varchar(10), in customer_type varchar(10),in username varchar(100))
    begin
        insert into customer (customer_id,name,address_number,address_line_1,address_line_2,contact_number,custormer_type,user_name ) values (customer_id,name,address_number,address_line_1,address_line_2,contact_number,customer_type,username);
    end //


    CREATE procedure RemoveCustomer(in customerID varchar(30))
    begin
        delete from customer where customer_id=customerID;
    end //


    create procedure EditProfile(in customer_id_in int, in name_in  varchar(50) ,in address_number_in varchar(10), in address_line_1_in  varchar(30), in address_line_2_in varchar(30), in contact_number_in varchar(10), in customer_type_in varchar(10),in username_in varchar(100))
    begin
        update customer
        set customer_id=customer_id_in,name=name_in,address_number=address_number_in,address_line_1=address_line_1_in,address_line_2=address_line_2_in,contact_number=contact_number_in,customer_type=customer_type_in,user_name=username_in where customer_id=customer_id_in;
    end //


    create procedure AddDriver(in name varchar(50), in nicNO varchar(15),in address_line_1 text,in address_line_2 text)
    begin
        insert into driver (driver_name,NIC,address_line1,address_line2) values (name,nicNO,address_line_1,address_line_2);
    end //


    create procedure AddDriverAssistant(in name varchar(50), in nicNO varchar(15),in address_line_1 text,in address_line_2 text)
    begin
        insert into driver_assistant (driver_assistant_name,NIC,address_line1,address_line2) values (name,nicNO,address_line_1,address_line_2);
    end //


    create procedure AddTrainSession(in trainID int,in departureTime time,in departureDate date,in availableCapacity decimal(5,2))
    begin
        insert into train_schedule (train_id,departure_time,departure_date,available_capacity) values (trainID,departureTime,departureDate,availableCapacity);
    end //


    create procedure AddTrain(in trainID int,in capacity decimal(5,2))
    begin
        insert into train (train_id,train_capacity) values (trainID,capacity);
    end //


    create procedure AddRoute(in routeID int,in storeName varchar(30),in timeTaken decimal(3,2))
    begin
        insert into route (route_id,store_name,time_taken) values (routeID,storeName,timeTaken);
    end //


    create procedure AddTruck(in truck_capacity decimal(5,2) ,in hours decimal(8,2), IN `store_name` VARCHAR(30))
    begin
        insert into truck (truck_capacity,used_hours, store_name) values (truck_capacity,hours, store_name);
    end //


    create procedure AddStore(in storeName varchar(30),in address_line_1 text,in address_line_2 text)
    begin
        insert into store (store_name,address_line1,address_line2) values (store_name,address_line_1,address_line_2);
    end //


    CREATE PROCEDURE insertArrivalStation(in train_sessionId int ,in station varchar(30),in arrivalTime time)
    begin
        insert into arrival_station (train_session_id,arrival_station) values  (train_sessionId,station);
    End //


    CREATE  PROCEDURE AvailableTrains(in orderID int , out trainID int)
    begin
        declare routeID int;
        declare OrderDate date;
        declare TotalCapacity decimal(5,2);
        declare StoreName varchar(30);
        select route_id into routeID from order_table where order_id=orderID;
        select order_date into OrderDate from order_table where order_id=orderID;
        select total_capacity into TotalCapacity from order_table where order_id=orderID;
        select store_name into StoreName from route where route_id =routeID;
        select train_session_id into trainID from train_schedule natural join arrival_station where  train_schedule.available_capacity > TotalCapacity and arrival_station.arrival_station=StoreName and departure_date > now() limit 1;
    end //


    CREATE PROCEDURE AddTruckSession (IN truckId INT, IN driverId INT, IN driverAssistantId INT, IN routeId INT, IN departureDate DATE, IN departureTime TIME)
    BEGIN
    DECLARE arrivalTime TIME;
    DECLARE availableCapacity NUMERIC(5,2);
    DECLARE weekNumber INT;
    DECLARE yearNumber INT;
    SET arrivalTime := (ADDTIME(departureTime, SEC_TO_TIME(3600*(SELECT time_taken FROM route WHERE route.route_id=routeID))));
    SET availableCapacity := (SELECT truck_capacity FROM truck WHERE truck.truck_id=truckID);
    SET weekNumber := WEEK(departureDate);
    SET yearNumber := YEAR(departureDate);
    INSERT INTO truck_schedule(truck_id, driver_id, driver_assistant_id, route_id, departure_date, departure_time, arrival_time, available_capacity, week_number, year_number)
    VALUES(truckId, driverId, driverAssistantId, routeId, departureDate, departureTime, arrivalTime, availableCapacity, weekNumber, yearNumber) ;
    update truck set used_hours = used_hours + format((arrivalTime - departureTime)/10000,0)  where truck_id = truckID;
    END //


    CREATE PROCEDURE Add_Driver_assistant(in name varchar(50), in nicNO varchar(15),in address_line_1 text,in address_line_2 text)
    begin
        insert into driver_assistant (driver_assistant_name,NIC,address_line1,address_line2) values (name,nicNO,address_line_1,address_line_2);
    end //


    CREATE PROCEDURE Add_Driver(in name varchar(50), in nicNO varchar(15),in address_line_1 text,in address_line_2 text)
    begin
        insert into driver (driver_name,NIC,address_line1,address_line2) values (name,nicNO,address_line_1,address_line_2);
    end //

    CREATE FUNCTION IsItemCountMatch(customerID INT)
      RETURNS int
      DETERMINISTIC

      BEGIN
        DECLARE rs int;
        DECLARE X int;
        DECLARE Y int;

        select total_quantity into X from cart_details where customer_id = customerID;
        select min_number_of_items into Y from customer_type type where customer_type IN (select customer_type from customer where customer_id = customerID);


        if Y > X THEN SET rs = 0;
        elseif Y then set rs = 1;
        else SET rs = 4;
        end if;

        RETURN rs;

      END //


    CREATE procedure AddToCart (IN customerID int , IN itemID int , IN quantity int)
    BEGIN
        declare cusID int;
        select count(customer_id) into cusID from cart where customer_id = customerID and item_id = itemID;

        if cusID = 0 then
        insert into cart values (customerID, itemID , quantity);
        else
        update cart set item_quantity = quantity where customer_id = customerID and item_id = itemID;
        end if;

    END //


    CREATE procedure RegisterUser (IN name varchar(50), IN user_name varchar(100),IN pw varchar(50), IN modee varchar(20))
    BEGIN
        INSERT INTO users VALUES (user_name,pw,modee);
        if modee = 'customer' then
        INSERT INTO customer (name , user_name) values (name,user_name);
        elseif modee = 'Store_manager' then
        INSERT INTO store_manager (name , user_name) values (name,user_name);
        elseif modee = 'Main_manager' then
        INSERT INTO main_manager (name , user_name) values (name,user_name);
        end if;
    END //


    CREATE FUNCTION UsedHoursOfTruck (TruckID int) RETURNS decimal(8,2) READS SQL DATA
    BEGIN
    declare UsedHours decimal(8,2) default 0;
    select used_hours into UsedHours from truck where truck_id=TruckID;
    RETURN UsedHours;
    END //


    CREATE FUNCTION WorkingHoursOfDriverAssistant (DriverAssistantID int ) RETURNS decimal(5,2) READS SQL DATA
    BEGIN
    declare WorkingHours decimal(5,2) default 0;
    select sum(working_hours) into WorkingHours from driver_assistant_working_hours where driver_assistant_id=DriverAssistantID;
    RETURN WorkingHours;
    END //


    CREATE FUNCTION WorkingHoursOfDriver (DriverID int ) RETURNS decimal(5,2) READS SQL DATA
    BEGIN
    declare WorkingHours decimal(5,2) default 0;
    select sum(working_hours) into WorkingHours from driver_working_hours where driver_id=DriverID;
    RETURN WorkingHours;
    END //


    CREATE PROCEDURE CustomerOrderReport (in customerID int,out customerName varchar(50),out Email varchar(100),out CustomerType varchar(10),out NoOfOrders int,out NoOfItems int,out total decimal(10,2),out total_discount decimal(10,2))
    BEGIN
    select name into customerName from customer where customer_id=customerID;
    select user_name into Email from customer where customer_id=customerID;
    select customer_type into CustomerType from customer where customer_id=customerID;
    select count(order_id) into NoOfOrders from order_table where customer_id=CustomerID group by customer_id;
    select sum(order_items.order_items_quantity) into NoOfITems from order_table natural join order_items where customer_id=customerID;
    select sum(total_price) into total from order_table where customer_id=customerID;
    select sum(discount) into total_discount from order_table where customer_id=customerID;
    END //


    CREATE FUNCTION GetRevenueOfGivenRouteGivenStore (GivenStoreName varchar(30), GivenRouteID int) RETURNS decimal(10,2) READS SQL DATA
    BEGIN
        DECLARE RouteRevenue DECIMAL(10,2) DEFAULT 0.0;
        set RouteRevenue = (SELECT t.rev FROM (SELECT store_name, route_id, sum(order_table.total_price) as rev FROM order_table natural join route where store_name=GivenStoreName group by order_table.route_id) as t WHERE t.route_id=GivenRouteID);
    RETURN RouteRevenue;
    END //


    CREATE PROCEDURE GetRevenueOfEachQuarterGivenYear (IN GivenYear year, OUT revenue_of_quarter_1 decimal(10,2), OUT revenue_of_quarter_2 decimal(10,2), OUT revenue_of_quarter_3 decimal(10,2), OUT revenue_of_quarter_4 decimal(10,2))
    BEGIN
        DECLARE revenueQ1 DEC(10,2) DEFAULT 0.0;
        DECLARE revenueQ2 DEC(10,2) DEFAULT 0.0;
        DECLARE revenueQ3 DEC(10,2) DEFAULT 0.0;
        DECLARE revenueQ4 DEC(10,2) DEFAULT 0.0;

        set revenueQ1 = (select GetRevenueOfGivenQuarterGivenYear(GivenYear, 1));
        set revenueQ2 = (select GetRevenueOfGivenQuarterGivenYear(GivenYear, 2));
        set revenueQ3 = (select GetRevenueOfGivenQuarterGivenYear(GivenYear, 3));
        set revenueQ4 = (select GetRevenueOfGivenQuarterGivenYear(GivenYear, 4));

        set revenue_of_quarter_1 = (select if (revenueQ1 is null, 0.0, revenueQ1));
        set revenue_of_quarter_2 = (select if (revenueQ2 is null, 0.0, revenueQ2));
        set revenue_of_quarter_3 = (select if (revenueQ3 is null, 0.0, revenueQ3));
        set revenue_of_quarter_4 = (select if (revenueQ4 is null, 0.0, revenueQ4));
    END //


    CREATE PROCEDURE Add_Train_Schedule(IN trainID INT, IN departureTime TIME, IN departureDate DATE, IN availableCapacity DECIMAL(5,2), IN arrivalStation VARCHAR(30))
    NOT DETERMINISTIC CONTAINS SQL
    SQL SECURITY DEFINER
    begin
        insert into train_schedule (train_id,departure_time,departure_date,available_capacity) values (trainID,departureTime,departureDate,availableCapacity);
        INSERT INTO arrival_station (train_session_id, arrival_station) values((select train_session_id from train_schedule where train_id=trainID and departure_time=departureTime and departure_date=departureDate), arrivalStation);
    end//


    CREATE PROCEDURE OrderAssignToTruck (in orderID int , in truck_sessionID int)
    BEGIN
        declare order_capacity decimal(5,2);
        select total_capacity into order_capacity from order_table where order_id = orderID;
        insert into order_truck_schedule values (orderID,truck_sessionID);
        update truck_schedule set available_capacity = available_capacity - order_capacity where truck_session_id = truck_sessionID;
        update order_table set delivery_state = "InTruck" where order_id = orderID;
    END //


    CREATE FUNCTION GetRevenueOfGivenQuarterGivenYear (GivenYear year, GivenQuarterNumber int) RETURNS decimal(10,2) READS SQL DATA
    BEGIN
        DECLARE QuarterlyRevenue DECIMAL(10,2) DEFAULT 0.0;
        set QuarterlyRevenue = (SELECT sum(monthly_revenue) from (select year(order_date) as revenue_year, month(order_date) as revenue_month, sum(total_price) as monthly_revenue from order_table where (year(order_date)=GivenYear) group by year(order_date), month(order_date) order by year(order_date), month(order_date)) as t where (revenue_month>=(((GivenQuarterNumber - 1) * 3) + 1)) and (revenue_month<=((GivenQuarterNumber) * 3)));
        RETURN QuarterlyRevenue;
    END //


    CREATE FUNCTION IsDriverAllowedToAssign (driverID INT, newSessionDepartureDate DATE, newSessionDepartureTime TIME) RETURNS tinyint(1)
        READS SQL DATA
    BEGIN
        RETURN IF((select HOUR(truck_schedule.arrival_time) from truck_schedule where truck_schedule.departure_date=newSessionDepartureDate and truck_schedule.driver_id=driverID ORDER BY truck_schedule.arrival_time DESC LIMIT 1) IS NULL,
        1,
        IF((select HOUR(truck_schedule.arrival_time) from truck_schedule where truck_schedule.departure_date=newSessionDepartureDate and truck_schedule.driver_id=driverID ORDER BY truck_schedule.arrival_time DESC LIMIT 1) + 1 < HOUR(newSessionDepartureTime), 1, 0));
    END //


    CREATE procedure InsertSampleRecords ( )
    BEGIN
        Insert into customer_type values('end',0.0,1);
        Insert into customer_type values('ret',0.2,3);
        Insert into customer_type values('whole',0.3,6);

        insert into items values ('201','Coffee Maker','1.6','7000','Mr. Coffee Coffee Maker with Auto Pause and Glass Carafe, 12 Cups, Black');
        insert into items values ('202','Rice Cooker','2.1','1800','6-Cup (Uncooked) Micom Rice Cooker | 12 Menu Options: White Rice, Brown Rice & More, Nonstick Inner Pot');
        insert into items values ('203','Electric Kettle','1.6','7000','1500W Electric Kettle with SpeedBoil Tech, 1.8 Liter Cordless with LED Light, Borosilicate Glass, Auto Shut-Off and Boil-Dry Protection');
        insert into items values ('204','Oven','3','40000','Bravo Air Fryer Oven , 12-in-1, 30QT XL Large Capacity Digital Countertop Convection Oven');
        insert into items values ('205','Electric Fan','2.5','10000','Small Room Air Circulator Fan, 11-Inch');

        insert into store values('Colombo','23/D','Colombo');
        insert into store values('Negombo','10','Negombo');
        insert into store values('Galle','43','Galle');
        insert into store values('Matara','32','Matara');
        insert into store values('Jaffna','23/E','Jaffna');
        insert into store values('Trinco','14','Trinco');

        insert into truck(truck_id,truck_capacity,used_hours,store_name) values (801,20,20000,'Colombo');
        insert into truck(truck_id,truck_capacity,used_hours,store_name) values (802,30,25000,'Colombo');
        insert into truck(truck_id,truck_capacity,used_hours,store_name) values (803,25,23000,'Colombo');
        insert into truck(truck_id,truck_capacity,used_hours,store_name) values (804,30,22000,'Matara');
        insert into truck(truck_id,truck_capacity,used_hours,store_name) values (805,100,24000,'Matara');

        insert into Driver(driver_id,driver_name,NIC,address_line1,address_line2,store_name)
        values('1','Sasindu','200008400671','245','thissamaharama','Colombo');
        insert into Driver(driver_id,driver_name,NIC,address_line1,address_line2,store_name)
        values('2','Bimal','202343240676','45','katubedda','Colombo');
        insert into Driver(driver_id,driver_name,NIC,address_line1,address_line2,store_name)
        values('3','Navinda','208785700673','235','maharagama','Matara');

        insert into Driver_assistant(driver_assistant_id,driver_assistant_name,NIC,address_line1,address_line2,store_name)
        values('1','Ama','20004545456','285','maharagama','Matara');
        insert into Driver_assistant(driver_assistant_id,driver_assistant_name,NIC,address_line1,address_line2,store_name)
        values('2','Shamindi','208785700673','115','nugegoda','Colombo');
        insert into Driver_assistant(driver_assistant_id,driver_assistant_name,NIC,address_line1,address_line2,store_name)
        values('3','Chinthani','200018400870','5','gampaha','Colombo');

        Insert into route(store_name,route_id,time_taken) values ('Colombo','601','5'),
        ('Colombo','602','7'),
        ('Negombo','603','4'),
        ('Negombo','604','6'),
        ('Galle','605','8'),
        ('Galle','606','3'),
        ('Matara','607','5'),
        ('Matara','608','8'),
        ('Jaffna','609','6'),
        ('Jaffna','610','7');

        insert into train values("1010",100);
        insert into train values("1011",150);
        insert into train values("1012",200);
        insert into train values("1013",100);
        insert into train values("1014",200);

    END //

    DELIMITER ;


    create view items_with_most_orders as select order_items.item_id,item_name,count(order_items.item_id) as no_of_orders,sum(order_items_quantity) as sum_of_quantity from order_items,items where order_items.item_id=items.item_id group by item_id order by sum_of_quantity desc limit 10 ;

    create view cart_items as select item_id , customer_id,item_quantity,item_name,capacity,price,description, item_quantity * price as total_price from cart natural join items ;

    create view cart_details as select customer_id , sum(total_price) as total_price , sum(item_quantity) as total_quantity from cart_items group by customer_id;

    CREATE VIEW route_revenue_view AS SELECT t.route_id, route.store_name, t.revenue_of_route FROM (SELECT order_table.route_id, SUM(order_table.total_price) AS revenue_of_route FROM order_table GROUP BY order_table.route_id) AS t NATURAL JOIN route;

    CREATE VIEW trucks_used_hours AS SELECT truck.truck_id, truck.store_name, SUM(truck.used_hours) AS used_hours FROM truck GROUP BY truck.truck_id;

    CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW manager_order_view AS SELECT order_table.order_id AS order_id, order_table.customer_id AS customer_id, order_table.number_of_items AS number_of_items, order_table.order_date AS order_date, order_table.order_time AS order_time, order_table.total_price AS total_price, order_table.total_capacity AS total_capacity, order_table.route_id AS route_id, order_table.delivery_state AS delivery_state FROM order_table;

    create view driver_working_hours as select driver_id , week(departure_date) as week_number ,Year(departure_date) as year_number , format(sum(arrival_time - departure_time)/10000,0) as working_hours from truck_schedule group by driver_id,year(departure_date),week(departure_date) ;

    create view driver_assistant_working_hours as select driver_assistant_id , week(departure_date) as week_number ,Year(departure_date) as year_number , format(sum(arrival_time - departure_time)/10000,0) as working_hours from truck_schedule group by driver_assistant_id,year(departure_date),week(departure_date) ;


    DELIMITER //

    create trigger CheckTrain before insert on order_train_schedule
    for each row
    begin
        declare trainID int;
        declare err_msg varchar(100);
        declare isCapacityAvailable boolean;
         call AvailableTrains(new.order_id,@train);
         select @train into trainID;
         select((select available_capacity from train_schedule where train_session_id=new.train_session_id) > (select total_capacity from order_table where order_id=new.order_id)) into isCapacityAvailable;
         select CONCAT("Order cannot assign to train. Available Train Session ID ", trainID) into err_msg;
        if ( (new.train_session_id != trainID) or (isCapacityAvailable != 1 ) ) then
        SIGNAL sqlstate '50001' set message_text = err_msg;
        end if;
    end //


    CREATE TRIGGER CheckTruckCapacity BEFORE INSERT ON order_truck_schedule FOR EACH ROW
    BEGIN
        DECLARE isCapacityAvailable BOOLEAN;
        SELECT((SELECT available_capacity FROM truck_schedule WHERE truck_session_id = NEW.truck_session_id) > (SELECT total_capacity FROM order_table WHERE order_id = NEW.order_id)) INTO isCapacityAvailable;
    IF(isCapacityAvailable != 1)
    THEN SIGNAL SQLSTATE '50001' SET MESSAGE_TEXT = "Not enough capacity in the truck";
    END IF;
    END //


    create trigger CheckDriverHour before insert on truck_schedule
    for each row
    begin
    declare hours int ;
    select working_hours into hours from driver_working_hours
    where   driver_id = new.driver_id and
            year_number = YEAR(new.departure_date) and
            week_number = WEEK(new.departure_date) ;
    set hours = hours + format((new.arrival_time - new.departure_time)/10000,0);
    if ( hours > 40 ) then
    SIGNAL sqlstate '50001' set message_text = "Driver has exceeded weekly work hours (40)!";
    end if;
    end //


    create trigger CheckDriverAssistantHour before insert on truck_schedule
    for each row
    begin
    declare hours int ;
    select working_hours into hours from driver_assistant_working_hours
    where   driver_assistant_id = new.driver_assistant_id and
            year_number = YEAR(new.departure_date) and
            week_number = WEEK(new.departure_date) ;
    set hours = hours + format((new.arrival_time - new.departure_time)/10000,0);
    if ( hours > 60 ) then
    SIGNAL sqlstate '50001' set message_text = "Driver Assistant has exceeded weekly work hours (60)!";
    end if;
    end //


    create trigger CheckDriver before insert on truck_schedule
    for each row
    begin
    declare result int;
    select IsDriverAllowedToAssign(new.driver_id , new.departure_date , new.departure_time) into result;
    if ( result = 0 ) then
    SIGNAL sqlstate '50001' set message_text = "Driver cannot be assigned to two consecutive Truck schedule";
    end if;
    end //

    DELIMITER ;

    

    CALL InsertSampleRecords();