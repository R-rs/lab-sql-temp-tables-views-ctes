#Challenge
#Creating a Customer Summary Report

/*In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database,
including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.*/
USE sakila;

# Step 1: Create a View
/* First, create a view that summarizes rental information for each customer.
The view should include the customer's ID, name, email address, and total number of rentals (rental_count).*/

SELECT * FROM customer;
SELECT * FROM rental;

CREATE VIEW rental_information AS 
SELECT c.customer_id, CONCAT(c.first_name,' ', c.last_name) AS full_name, c.email, COUNT(*) rental_count
FROM rental r
LEFT JOIN customer c
ON r.customer_id = c.customer_id
GROUP BY c.customer_id;

SELECT * FROM rental_information;


# Step 2: Create a Temporary Table
/* Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.*/
SELECT * FROM payment;

CREATE TEMPORARY TABLE total_paid_2 AS
SELECT ri.customer_id, SUM(p.amount) total_paid_cust
FROM payment p
LEFT JOIN rental_information ri
ON p.customer_id=ri.customer_id
GROUP BY ri.customer_id;

CREATE TEMPORARY TABLE total_paid AS
SELECT ri.*, extra_col.total_paid_cust
FROM rental_information ri
INNER JOIN (SELECT ri.customer_id, SUM(p.amount) total_paid_cust
			FROM payment p
			LEFT JOIN rental_information ri
			ON p.customer_id=ri.customer_id
			GROUP BY ri.customer_id) extra_col
ON ri.customer_id = extra_col.customer_id;

SELECT * FROM total_paid;
SELECT * FROM total_paid_2;

# Step 3: Create a CTE and the Customer Summary Report
/* Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2.
The CTE should include the customer's name, email address, rental count, and total amount paid.*/

WITH rental_summary AS(
		SELECT ri.*, total_paid_2.total_paid_cust
		FROM rental_information ri
		INNER JOIN total_paid_2
        ON ri.customer_id = total_paid_2.customer_id)
SELECT * FROM rental_summary;

/* Next, using the CTE, create the query to generate the final customer summary report, which should include:
customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.*/

WITH rental_summary AS(
		SELECT ri.*, total_paid_2.total_paid_cust
		FROM rental_information ri
		INNER JOIN total_paid_2
        ON ri.customer_id = total_paid_2.customer_id)
SELECT rs.full_name, rs.email, rs.rental_count, rs.total_paid_cust,
		CASE 
		WHEN customer_id IS NOT NULL THEN ROUND(total_paid_cust/rental_count,2)
		END AS average_payment_per_rental
FROM rental_summary rs;