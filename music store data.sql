use musicstore;
show tables;

## Question 1. Who is senior most employee based on job title?
select * from employee
order by levels Desc
limit 1;

## Question 2: Which countries have the most invoice ?
select count(*) as c, billing_country  from invoice
group by billing_country
order by c desc;

##Question 3:What are the top 3 values of total_invoice?
select * from invoice;
select total from invoice
order by total desc
limit 3 ;

##Question 4: Which city has the best coustomers? We would like to throw a promotional 
##Music Festival in the city we made the most money.Write a query that returns one city that has the highest sum of 
## invoice totals.Retuen both the city and sum of all invoice totals.alter

select sum(total) as invoice_total,billing_city from invoice
group by  billing_city
order by invoice_total desc 
limit 1; 

##Question 5:Who is the best customer?The customer who has spent the most money will be declared the 
##best customer.Write a query that return the person who has spent the most money?
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(i.total) AS total
FROM
    customer c
JOIN
    invoice i ON i.customer_id = c.customer_id
GROUP BY
    c.customer_id ,c.first_name,c.last_name
ORDER BY
    total DESC
LIMIT 1;

##Question 6:Write query to return the email,first_name,last_name & Genre of all Rock Music listeners.Return your list ordered alphabetically by email starting with A


select  c.first_name,c.last_name,c.email from customer c
join invoice i
on i.customer_id = c.customer_id
join invoice_line l
on l.invoice_id = i.invoice_id
join track t
on t.track_id  = l.track_id
join genre g
on g.genre_id =t.genre_id
where g.name like 'Rock' and email like 'a%'
order by c.email ;

##Question 7: Let's invite the artists who have written the most rock music in our 
#dataset.Write a query that returns the Artist name and total track count of the 
#top 10 rock
SELECT artist.name AS Artist_Name, COUNT(*) AS Total_Tracks
FROM track
JOIN album2 ON album2.album_id = track.album_id
JOIN artist ON artist.artist_id = album2.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.name
ORDER BY Total_Tracks DESC
LIMIT 10;

##Question8: Return all the track names that have a song length longer than the average song length .
##Return the Names and milliseconds for each track.Order by the song length with the longest songs listed first.
SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;


##Question 9:Find how much amount spent by each customer on artists ?
## Write a query to return customer name,artist name  and total spent?

 SELECT c.customer_id, c.first_name, c.last_name, ar.name AS artist_name, SUM(il.unit_price) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
GROUP BY 1,2,3,4
ORDER BY total_spent DESC;

##or we can solve this query via cte
WITH best_Selling_artist AS (
    SELECT ar.artist_id AS artist_id, ar.name AS artist_name, SUM(il.unit_price * il.quantity) AS total_spent
    FROM invoice_line il
    JOIN track t ON t.track_id = il.track_id
    JOIN album2 a ON t.album_id = a.album_id
    JOIN artist ar ON a.artist_id = ar.artist_id
    GROUP BY ar.artist_id, ar.name
    ORDER BY 3 DESC
    LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name AS artist_name, SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 a ON t.album_id = a.album_id
JOIN best_Selling_artist bsa ON bsa.artist_id = a.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY 5 DESC;

##Question 10:We want to find out the most popular genre for each country .
##we determine the most popular genre as the genre with the highest amount of purchases .
#write a query that returns each country along with the top genre .
##for countries where the maximum number of purcxhases is shared return all geres .


    WITH popular_genre AS
(
    SELECT 
        COUNT(il.quantity) AS purchases,
        c.customer_id,
        g.name,
        g.genre_id,
        ROW_NUMBER() OVER (PARTITION BY c.country, g.genre_id ORDER BY COUNT(il.quantity) DESC) AS Row_no
    FROM invoice_line il
    JOIN invoice i ON i.invoice_id = il.invoice_id
    JOIN customer c ON c.customer_id = i.customer_id
    JOIN track t ON t.track_id = il.track_id 
    JOIN genre g ON g.genre_id = t.genre_id 
    GROUP BY c.customer_id, g.name, g.genre_id, c.country
)

SELECT * FROM popular_genre WHERE Row_no = 1;


##Question 11: Write a query that determines the customer that has spent the most on music for each 
##country. Write a query that returns the country along with the top customer and how 
##much they spent. For countries where the top amount spent is shared, provide all 
##customers who spent this amount 

WITH Customer_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customer_with_country WHERE RowNo <= 1;




