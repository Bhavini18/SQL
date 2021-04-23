use sql2;

-- --------------------------------------------------------------
# Dataset Used: wine.csv
-- --------------------------------------------------------------

SELECT * FROM wine;

# Q1. Rank the winery according to the quality of the wine (points).-- Should use dense rank

select points, variety,winery, dense_rank() over(order by points) as Point_wise from wine;

# Q2. Give a dense rank to the wine varities on the basis of the price.

select *, dense_rank() over(partition by (variety) order by price) as variety_wise from wine; 


# Q3. Use aggregate window functions to find the average of points for each row within its partition (country). 
-- -- Also arrange the result in the descending order by country.

SELECT  country,points,                  
AVG(points) OVER(partition by country) AS average       
FROM wine order by country desc;

-----------------------------------------------------------------
# Dataset Used: students.csv
-- --------------------------------------------------------------

# Q4. Rank the students on the basis of their marks subjectwise.

SELECT *,
rank() over (partition by subject  order by marks desc) as rnk
FROM students;

# Q5. Provide the new roll numbers to the students on the basis of their names alphabetically.

SELECT name, row_number() over ( order by name ) as name_alpha
FROM students;

# Q6. Use the aggregate window functions to display the sum of marks in each row within its partition (Subject).

select subject, marks, sum(marks) over(partition by subject) as eachSubMarks from students;

# Q7. Display the records from the students table where partition should be done 
-- on subjects and use sum as a window function on marks, 
-- -- arrange the rows in unbounded preceding manner.

select *, sum(marks) over(partition by subject rows unbounded preceding) as std_records
from students;


# Q8. Find the dense rank of the students on the basis of their marks subjectwise. Store the result in a new table 'Students_Ranked'

create table student_rank as
select subject, marks, dense_rank() over(partition by subject order by marks ) as subject_rank
from students;

select * from student_rank;

update website_stats set day = str_to_date(day,'%d-%m-%Y');
-----------------------------------------------------------------
# Dataset Used: website_stats.csv and web.csv
-----------------------------------------------------------------
# Q9. Show day, number of users and the number of users the next day (for all days when the website was used)
select day,no_users, id, name, 
lead(no_users,1) over(order by day) as day_total
from web as w inner join website_stats as ws on w.id=ws.website_id;

# Q10. Display the difference in ad_clicks between the current day and the next day for the website 'Olympus'

select website_id,day,ad_clicks,
lead(ad_clicks,1,0) over (order by day) as next_day_ad,
(ad_clicks)-(lead(ad_clicks,1,0) over (order by day)) as difference
from website_stats 
where website_id=(select id from web where name='olympus');

# Q11. Write a query that displays the statistics for website_id = 3 such that for each row, show the day, the number of users and the smallest number of users ever.

select day,no_users,first_value(no_users) 
over(order by no_users) as small_users_ever
from website_stats
where website_id = 3
order by day;

# Q12. Write a query that displays name of the website and it's launch date. The query should also display the date of recently launched website in the third column.

select website_id, name, launch_date, day from
(select website_id, day, rank() over
(partition by website_id order by day desc )
 as row_num from website_stats) as dummy_t
inner join web w 
on dummy_t.website_id=w.id
where row_num=1;

-----------------------------------------------------------------
# Dataset Used: play_store.csv and sale.csv
-----------------------------------------------------------------
# Q13. Write a query thats orders games in the play store into three buckets as per editor ratings received  
select id,name, platform, editing_rating, ntile(2) over 
(order by editor_rating)
from play_store;

# Q14. Write a query that displays the name of the game, the price, the sale date and the 4th column should display 
# the sales consecutive number i.e. ranking of game as per the sale took place, so that the latest game sold gets number 1. Order the result by editor's rating of the game

select name, price, date as sale_date,
rank() over( order by str_to_date(date, '%d-%m-%Y') desc) as
date_rank from play_store as ps join sale as s
on ps.id=s.game_id
order by editor_rating;


# Q15. Write a query to display games which were both recently released and recently updated. For each game, show name, 
#date of release and last update date, as well as their rank
#Hint: use ROW_NUMBER(), sort by release date and then by update date, both in the descending order

select *, row_number() over 
(order by released desc, updated desc) as 'row update' from play_store ;



-----------------------------------------------------------------
# Dataset Used: movies.csv, customers.csv, ratings.csv, rent.csv
-----------------------------------------------------------------
# Q16. Write a query that displays basic movie informations as well as the previous rating provided by customer for that same movie 
# make sure that the list is sorted by the id of the reviews.

select 	title,release_year,genre,editor_rating, rating as Customer_Rating, 
lag(rating,1,"No Previous Customer Rating") 
over(partition by title order by r.id) 
Previous_Customer_Rating from ratings r
join movies m on r.movie_id = m.id
order by r.id;


# Q17. For each movie, show the following information: title, genre, average user rating for that movie 
# and its rank in the respective genre based on that average rating in descending order (so that the best movies will be shown first).

with subquery(average, mid) as (select avg(rating), movie_id from ratings group by movie_id)
select title, genre, average, rank() 
over(partition by genre order by average desc) from movies, subquery; 

# Q18. For each rental date, show the rental_date, the sum of payment amounts (column name payment_amounts) from rent 
#on that day, the sum of payment_amounts on the previous day and the difference between these two values.


select * from rent;
with subquery(pay, rdate) as (select sum(payment_amount), 
rental_date from rent group by str_to_date(rental_date,'%Y-%m-%d'))
select rental_date, pay, lag(pay,1,0) 
over(order by str_to_date(rental_date,'%Y-%m-%d')) as pre_pay, 
pay-lag(pay,1,0) over(order by str_to_date(rental_date,'%Y-%m-%d')) as diff
from rent, subquery where rent.rental_date = subquery.rdate;
