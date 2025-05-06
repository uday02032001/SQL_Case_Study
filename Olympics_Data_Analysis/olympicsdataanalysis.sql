select * from olympics_history;

select * from olympics_history_noc_regions;

-- How many Olympics games have been held?

select count(distinct games) from olympics_history;
-- Extract all Olympics games held so far.
select distinct games from olympics_history;

-- 3 Total no of nations who participated in each Olympics game?

select  games,count(distinct noc) from olympics_history
group by games;


-- 4 Which year saw the highest and lowest no of countries participating in Olympics?
with high as (
select year,count(distinct noc) countofcountries from olympics_history
group by year
order by countofcountries desc
limit 1),
low as (
select year, count(distinct noc) countofcountries from olympics_history
group by year
order by countofcountries asc
limit 4)
select low.year as lowest_year,low.countofcountries, high.year as highest_year, high.countofcountries 
from high
join low
on high.year !=low.year;

-- or 
select * from olympics_history;
with cte1 as (
select year, count(distinct noc) as total_participation_counts
from olympics_history
group by year),
cte2 as(
select case 
when total_participation_counts=(select max(total_participation_counts) from cte1) then year end as highest_participation_noc,
case when total_participation_counts=(select min(total_participation_counts) from cte1) then year end as lowest_participation_noc 
from cte1)
select group_concat(highest_participation_noc separator ',') as high_participation_years,
group_concat(lowest_participation_noc separator ',') as lower_participation_years
from cte2;

with all_countries as
              (select games, nr.region
              from olympics_history oh
              join olympics_history_noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries;
      
      
select first_value(games) over(order by noc asc) as lowest_countries,
first_value(games) over(order by noc desc) as HIGHEST
from olympics_history
limit 1;
-- Which nation has participated in all of the Olympic games?

-- here first i found total distinct years are 41 then i need to match them with noc count( participation)
-- by noc 
select noc, count(distinct games) counts from olympics_history
group by noc
having counts = (select count(distinct games) from olympics_history) ;

-- or

WITH TotalGames AS (
    SELECT COUNT(DISTINCT games) AS total_games_count
    FROM olympics_history
),
NationGames AS (
    SELECT noc, COUNT(DISTINCT games) AS games_participated
    FROM olympics_history
    GROUP BY noc
)
SELECT 
    ng.noc,
    ng.games_participated,
    tg.total_games_count
FROM NationGames ng
CROSS JOIN TotalGames tg
WHERE ng.games_participated = tg.total_games_count;

-- Find the Ratio of male and female athletes participated in all Olympic games

select distinct concat(round((select count(sex) from olympics_history where sex = "F")/
(select count(sex) from olympics_history where sex = "M"),1),":",round((select count(sex) from olympics_history where sex = "M")/
(select count(sex) from olympics_history where sex = "F"),1)) as ratio
from olympics_history; 
-- or
-- percentage of participation
SELECT 
    CAST(COUNT(CASE WHEN sex = 'M' THEN 1 END) AS FLOAT) /
    CAST(COUNT(CASE WHEN sex = 'F' THEN 1 END) AS FLOAT) AS ratio
FROM olympics_history;
-- ratio per game
SELECT 
    games,
    CAST(COUNT(CASE WHEN sex = 'M' THEN 1 END) AS FLOAT) /
    CAST(COUNT(CASE WHEN sex = 'F' THEN 1 END) AS FLOAT) AS ratio
FROM olympics_history
GROUP BY games
ORDER BY games;
-- we need to count female as well as male and then we need to devide them how we gonna do it;

-- Fetch the top 5 athletes who have won the most gold medals
select * from olympics_history;

select id,name,count(medal) count_medals from olympics_history
where lower(medal) = "gold"
group by id, name
order by count_medals desc
limit 10;
-- or
select * from(select name,count(*), dense_rank() over(order by count(*) desc) as highest
from olympics_history
where lower(medal) = 'gold'
group by name) as topathlets
where highest < 6;
 
-- Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

select id,name, count(medal) as count_medals from olympics_history
where medal != "NA"
group by id,name
order by count_medals desc
limit 5;
--
select name,count_medals,ranks
from(select name,count_medals,dense_rank()over(order by count_medals desc) as ranks
from(select id,name, count(medal) as count_medals from olympics_history
where medal != "NA"
group by id,name) temp) temp2
where ranks <=5;


-- Identify the sport which was played in all summer Olympics.

select * from olympics_history;
select sport, count(distinct games)
from olympics_history
where season = 'winter' 
group by sport;

select count(distinct games)
from olympics_history
where season =  'winter';
select * from olympics_history;

select distinct games, sport,count(distinct sport)
from olympics_history
where sport = 'Athletics'
group  by games,sport;

select count(distinct games) from olympics_history
where games like "%summer%";
select sport, count(distinct games) count_olympics from olympics_history
where games like "%summer%"
group by sport;

-- final query
select sport, count(distinct games) as count_games from olympics_history
where season like "summer"
group by sport
having count_games = (select count(distinct games) from olympics_history
where season like "summer");

-- or 

with t1 as (
select sport, count(distinct games) countswithsportswise
from olympics_history 
where season = "Summer"
group by sport),
t2 as (
select count(distinct games) countofgames
from olympics_history 
where season = "summer")
select sport
from t1
join t2
on t1.countswithsportswise = t2.countofgames;

-- Which Sports were just played only once in the Olympics
select sport,count(*) from olympics_history
group by sport
having count(*) =1;

select sport, count(sport) from olympics_history
where sport = 'Rugby Sevens'
group by sport;
-- Fetch the total no of sports played in each Olympics game

select games, count(distinct sport) as count_sports
from olympics_history
group by games;

-- Fetch details of the oldest athletes to win a gold medal.

select * from olympics_history;
select distinct name,age,year 
from olympics_history
where lower(medal) = "gold"
group by name,age,year
order by age desc;

-- Fetch the top 5 most successful countries in Olympics. Success is defined by no of medals won.

select * from olympics_history;
select * from olympics_history_noc_regions;
-- i need to join both the tables to see the nations
select * from olympics_history
where noc in ('EUN','RUS','URS');

select n.region, count(o.medal) count_medals
from olympics_history o 
left join olympics_history_noc_regions n  -- EUN	Russia  -- rus russial urs -- russia
on o.noc = n.noc
where lower(o.medal) !='na'
group by n.region
order by count_medals desc
limit 5;
-- 
select noc, count(*) from olympics_history
where lower(medal) != 'NA'
group by noc
order by count(*) desc;
/* select region, count(medal) from (select o.medal, n.region
from olympics_history o 
left join olympics_history_noc_regions n 
on o.noc = n.noc) as main
group by region; */
select * from olympics_history_noc_regions
where region = 'Russia';
-- 14.List down total gold, silver and bronze medals won by each country.
select * from olympics_history
wh;

select r.region,
count(case when o.medal = 'Gold' then  1 end )as Total_gold,
count(case when o.medal = 'Silver' then  1 end )as Total_Silver,
count(case when o.medal = 'bronze' then  1 end )as Total_bronze
from olympics_history o
join olympics_history_noc_regions r on r.noc=o.noc
group  by r.region;
--
select r.region,
sum(case when o.medal = 'Gold' then  1 else 0 end )as Total_gold,
sum(case when o.medal = 'Silver' then  1 else 0 end )as Total_Silver,
sum(case when o.medal = 'bronze' then  1 else 0 end )as Total_bronze
from olympics_history o
join olympics_history_noc_regions r on r.noc=o.noc
group  by r.region;
--
with gold as (
select region, count(medal) count_gold
from olympics_history o 
left join olympics_history_noc_regions n 
on o.noc = n.noc
where lower(medal) = "gold"
group by region),
silver as (
select region, count(medal) count_silver
from olympics_history o 
left join olympics_history_noc_regions n 
on o.noc = n.noc
where lower(medal) = "silver"
group by region),
bronze as(
select region, count(medal) count_bronze
from olympics_history o 
left join olympics_history_noc_regions n 
on o.noc = n.noc
where lower(medal) = "bronze"
group by region)
select regions.region, 
coalesce(count_gold,0) count_gold,
coalesce(count_silver,0) count_silver, 
coalesce(count_bronze,0) count_bronze
from (
select region from gold
union 
select region from silver
union 
select region from bronze) regions
LEFT JOIN gold g ON regions.region = g.region
LEFT JOIN silver s ON regions.region = s.region
LEFT JOIN bronze b ON regions.region = b.region
ORDER BY count_gold DESC;

select * from olympics_history_noc_regions;
-- 15. List down total gold, silver and bronze medals won by each country corresponding to each Olympic game.
SELECT r.region,o.games,
sum(CASE WHEN o.medal="Gold" THEN 1 else 0 END) AS GOLD,
sum(CASE WHEN o.medal="Silver" THEN 1 else 0 END) AS SILVER,
sum(CASE WHEN o.medal="Bronze" THEN 1 else 0 END) AS BRONZE
FROM olympics_history o 
join olympics_history_noc_regions r on r.noc=o.noc
GROUP BY r.region, o.games
ORDER BY r.region,games;

select * from olympics_history;
-- 

with g as (select  noc,games, count(medal) goldcounts from olympics_history
where lower(medal) = 'gold'
group by noc,games),

s as(select  noc,games, count(medal) silvercounts from olympics_history
where lower(medal) = 'silver'
group by noc,games),

b as(select  noc,games, count(medal) bronzecounts from olympics_history
where lower(medal) = 'bronze'
group by noc,games) 

select distinct merging.noc, merging.games, 
coalesce(goldcounts,0) gold_medals,
coalesce(silvercounts,0) silver_medals,
coalesce(bronzecounts,0) bronze_medals
from (
select distinct noc,games from olympics_history) as merging
left join g on merging.noc = g.noc and merging.games = g.games
left join s on merging.noc = s.noc and merging.games = s.games
left join b on merging.noc = b.noc and merging.games = b.games
order by noc asc;

-- 16.	Identify which country won the most gold, most silver and most bronze medals in each Olympic game.
-- gpt asnwer 
WITH MedalCounts AS (
    SELECT games, noc, 
           SUM(CASE WHEN LOWER(medal) = 'gold' THEN 1 ELSE 0 END) AS gold_medals,
           SUM(CASE WHEN LOWER(medal) = 'silver' THEN 1 ELSE 0 END) AS silver_medals,
           SUM(CASE WHEN LOWER(medal) = 'bronze' THEN 1 ELSE 0 END) AS bronze_medals
    FROM olympics_history
    WHERE medal IS NOT NULL
    GROUP BY games, noc
),
RankedMedals AS (
    SELECT games, noc, gold_medals, silver_medals, bronze_medals,
           dense_rank() OVER (PARTITION BY games ORDER BY gold_medals DESC) AS gold_rank,
           dense_rank() OVER (PARTITION BY games ORDER BY silver_medals DESC) AS silver_rank,
           dense_rank() OVER (PARTITION BY games ORDER BY bronze_medals DESC) AS bronze_rank
    FROM MedalCounts
)
SELECT games, 
       MAX(CASE WHEN gold_rank = 1 THEN noc END) AS top_gold_country,
       MAX(CASE WHEN silver_rank = 1 THEN noc END) AS top_silver_country,
       MAX(CASE WHEN bronze_rank = 1 THEN noc END) AS top_bronze_country
FROM RankedMedals
GROUP BY games
ORDER BY games;

--
(SELECT year, 'Gold' AS medal_type, team, COUNT(medal) AS no_of_gold_medals
FROM olympics_history
WHERE medal = 'Gold'
GROUP BY year, team
ORDER BY year, no_of_gold_medals DESC
LIMIT 1
)
UNION

(SELECT year, 'Silver' AS medal_type, team, COUNT(medal) AS no_of_silver_medals
FROM olympics_history
WHERE medal = 'Silver'
GROUP BY year, team
ORDER BY year, no_of_silver_medals DESC
LIMIT 1
)
UNION
(
SELECT year, 'Bronze' AS medal_type, team, COUNT(medal) AS no_of_bronze_medals
FROM olympics_history
WHERE medal = 'Bronze'
GROUP BY year, team
ORDER BY year, no_of_bronze_medals DESC
LIMIT 1);


-- 17.	Identify which country won the most gold, most silver, most bronze medals and the most medals in each Olympic game.
WITH MedalCounts AS (
    SELECT games, noc, 
           SUM(CASE WHEN LOWER(medal) = 'gold' THEN 1 ELSE 0 END) AS gold_medals,
           SUM(CASE WHEN LOWER(medal) = 'silver' THEN 1 ELSE 0 END) AS silver_medals,
           SUM(CASE WHEN LOWER(medal) = 'bronze' THEN 1 ELSE 0 END) AS bronze_medals,
          sum(case when lower(medal) in ('gold','silver','bronze') then 1 else 0 end) as sum_medals 
    FROM olympics_history
    WHERE medal IS NOT NULL
    GROUP BY games, noc
),
RankedMedals AS (
    SELECT games, noc, gold_medals, silver_medals, bronze_medals,sum_medals,
           dense_rank() OVER (PARTITION BY games ORDER BY gold_medals DESC) AS gold_rank,
           dense_rank() OVER (PARTITION BY games ORDER BY silver_medals DESC) AS silver_rank,
           dense_rank() OVER (PARTITION BY games ORDER BY bronze_medals DESC) AS bronze_rank,
          dense_rank() over(partition by games order by sum_medals desc) as total_rank
           
    FROM MedalCounts
)
SELECT games, 
       MAX(CASE WHEN gold_rank = 1 THEN concat(noc,"-",gold_medals) END) AS top_gold_country,
       MAX(CASE WHEN silver_rank = 1 THEN concat(noc,"-",silver_medals) END) AS top_silver_country,
       MAX(CASE WHEN bronze_rank = 1 THEN concat(noc,"-",bronze_medals) END) AS top_bronze_country,
      max(Case when total_rank =1 then concat(noc,"-",sum_medals) end) as top_total_medals 
FROM RankedMedals
GROUP BY games
ORDER BY games;
-- 18.	Which countries have never won gold medal but have won silver/bronze medals?
WITH gold AS (
  SELECT noc
  FROM olympics_history o
  WHERE LOWER(medal) = 'gold'
  GROUP BY noc
),
silver_bronze AS (
  SELECT noc
  FROM olympics_history o
  WHERE LOWER(medal) IN ('silver', 'bronze')
  GROUP BY noc
)
SELECT sb.noc
FROM silver_bronze sb
LEFT JOIN gold g
  ON sb.noc = g.noc
WHERE g.noc IS NULL
ORDER BY sb.noc;

-- 19.	In which Sport/event, India has won highest medals.

select sport, count(medal) countmedals from olympics_history
where noc = 'IND'
group by sport
order by countmedals desc;

-- 20.	Break down all Olympic games where India won medal for Hockey and how many medals in each Olympic games.
select sport,games, count(medal) countmedals from olympics_history
where noc = 'IND' and sport = 'Hockey'
group by sport,games
order by countmedals desc;



-- never won gold but silver/bronze
SELECT distinct region
FROM olympics_history o
LEFT JOIN olympics_history_noc_regions n
  ON o.noc = n.noc
WHERE LOWER(o.medal) IN ('silver', 'bronze')
AND o.noc NOT IN (
  SELECT o2.noc
  FROM olympics_history o2
  WHERE LOWER(o2.medal) = 'gold'
)
ORDER BY region;

-- never won gold but silver/bronze

select distinct noc 
from olympics_history o1
where lower(medal) in ('silver','bronze') and not exists
(select 1 from olympics_history o2
where lower(medal) = 'gold'
and o1.noc = o2.noc);





select * from olympics_history;

select name,games,count(medal)
from olympics_history
where medal != 'NA'
group by name,games;


select medal,sport
from olympics_history
where name ='Janica Kosteli' and games='2002 Winter';


--
with all_data as (select oh.*,nd.region from olympics_history oh join olympics_history_noc_regions nd on oh.noc=nd.noc),
	 most_medals as 
(
select games,
concat(first_value(region) over(partition by games order by sum(case when medal='Gold' then 1 else 0 end) desc),'-',
	first_value(sum(case when medal='Gold' then 1 else 0 end)) over(partition by games order by sum(case when medal='Gold' then 1 else 0 end) desc)) Gold,
concat(first_value(region) over(partition by games order by sum(case when medal='Silver' then 1 else 0 end) desc),'-',
	first_value(sum(case when medal='Silver' then 1 else 0 end)) over(partition by games order by sum(case when medal='Silver' then 1 else 0 end) desc)
) Silver,concat(first_value(region) over(partition by games order by sum(case when medal='Bronze' then 1 else 0 end) desc),'-',
	first_value(sum(case when medal='Bronze' then 1 else 0 end)) over(partition by games order by sum(case when medal='Bronze' then 1 else 0 end) desc) ) Bronze,
concat(first_value(region) over(partition by games order by sum(case when medal='Gold' then 1 else 0 end) desc),'-',
	first_value(sum(case when medal='NA' then 0 else 1 end)) over(partition by games order by sum(case when medal='NA' then 0 else 1 end) desc)) total_medals,
	row_number() over(partition by games) rn from all_data GROUP BY games,region
)
select * from most_medals where rn=1;

