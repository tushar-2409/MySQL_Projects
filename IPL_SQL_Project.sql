-------------------------------------------------- IPL_Project ----------------------------------------------------
USE ipl;

/* 1. Show the percentage of wins of each bidder in the order of highest to lowest 
percentage. */

SELECT bdg.bidder_id, bdr.BIDDER_NAME,
COUNT(CASE WHEN BID_STATUS = 'Won' THEN 1 END) / COUNT(bid_status) * 100 AS win_percentage
FROM ipl_bidding_details bdg 
inner join ipl_bidder_details bdr
on bdg.BIDDER_ID=bdr.BIDDER_ID
group BY bidder_id
order by win_percentage desc;

/* 2. Display the number of matches conducted at each stadium with stadium name, city 
from the database. */

SELECT `is`.stadium_name, `is`.city, count(ims.match_id) as Number_of_matches
FROM ipl_match_schedule as ims
INNER JOIN ipl_stadium as `is`
ON ims.stadium_id=`is`.stadium_id
GROUP BY `is`.stadium_name, `is`.city
ORDER BY Number_of_matches desc;

/* 3. In a given stadium, what is the percentage of wins by a team which has won the 
toss? */

select stad.stadium_id , stad.stadium_name ,
(select count(*) 
from ipl_match mat inner join ipl_match_schedule schd 
on mat.match_id = schd.match_id
where schd.stadium_id = stad.stadium_id and (toss_winner = match_winner)) /
(select count(*) from ipl_match_schedule schd where schd.stadium_id = stad.stadium_id) * 100 
as 'Toss and Match Wins %'
from ipl_stadium stad;

/* 4. Show the total bids along with bid team and team name. */

select bdg.BID_TEAM,tea.TEAM_NAME,count(*) as Total_Bids
from ipl_team tea 
inner join ipl_bidding_details bdg
on tea.TEAM_ID=bdg.BID_TEAM
group by bdg.BID_TEAM,tea.TEAM_NAME;

/* 5. Show the team id who won the match as per the win details. */

SELECT match_id, 
CASE
	WHEN match_winner = 1 THEN  team_id1 
    WHEN match_winner = 2 THEN team_id2
    END as winner_team_id,
win_details
FROM ipl_match;

/* 6. Display total matches played, total matches won and total matches lost by team 
along with its team name. */

SELECT it.team_name, sum(its.matches_played) as matches_played, sum(its.matches_won) as matches_won, sum(its.matches_lost) as matches_lost
FROM ipl_team as it
INNER JOIN ipl_team_standings as its
ON it.team_id = its.team_id
GROUP BY it.team_name;

/* 7. Display the bowlers for Mumbai Indians team. */

SELECT ip.player_name
FROM ipl_team_players as itp
LEFT JOIN ipl_team as it
ON itp.team_id = it.team_id
INNER JOIN ipl_player as ip
ON itp.player_id = ip.player_id
WHERE it.team_name = "Mumbai Indians" AND itp.player_role = "Bowler";

/* 8. How many all-rounders are there in each team, Display the teams with more than 4 
all-rounder in descending order. */

SELECT it.team_name, count(itp.player_role)
FROM ipl_team_players as itp
LEFT JOIN ipl_team as it
ON itp.team_id = it.team_id
INNER JOIN ipl_player as ip
ON itp.player_id = ip.player_id
where itp.player_role = "All-Rounder"
GROUP BY it.team_name
HAVING count(itp.player_role) > 4;









