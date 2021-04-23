#take home day 2

CREATE SCHEMA IF NOT EXISTS Video_Games;
USE Video_Games;
SELECT * FROM Video_Games_Sales;
 
# 1. Display the names of the Games, platform and total sales in North America for respective platforms.

select name , platform, sum(NA_Sales)
over(partition by platform)
from video_games_sales
;

# 2. Display the name of the game, platform , Genre and total sales in North America for 
#corresponding Genre as Genre_Sales,total sales for the given platform as Platformm_Sales and 
#also display the global sales as total sales .
# Also arrange the results in descending order according to the Total Sales.

select name,platform, genre, 
sum(NA_Sales)over( partition by genre order by global_sales desc) genre_sales,
sum(NA_Sales)over( partition by global_sales order by global_sales desc) as total_sale,
sum(NA_Sales)over( partition by platform order by global_sales desc) platform_sales
from video_games_sales;

# 3. Use nonaggregate window functions to produce the row number for each row 
# within its partition (Platform) ordered by release year.

select row_number() over(partition by platform order by year_of_release) row_num, name,
 platform, year_of_release
from video_games_sales;

# 4. Use aggregate window functions to produce the average global sales of 
#each row within its partition (Year of release). 
#Also arrange the result in the descending order by year of release.
   
select name,  avg(global_sales) over 
(partition by year_of_release order by year_of_release desc ) 
from video_games_sales
;
 
# 5. Display the name of the top 5 Games with highest Critic Score For Each Publisher. 

select name, publisher,critic_score, ranking from (
select name, publisher,critic_score,
dense_rank() over ( partition by publisher  order by critic_score desc ) ranking
from video_games_sales) as first_table
where ranking between 1 and 5;
;

------------------------------------------------------------------------------------
# Dataset Used: website_stats.csv and web.csv
------------------------------------------------------------------------------------
# 6. Write a query that displays the opening date two rows forward i.e.
 #the 1st row should display the 3rd website launch date

select * , lead(launch_date,2) over(order by launch_date) from web;

# 7. Write a query that displays the statistics for website_id = 1 i.e. 
#for each row, show the day, the income and the income on the first day.

select * 

from website_stats;

-----------------------------------------------------------------
# Dataset Used: play_store.csv 
-----------------------------------------------------------------
# 8. For each game, show its name, genre and date of release. 
#In the next three columns, show RANK(), DENSE_RANK() and ROW_NUMBER() 
#sorted by the date of release.

select name , genre, released date_of_release ,
rank() over(order by released) as ranking,
dense_rank () over( order by released) as denserank,
row_number() over(order by released) rownum
from play_store;