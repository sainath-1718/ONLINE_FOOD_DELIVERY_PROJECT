CREATE DATABASE food_app_project;
USE food_app_project;

-- Table 1: customers (No dependencies)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(255) ,
    city VARCHAR(250),
    signup_date DATE NOT NULL,
    gender VARCHAR(10)
);

-- Table 2: restaurants (No dependencies)
CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    rest_name VARCHAR(255),
    city VARCHAR(50) ,
    cuisine VARCHAR(50),
    rating DECIMAL(2,1)
);

-- Table 3: Delivery agents (No dependencies)
CREATE TABLE delivery_agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100),
    city VARCHAR(50),
    joining_date DATE,
    rating DECIMAL(2,1)
);

-- Table 4: orders (Depends on customers and restaurants)
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_date DATE,
    order_amount DECIMAL(10,2),
    discount DECIMAL(10,2),
    payment_method VARCHAR(20),
    delivery_time INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- Table 5: order_item (Depends on orders)
CREATE TABLE order_item (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    item_name VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);




-- PHASE 8-- Performance Optimization
--  Index on order_date (for monthly reports)
CREATE INDEX idx_order_date ON orders(order_date);


-- Index on customer_name (for joins)
CREATE INDEX idx_customer_name ON customers(name);

-- Index on restaurant_name
CREATE INDEX idx_restaurant_name ON restaurants(restaurant_name);


-- PHASE 9 —Automation Logic

-- TRIGGER 1 — Prevent Negative Discount

CREATE TRIGGER prevent_negative_discount
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.discount < 0 THEN
        SET NEW.discount = 0;
    END IF;
END 

INSERT INTO orders VALUES (1014, 231, 138, '2024-01-01', 100.00, -10.00, 'Credit Card', 30);
 SELECT * FROM orders WHERE order_id = 1014;

-- TRIGGER 2 — Delivery Delay Warning
CREATE TABLE delivery_delay_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    customer_id INT,

    delay_minutes INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    restaurant_id INT
);
CREATE TRIGGER log_delivery_delay
AFTER insert ON orders
FOR EACH ROW
BEGIN
    IF NEW.delivery_time > 45 THEN
        INSERT INTO delivery_delay_log (order_id, customer_id, delay_minutes, restaurant_id)
        VALUES (NEW.order_id, NEW.customer_id, NEW.delivery_time - 45, NEW.restaurant_id);
    END IF;
END;

INSERT INTO orders VALUES (1015, 232, 139, '2024-01-02', 150.00, 20.00, 'Cash', 50);
SELECT * FROM delivery_delay_log WHERE order_id = 1015;