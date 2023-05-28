CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100)
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name varchar(100),
    price decimal
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer,
    order_date date
);

CREATE TABLE order_items (
    order_id integer,
    product_id integer,
    quantity integer
);

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'John', 'Doe', 'johndoe@email.com'),
(2, 'Jane', 'Smith', 'janesmith@email.com'),
(3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
(4, 'Alice', 'Brown', 'alicebrown@email.com'),
(5, 'Charlie', 'Davis', 'charliedavis@email.com'),
(6, 'Eva', 'Fisher', 'evafisher@email.com'),
(7, 'George', 'Harris', 'georgeharris@email.com'),
(8, 'Ivy', 'Jones', 'ivyjones@email.com'),
(9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
(10, 'Lily', 'Nelson', 'lilynelson@email.com'),
(11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
(12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
(13, 'Sophia', 'Thomas', 'sophiathomas@email.com');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Product A', 10.00),
(2, 'Product B', 15.00),
(3, 'Product C', 20.00),
(4, 'Product D', 25.00),
(5, 'Product E', 30.00),
(6, 'Product F', 35.00),
(7, 'Product G', 40.00),
(8, 'Product H', 45.00),
(9, 'Product I', 50.00),
(10, 'Product J', 55.00),
(11, 'Product K', 60.00),
(12, 'Product L', 65.00),
(13, 'Product M', 70.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-05-02'),
(3, 3, '2023-05-03'),
(4, 1, '2023-05-04'),
(5, 2, '2023-05-05'),
(6, 3, '2023-05-06'),
(7, 4, '2023-05-07'),
(8, 5, '2023-05-08'),
(9, 6, '2023-05-09'),
(10, 7, '2023-05-10'),
(11, 8, '2023-05-11'),
(12, 9, '2023-05-12'),
(13, 10, '2023-05-13'),
(14, 11, '2023-05-14'),
(15, 12, '2023-05-15'),
(16, 13, '2023-05-16');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 1),
(2, 3, 3),
(3, 1, 1),
(3, 3, 2),
(4, 2, 4),
(4, 3, 1),
(5, 1, 1),
(5, 3, 2),
(6, 2, 3),
(6, 1, 1),
(7, 4, 1),
(7, 5, 2),
(8, 6, 3),
(8, 7, 1),
(9, 8, 2),
(9, 9, 1),
(10, 10, 3),
(10, 11, 2),
(11, 12, 1),
(11, 13, 3),
(12, 4, 2),
(12, 5, 1),
(13, 6, 3),
(13, 7, 2),
(14, 8, 1),
(14, 9, 2),
(15, 10, 3),
(15, 11, 1),
(16, 12, 2),
(16, 13, 3);

  /* --------------------
   Case Study Questions
   --------------------*/

--1) Which product has the highest price? Only return a single row.
    
    SELECT product_name 
      FROM products
      WHERE price = (SELECT MAX(price) FROM products);
      
--2) Which customer has made the most orders?
    
    WITH max_orders AS(
      SELECT customer_id, first_name, last_name, COUNT(customer_id) AS max_order,
      RANK() OVER(ORDER BY COUNT(customer_id) DESC) AS max_order_cust
        FROM customers c
        INNER JOIN orders o
        USING (customer_id)
        GROUP BY customer_id
      )
    
    SELECT customer_id, first_name, last_name, max_order
      FROM max_orders
      WHERE max_order_cust = 1;
    
--3) What’s the total revenue per product?
    
    SELECT product_id, product_name, price * SUM(quantity) AS revenue
      FROM products p
      INNER JOIN order_items oi
      USING (product_id)
      GROUP BY product_id;
    
    --4) Find the day with the highest revenue.
    
    WITH total_revenue AS(
      SELECT order_date, SUM(price * quantity) AS revenue,
      RANK() OVER(ORDER BY SUM(price * quantity) DESC) AS highest_revenue
        FROM orders o
        INNER JOIN order_items oi
        ON o.order_id = oi.order_id
        INNER JOIN products p
        ON oi.product_id = p.product_id
        GROUP BY order_date
      )
    
    SELECT order_date, revenue
      FROM total_revenue
      WHERE highest_revenue = 1;
    
--5) Find the first order (by date) for each customer.

    WITH first_order AS(
    SELECT customer_id, product_name, order_date,
    DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date ASC) AS order_first
      FROM orders o
      INNER JOIN order_items oi
      ON o.order_id = oi.order_id
      INNER JOIN products p
      ON oi.product_id = p.product_id
    )

   SELECT customer_id, product_name, order_date
     FROM first_order
    WHERE order_first = 1;

--6) Find the top 3 customers who have ordered the most distinct products
    
    SELECT c.customer_id, first_name, last_name, COUNT(DISTINCT product_id) AS distinct_products
      FROM customers c
      INNER JOIN orders o
      ON c.customer_id = o.customer_id
      INNER JOIN order_items oi
      ON o.order_id = oi.order_id
      GROUP BY c.customer_id, first_name, last_name
      ORDER BY distinct_products DESC, customer_id
      LIMIT 3;
    
--7) Which product has been bought the least in terms of quantity?
    
    WITH least_products_bought AS(
      SELECT product_name, p.product_id, SUM(quantity) AS least_bought_products,
      DENSE_RANK() OVER (ORDER BY SUM(quantity)) AS rnk
        FROM products p
        INNER JOIN order_items oi
        ON p.product_id = oi.product_id
        GROUP BY product_name, p.product_id
      )
      
    SELECT product_name, product_id, least_bought_products
      FROM least_products_bought
      WHERE rnk = 1;
    
--8) What is the median order total?
    
    WITH order_total AS(	
      SELECT order_id, SUM(p.price * quantity) AS total
      FROM products p
      INNER JOIN order_items oi
      ON P.product_id = oi.product_id
      GROUP BY order_id
      )
      
    SELECT PERCENTILE_CONT(.5)  WITHIN GROUP (ORDER BY total) AS total_order_median
      FROM order_total;
    
--9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.
    
    WITH order_classification AS(
      SELECT order_id, SUM(price * quantity) AS revenue
        FROM products p
        INNER JOIN order_items oi
        ON p.product_id = oi.product_id
        GROUP BY order_id
      )
      
    SELECT order_id, revenue,
      CASE WHEN revenue > 300 THEN 'Expensive'
      WHEN revenue > 100 THEN 'Affordable'
      ELSE 'Cheap'
      END AS order_classified
        FROM order_classification
        ORDER BY order_id;
    
--10) Find customers who have ordered the product with the highest price.
    
    SELECT c.customer_id, CONCAT(first_name,' ',last_name) AS Full_name, product_name, price AS highest_price
      FROM products p
      INNER JOIN order_items oi
      ON p.product_id = oi.product_id
      INNER JOIN orders o
      ON oi.order_id = o.order_id
      INNER JOIN customers c
      ON c.customer_id = o.customer_id
      WHERE price IN (SELECT MAX(price) FROM products);
