/*Who is the senior most employee based on job title? */
SELECT 
  title, 
  last_name, 
  first_name, 
  hire_date 
FROM 
  MusicStore.dbo.employee
ORDER BY 
  levels DESC;

  /*Which countries have the most Invoices? */
Select 
  count(*) as C, 
  billing_country 
from 
  MusicStore.dbo.invoice 
group by 
  billing_country 
order by 
  C desc


/*What are top 3 values of total invoice? */
Select 
  top 3 total 
from 
  MusicStore.dbo.invoice 
order by 
  total desc

  /*Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one 
  city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals */
Select 
  top 1 billing_city, 
  sum(total) as sum 
from 
  MusicStore.dbo.invoice 
Group by 
  billing_city 
order by 
  sum desc


/*Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent
the most money */
Select 
  Top 1 invoice.customer_id, 
  sum(total) as sum, 
  first_name, 
  last_name 
from 
  MusicStore.dbo.invoice 
  Join MusicStore.dbo.customer on invoice.customer_id = customer.customer_id 
Group by 
  invoice.customer_id, 
  first_name, 
  last_name 
order by 
  sum desc



/*Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A */
Select 
  Distinct customer.email, 
  customer.first_name, 
  customer.last_name 
from 
  MusicStore.dbo.customer 
  join MusicStore.dbo.invoice on customer.customer_id = invoice.customer_id 
  join MusicStore.dbo.invoice_line on invoice.invoice_id = invoice_line.invoice_id 
  join MusicStore.dbo.track on invoice_line.track_id = track.track_id 
  join MusicStore.dbo.genre on track.genre_id = genre.genre_id 
Where 
  genre.name Like 'Rock' 
order by 
  customer.email


  /*Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of
  the top 10 rock bands*/
Select 
  top 10 artist.name, 
  count(track.track_id) as C 
from 
  MusicStore.dbo.artist 
  join MusicStore.dbo.album on artist.artist_id = album.artist_id 
  Join MusicStore.dbo.album2 on album2.album_id = album.album_id 
  Join MusicStore.dbo.track on track.album_id = album2.album_id 
  join MusicStore.dbo.genre on genre.genre_id = track.genre_id 
where 
  genre.name LIKE 'Rock' 
group by 
  artist.name 
order by 
  C desc

 /*Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track.
 Order by the song length with the longest songs listed first */
Select 
  name, 
  milliseconds 
from 
  track 
where 
  milliseconds > (
    select 
      avg(milliseconds) as avg 
    from 
      track
  ) 
order by 
  milliseconds desc

  /*Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
  WITH best_selling_artist AS (
    SELECT TOP 1 
        artist.artist_id AS artist_id, 
        artist.name AS artist_name, 
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM 
        invoice_line
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        album ON album.album_id = track.album_id
    JOIN 
        artist ON artist.artist_id = album.artist_id
    GROUP BY 
        artist.artist_id, artist.name
    ORDER BY 
        total_sales DESC
)
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    bsa.artist_name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM 
    invoice i
JOIN 
    customer c ON c.customer_id = i.customer_id
JOIN 
    invoice_line il ON il.invoice_id = i.invoice_id
JOIN 
    track t ON t.track_id = il.track_id
JOIN 
    album alb ON alb.album_id = t.album_id
JOIN 
    best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY 
    amount_spent DESC;


/* We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id  -- Include all non-aggregated columns here
)
SELECT * FROM popular_genre 
WHERE RowNo <= 1
ORDER BY country ASC, purchases DESC;


/* Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
WITH Customer_with_country AS (
    SELECT 
        customer.customer_id,
        first_name,
        last_name,
        billing_country,
        SUM(total) AS total_spending,
        ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
    FROM 
        invoice
    JOIN 
        customer ON customer.customer_id = invoice.customer_id
    GROUP BY 
        customer.customer_id,
        first_name,
        last_name,
        billing_country
)
SELECT 
    * 
FROM 
    Customer_with_country 
WHERE 
    RowNo <= 1
ORDER BY 
    billing_country ASC, 
    total_spending DESC;









  
