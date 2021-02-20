use ipl;

#1Show the percentage of wins of each bidder in the order of highest to lowest percentage.
with wins as (
select BIDDER_ID, 
sum(case when BID_STATUS like '%won%' then 1 else null end) as won_status
from `ipl_bidding_details` group by BIDDER_ID)
select a.BIDDER_ID, 
(wins.won_status/count(a.BID_STATUS))*100 as win_percentage 
from ipl_bidding_details a 
join wins on a.BIDDER_ID = wins.BIDDER_ID 
group by a.BIDDER_ID 
order by win_percentage desc;

#2 Display the number of matches conducted at each stadium with stadium name, city from the database.

select ms.STADIUM_ID, i.STADIUM_NAME, i.city, 
count(ms.STATUS) as no_of_matches from ipl_stadium i 
join ipl_match_schedule ms on i.stadium_id = ms.stadium_id 
where ms.STATUS like '%Completed%' group by 
i.STADIUM_NAME, i.city;

#3 In a given stadium, what is the percentage of wins by a team which has won the toss?

with wins as(
select MATCH_ID from ipl_match 
where TOSS_WINNER = MATCH_WINNER),
total as (
select STADIUM_ID, 
count(MATCH_ID)count1 
from ipl_match_schedule group by STADIUM_ID)
select ms.STADIUM_ID, 
(count(ms.MATCH_ID)/total.count1)*100 as win_percent 
from ipl_match_schedule ms 
join wins on ms.MATCH_ID = wins.MATCH_ID
join total on ms.STADIUM_ID= total.STADIUM_ID 
group by ms.STADIUM_ID;

#4 Show the total bids along with bid team and team name.

select b.BID_TEAM, c.TEAM_NAME, 
count(a.NO_OF_BIDS) total_bids 
from ipl_bidder_points a join 
ipl_bidding_details b 
on a.BIDDER_ID = b.BIDDER_ID 
join ipl_team c on b.BID_TEAM = c.TEAM_ID
group by BID_TEAM;

#5 Show the team id who won the match as per the win details.

select it.TEAM_ID,it.TEAM_NAME, im.WIN_DETAILS
from ipl_team it
join ipl_match im
on substring(im.WIN_DETAILS, 6, 2) = substring(it.REMARKS, 1, 2);


#6.	Display total matches played, total matches won and total matches lost by team along with its team name.

with won1 as (
select case when MATCH_WINNER = 1 then TEAM_ID1 else TEAM_ID2 end as teams, 
count(*) matches_won from ipl_match group by teams),
ma1 as (
select TEAM_ID1, count(TEAM_ID1) as onee from ipl_match group by TEAM_ID1),
ma2 as (
select TEAM_ID2, count(TEAM_ID2) as two from ipl_match group by TEAM_ID2)
select won1.teams, c.TEAM_NAME, ma1.onee + ma2.two as total_matches, won1.matches_won, 
(ma1.onee + ma2.two) - won1.matches_won as lost
from ma1 join ma2 on ma1.TEAM_ID1 = ma2.TEAM_ID2 join won1 on ma2.TEAM_ID2  = won1.teams 
join ipl_team c on won1.teams = c.TEAM_ID;



#7.	Display the bowlers for Mumbai Indians team.
select tp.PLAYER_ID, ip.PLAYER_NAME from ipl_team_players tp join ipl_player ip on tp.PLAYER_ID = ip.PLAYER_ID
where tp.PLAYER_ROLE like '%Bowler%' and substring(tp.REMARKS,8,2) = 'MI';


#8.	How many all-rounders are there in each team, Display the teams with more than 4  all-rounder in descending order
select tp.TEAM_ID, it.TEAM_NAME, count(PLAYER_ID) all_rounders 
from ipl_team_players tp join ipl_team it on tp.TEAM_ID = it.TEAM_ID
where PLAYER_ROLE like '%round%' group by TEAM_ID having all_rounders> 4 order by all_rounders desc ;