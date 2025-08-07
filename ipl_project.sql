create database ipl;
use ipl;
create table matches (id char(10),
                      season varchar(30),
                      city varchar(30),
                      date_ varchar(20),
                      match_type varchar(30),
                      player_of_the_match varchar(30),
                      venue varchar(80),
                      team1 varchar(50),
                      team2 varchar(50),
                      toss_winner varchar(50) ,
                      toss_decision char(10)  ,
                      winner varchar(50),
                      result char(20),
                      result_margin char(10) ,
                      target_runs char(10),
                      target_overs char(10),
                      super_over char(10) ,
                      method char(10),
                      umpire1 char(30),
                      umpire2 char(30));
select count(*) from matches;
select * from matches;


alter table matches modify column id char(10) primary key;
describe matches;
SHOW COLUMNS FROM matches LIKE 'date_';

SET SQL_SAFE_UPDATES = 0;
UPDATE matches
SET date_ = DATE_FORMAT(STR_TO_DATE(date_, '%d-%m-%Y'), '%Y-%m-%d')
WHERE date_ LIKE '__-__-____';

ALTER TABLE matches
MODIFY COLUMN date_ DATE;

select distinct toss_decision from matches;
select distinct result_margin from matches;
select distinct target_runs from matches;
select distinct target_overs from matches;
select distinct super_over from matches;
select distinct method from matches;

ALTER TABLE matches
MODIFY COLUMN toss_decision char(5) check(toss_decision in ("field","bat")) ;

ALTER TABLE matches
MODIFY COLUMN super_over char(5) check(super_over in ("N","Y")) ;


UPDATE matches
SET result_margin = 0
WHERE result_margin = "NA";

ALTER TABLE matches
MODIFY COLUMN result_margin int;

UPDATE matches
SET target_runs = 0
WHERE target_runs = "NA";

ALTER TABLE matches
MODIFY COLUMN target_runs int;

UPDATE matches
SET target_overs = 0
WHERE target_overs = "NA";

ALTER TABLE matches
MODIFY COLUMN target_overs int;
select * from matches;

-- How many matches were played in total for each season where the toss winner chose to bat and won the match?
SELECT season, count(*)  
FROM matches WHERE
toss_decision = "bat" AND toss_winner = winner 
GROUP BY season 
ORDER BY season;

-- What is the maximum winning margin (by runs) achieved by each winning team in seasons from 2015 to 2018, inclusive?
SELECT winner,result,season, max(result_margin) as max_margin_by_runs 
FROM matches 
where result = "runs" and season between "2015" and "2018" 
group by winner,season 
order by season asc;

--  What is the minimum winning margin (by wickets) for matches played in cities whose names start with 'M', grouped by the winning team?
SELECT winner,min(result_margin) AS min_margin_by_wickets 
From matches 
WHERE result = 'wickets' and city like 'M%' 
group by winner
order by min_margin_by_wickets;




-- Count the number of matches played in either 'Chennai' or 'Mumbai' across seasons 2019 and 2020/21, grouped by city.
SELECT city,count(*) AS matches_played
FROM matches 
WHERE city IN ("Chennai","Mumbai")  AND season IN ("2019","2020/21")
GROUP BY city
ORDER BY matches_played DESC;

-- What is the maximum winning margin (by runs) for matches where the winning team's name starts with 'Royal Challengers' or 'Deccan', grouped by the winning team?
SELECT winner,max(result_margin) AS max_win_by_runs
FROM matches 
WHERE result = 'runs' AND (winner like 'Royal Challengers%' or winner like 'Deccan%' )
GROUP BY winner
order by max_win_by_runs;

-- Calculate the total sum of the target_runs (first innings score) for matches won by batting first (result = 'runs') in seasons between 2010 and 2015, grouped by the winning team.
SELECT winner,sum(target_runs) as total_first_innings_score 
FROM matches WHERE result = 'runs' and season between '2010' and '2015' and winner IS NOT NULL
GROUP BY winner 
ORDER BY total_first_innings_score desc;


-- What is the minimum winning margin (runs) for matches played in seasons from 2018 to 2021, inclusive, grouped by venue?
SELECT venue,min(result_margin) AS  min_win_margin_runs 
FROM matches 
WHERE result = 'runs' and season between '2018' and '2021' 
GROUP BY venue 
ORDER BY min_win_margin_runs DESC;

-- Count the number of distinct players of the match for matches that had a 'D/L' method used, grouped by season.
SELECT season,count( DISTINCT player_of_the_match) AS distinct_player 
FROM matches 
WHERE method = 'D/L' 
GROUP BY season 
ORDER BY season;

-- What is the maximum winning margin (by wickets) for matches played in venues containing the word 'Stadium' or 'Academy', grouped by the winning team?
SELECT winner,venue,max(result_margin) AS max_win_margin_wickets 
FROM matches 
WHERE result = 'wickets' and ( venue like '%Stadium%' or venue like '%Academy%' )
GROUP BY winner,venue 
ORDER BY max_win_margin_wickets;
 
-- Count the number of matches that ended in a 'tie' or 'no result' where either 'Kings XI Punjab' or 'Delhi Daredevils' (or 'Delhi Capitals') was one of the playing teams (team1 or team2), grouped by the result type. 
SELECT result,count(*) AS count_of_matches 
FROM matches 
WHERE result in ("tie",'no result') AND ( team1 in ("Kings XI Punjab",'Delhi Daredevils','Delhi Capitals') or team2 in ("Kings XI Punjab",'Delhi Daredevils','Delhi Capitals'))
GROUP BY result
ORDER BY count_of_matches desc;

--  Find all matches where the winning result_margin (by runs) was greater than the average result_margin for all matches won by runs.
SELECT *
FROM matches
WHERE result = 'runs'
  AND result_margin > (
    SELECT AVG(result_margin)
    FROM matches
    WHERE result = 'runs');
    
--  List the teams that won a match with a result_margin (by runs) greater than the maximum result_margin (by runs) achieved by 'Chennai Super Kings' in any of their wins.
SELECT DISTINCT winner 
FROM matches 
WHERE result = 'runs' 
AND result_margin > (
     SELECT max(result_margin) 
     FROM matches 
     WHERE result = 'runs' and winner = 'Chennai Super Kings');
     
--  Count the number of matches played in cities that have hosted at least one 'Final' match, grouped by city.
SELECT city, COUNT(*) AS match_count
FROM matches
WHERE city IN (
    SELECT DISTINCT city
    FROM matches
    WHERE match_type = 'Final'
      AND city IS NOT NULL
)
GROUP BY city
ORDER BY match_count DESC;

--  Find the total number of matches won by teams that have a player_of_match whose name starts with 'J'.
SELECT count(winner) as total_matches_won_teams 
FROM matches 
WHERE player_of_the_match like 'J%' AND winner IS NOT NULL ;

--  Count the number of matches where the toss winner was not in the list of teams that have won any match by a result_margin (wickets) less than 2.
select * from matches;
SELECT count(*) AS count_matches_won_toss
FROM matches 
WHERE toss_winner not in (
           select distinct winner 
           from matches 
           where result = 'wickets' and result_margin < 2)
;

create table deliviers (match_id char(10) ,
                        inning char(10) ,
                        batting_team varchar(30),
                        bowling_team varchar(30),
                        over_ char(10),
                        ball char(10),
                        batter varchar(50),
                        bowler varchar(30),
                        non_striker varchar(30),
                        batsman_runs char(10),
                        extra_runs char(10),
                        total_runs char(10),
                        extras_type varchar(20),
                        is_wicket char(10),
                        player_dismissed char(10),
                        dismissal_kind char(10),
                        fielder char(10));
select * from matches;
select * from deliviers;
CREATE INDEX idx_match_id ON matches(id);

ALTER TABLE deliviers
ADD FOREIGN KEY (match_id)
REFERENCES matches (id);

--  For every match where "Royal Challengers Bangalore" was the winner, list the match_id, the date of the match, and the total batsman_runs scored by the batting_team in the first inning of that match.
select * from deliviers;
select d.match_id,m.date_,sum(d.batsman_runs) as total_first_innings_runs
from deliviers AS d JOIN matches AS m ON m.id = d.match_id 
where m.winner = "Royal Challengers Bangalore"  and  d.inning = 1 
group by d.match_id,m.date_ 
order by m.date_;

-- List the match_id, batter, and bowler for deliveries where the batting_team was 'Chennai Super Kings', the bowling_team was 'Mumbai Indians', and the batsman_runs scored on that delivery were '6'.
select match_id , batter, bowler 
from deliviers 
where batting_team = 'Chennai Super Kings' and bowling_team = 'Mumbai Indians' and batsman_runs = 6;

-- List all matches (id, date, venue) from the matches table. For each match, also show the name of the player_dismissed if the dismissal_kind was 'bowled' in that match. 
-- If multiple 'bowled' dismissals occurred, list them. If no 'bowled' dismissal occurred, the dismissal details should be absent (NULL).
select m.id,m.date_,m.venue,d.player_dismissed 
from matches as m 
left join deliviers as d on m.id = d.match_id 
where d.dismissal_kind = 'bowled' 
order by m.id;

--  List unique player names. For match_id = '335982', show the player's name if they were the batter on any delivery, 
-- and separately show their name if they were the player_of_match. A player could be both, one, or neither in these roles for this specific match.
select  distinct d.batter from deliviers as d join matches as m on d.match_id = m.id where d.match_id = '335982' and m.player_of_the_match;

SELECT 
    player_name,
    MAX(CASE WHEN role = 'batter' THEN 1 ELSE 0 END) AS is_batter,
    MAX(CASE WHEN role = 'player_of_match' THEN 1 ELSE 0 END) AS is_player_of_match
FROM (
    SELECT DISTINCT batter AS player_name, 'batter' AS role
    FROM deliviers
    WHERE match_id = 335982

    UNION

    SELECT player_of_the_match AS player_name, 'player_of_match' AS role
    FROM matches
    WHERE id = 335982
) AS combined_roles
GROUP BY player_name
ORDER BY player_name;

--  List all unique city names where a match was played in the '2019' season OR where 'MS Dhoni' was the player_of_match.
SELECT  DISTINCT city,season 
FROM matches 
WHERE season = '2019' or player_of_the_match = 'MS Dhoni'
order by season;

-- List all match_ids where 'Kolkata Knight Riders' was team1, and then list all match_ids where 'Kolkata Knight Riders' was team2.
-- Include duplicates if a hypothetical match had them as both (though not possible in this dataset).
SELECT id,team1,team2 FROM matches WHERE team1 = 'Kolkata Knight Riders' 
union all
SELECT id,team1,team2 FROM matches WHERE team2 = 'Kolkata Knight Riders';
-- method-2
SELECT id, 'team1' AS team_position
FROM matches
WHERE team1 = 'Kolkata Knight Riders'
UNION ALL
SELECT id, 'team2' AS team_position
FROM matches
WHERE team2 = 'Kolkata Knight Riders'
ORDER BY id;

--  For each batting_team in matches played in the '2020/21' season, calculate the total extra_runs they benefited from (conceded by the opposition).
SELECT 
    d.batting_team,
    SUM(d.extra_runs) AS total_extra_runs
FROM matches m
JOIN deliviers d ON m.id = d.match_id
WHERE m.season = '2020/21'
GROUP BY d.batting_team
ORDER BY total_extra_runs DESC;

-- List the match_id, date, and venue for all matches where the toss_winner was one of the teams that also won a match in 'Sharjah'.
SELECT id AS match_id, date_, venue
FROM matches
WHERE toss_winner IN (
    SELECT DISTINCT winner
    FROM matches
    WHERE venue = 'Sharjah' AND winner IS NOT NULL
);

-- Find the bowling_team and the total total_runs conceded by them in matches where the venue was 'Eden Gardens'. 
-- Only show teams that conceded more than 1000 runs in total at this venue.
SELECT d.bowling_team,sum(d.total_runs) as total_runs_conceded 
From deliviers as d 
join matches as m on d.match_id = m.id 
WHERE venue = 'Eden Gardens' 
GROUP BY bowling_team 
HAVING total_runs_conceded > 1000 
order by total_runs_conceded  desc;

-- .Create a combined list showing:
-- (1) match_id and batter for all 'caught' dismissals.
-- (2) match_id and player_dismissed (aliased as batter) for all 'bowled' dismissals.
SELECT match_id ,batter 
FROM deliviers 
WHERE dismissal_kind = 'caught'

union all 

SELECT match_id,player_dismissed as batter 
FROM deliviers 
WHERE dismissal_kind = 'bowled' 
ORDER BY match_id;
    

     



