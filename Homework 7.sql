-- initialize database
use sakila;

-- view all contents of actor table
SELECT * FROM actor;

-- 1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name FROM actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name' FROM actor; 

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE "Joe%";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT *
FROM actor
WHERE last_name LIKE "%gen%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE "%li%";

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
-- so create a column in the table actor named description and use the data type BLOB 
ALTER TABLE actor
	ADD description BLOB;
    
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
	DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS "Number of Occurences"
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by
-- at least two actors
SELECT last_name, COUNT(last_name) AS "Number of Occurences"
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "Harpo", last_name = "Williams"
WHERE first_name = "Groucho" AND last_name = "Williams";

-- 4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "Groucho"
WHERE first_name = "Harpo";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SELECT Table_Schema, Table_Name
FROM information_schema.tables
where Table_Name = "address";

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT * from staff;
SELECT * from address;
SELECT staff.first_name, staff.last_name, address.address	
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT * FROM payment;
SELECT first_name, last_name, sum(payment.amount) AS "Total Amount Aug. 05"
FROM payment
LEFT JOIN staff on staff.staff_id=payment.staff_id
WHERE payment.payment_date like "2005-08%"
GROUP BY staff.first_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT * FROM film_actor;
SELECT * from film;
SELECT film.title, count(film_actor.actor_id) as "Number of Actors"
FROM film
LEFT JOIN film_actor on film.film_id=film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * from inventory;
SELECT film.title, count(inventory.inventory_id) as "Number of Copies"
FROM film
LEFT JOIN inventory on film.film_id=inventory.film_id
GROUP BY film.title
HAVING title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT * from customer;
SELECT last_name, first_name, sum(amount) AS "Total Paid"
FROM customer
LEFT JOIN payment ON customer.customer_id=payment.customer_id
GROUP BY customer.customer_id
ORDER BY last_name;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT * from language;
SELECT title
FROM film
WHERE title like "K%" OR title like "Q%" AND language_id =
  (SELECT language_id
  FROM language
  where name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id in (
  SELECT actor_id
  FROM film_actor
  WHERE film_id in (
    SELECT film_id
    FROM film
    WHERE title = "Alone Trip"));

-- 7c. You will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer
LEFT JOIN address on address.address_id = customer.address_id
LEFT JOIN city on city.city_id = address.city_id
LEFT JOIN country on country.country_id = city.country_id
WHERE country.country = "Canada";

-- 7d. Identify all movies categorized as family films.
SELECT * from category;
SELECT title
from film 
WHERE film_id in (
  SELECT film_id 
  FROM film_category
  WHERE category_id in (
    SELECT category_id
    FROM category
    WHERE name = "Family"));

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, count(rental_id) as "Rental Frequency"
FROM film
LEFT JOIN inventory ON inventory.film_id=film.film_id
LEFT JOIN rental ON inventory.inventory_id=rental.inventory_id
GROUP BY film.title
ORDER BY count(rental_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * from store;
SELECT store.store_id, sum(payment.amount) AS "Total Amount"
FROM store
LEFT JOIN staff on staff.store_id=store.store_id
LEFT JOIN payment on staff.staff_id=payment.staff_id
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store
LEFT JOIN address on address.address_id=store.address_id
LEFT JOIN city on address.city_id=city.city_id
LEFT JOIN country on country.country_id=city.country_id;

-- List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT * FROM category;
SELECT category.name AS "Genre", sum(payment.amount) AS "Gross Revenue"
FROM payment
LEFT JOIN rental ON rental.rental_id=payment.rental_id
LEFT JOIN inventory ON inventory.inventory_id=rental.inventory_id
LEFT JOIN film_category ON film_category.film_id=inventory.film_id
LEFT JOIN category ON category.category_id = film_category.category_id
WHERE category.name is NOT NULL
GROUP BY category.name
LIMIT 5;

-- 8a. Use the solution from the problem above to create a view
CREATE VIEW genre_rev 
AS SELECT category.name AS "Genre", sum(payment.amount) AS "Gross Revenue"
FROM payment
LEFT JOIN rental ON rental.rental_id=payment.rental_id
LEFT JOIN inventory ON inventory.inventory_id=rental.inventory_id
LEFT JOIN film_category ON film_category.film_id=inventory.film_id
LEFT JOIN category ON category.category_id = film_category.category_id
WHERE category.name is NOT NULL
GROUP BY category.name
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * from genre_rev;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW genre_rev;













