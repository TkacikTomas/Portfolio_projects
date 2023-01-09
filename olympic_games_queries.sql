--How many olympics games have been held?
SELECT COUNT(DISTINCT games) AS total_olympic_games
FROM athlete_events

--List down all Olympics games held so far
SELECT Distinct year, season, city
FROM athlete_events
ORDER BY 1,2,3

--Mention the total number of nations who participated in each olympics game
SELECT 
	games,
	COUNT(distinct r.region)
FROM athlete_events e
JOIN noc_regions r
	ON e.noc=r.noc
GROUP BY games

-- yearof the highest and lowest number of countries participating in olympics

WITH cte AS(
	SELECT 
		games,
		COUNT(distinct r.region) as no_nations
	FROM athlete_events e
	JOIN noc_regions r
		ON e.noc=r.noc
	GROUP BY games)
	
SELECT 
	CONCAT(games, '-', no_nations) AS lowest_countries,
	(SELECT CONCAT(games, '-', no_nations)
	FROM cte
	WHERE no_nations=
				(SELECT MAX(no_nations)
				 FROM cte)
    ) AS highest_countries
FROM cte
WHERE no_nations=
				(SELECT MIN(no_nations)
				 FROM cte)

--Which nation has participated in all of the olympic games
WITH games_nation AS(
	SELECT 
		DISTINCT(CONCAT(games, '-',region)) as ol_nation
	FROM athlete_events e
	JOIN noc_regions r
		ON e.noc=r.noc
	order by 1),
split AS(
	SELECT *,
		LEFT(ol_nation,POSITION('-' IN ol_nation)-1) as games,
		SPLIT_PART(ol_nation, '-',2) as country
	FROM games_nation)
SELECT 
	country,
	COUNT(country) as no_partiticaped_games
FROM split
GROUP BY country
HAVING COUNT(country)=
		(SELECT  COUNT(DISTINCT games)
		 FROM athlete_events)
ORDER BY 1

--Identify the sport which was played in all summer olympics
SELECT sport, COUNT(row_number) 
FROM(
	SELECT year, sport,
		ROW_NUMBER() OVER (PARTITION BY year,sport ORDER BY year, sport) 
	FROM athlete_events
	WHERE season='Summer'
	ORDER BY year, sport) x
WHERE row_number=1
GROUP BY sport
HAVING COUNT(row_number)=
		(SELECT  COUNT(DISTINCT games)
		 FROM athlete_events
		 WHERE season='Summer')

--Which Sports were just played only once in the olympics
SELECT sport, COUNT(row_number) as no_games
FROM(
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY year,sport ORDER BY year, sport) 
	FROM athlete_events
	ORDER BY year, sport) x
WHERE row_number=1
GROUP BY sport
HAVING COUNT(row_number)=1

--Fetch the total no of sports played in each olympic games

SELECT 
	games,
	COUNT(distinct sport) AS no_sports
FROM athlete_events
GROUP BY games
ORDER BY 2 DESC

-- Fetch oldest athletes to win a gold medal
			
SELECT *
FROM athlete_events
WHERE medal='Gold' 
	AND age<>'NA'
	AND age=
	(SELECT MAX(age)
	 FROM(
		SELECT *
		FROM athlete_events
		WHERE medal='Gold'
			AND age<>'NA') x)

--Find the Ratio of male and female athletes participated in all olympic games

SELECT 
	CONCAT((no_women/no_women),':', ROUND((no_men::decimal/no_women::decimal),2)) AS ratio_w_m
FROM(
	SELECT 
		sex,
		COUNT(sex) as no_women,
		LEAD(COUNT(sex)) OVER() no_men
	FROM athlete_events
	GROUP BY sex) x
WHERE sex='F'

--Fetch the top 5 athletes who have won the most gold medals
with ranking AS(
	SELECT 
		name,
		team,
		COUNT(medal) AS no_gold_medals,
		DENSE_RANK() OVER(ORDER BY COUNT(medal) DESC) as rating
	FROM athlete_events
	WHERE medal='Gold'
	GROUP BY 1, 2
	ORDER BY no_gold_medals DESC)
SELECT name, team, no_gold_medals
FROM ranking
WHERE rating<6

--Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)
with ranking AS(
	SELECT 
		name,
		team,
		COUNT(medal) AS no_medals,
		DENSE_RANK() OVER(ORDER BY COUNT(medal) DESC) as rating
	FROM athlete_events
	WHERE medal IN('Gold', 'Silver', 'Bronze')
	GROUP BY 1, 2
	ORDER BY no_medals DESC)
SELECT name, team, no_medals
FROM ranking
WHERE rating<6

--Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won

SELECT 
	region, 
	COUNT(medal)  AS total_medals,
	DENSE_RANK() OVER(ORDER BY COUNT(medal) DESC) AS rnk
FROM athlete_events as e
JOIN noc_regions as r
	ON e.noc=r.noc
WHERE medal IN('Gold', 'Silver', 'Bronze')
GROUP BY region
ORDER BY total_medals DESC
LIMIT 5;


--List down total gold, silver and bronze medals won by each country

CREATE EXTENSION IF NOT EXISTS	tablefunc;
WITH  medals AS(
SELECT *
FROM CROSSTAB($$
		SELECT 
			r.region,
			medal,
			COUNT(medal)  AS total_medals
		FROM athlete_events as e
		JOIN noc_regions as r
			ON e.noc=r.noc
		WHERE medal IN('Gold', 'Silver', 'Bronze')
		GROUP BY r.region, medal
		ORDER BY r.region, medal
$$) AS mdls (region VARCHAR,
			"Bronze" bigint,
			"Gold" bigint,
			"Silver" bigint)
ORDER BY region DESC)
SELECT region, 
	   COALESCE("Gold",0) AS gold,
	   COALESCE("Silver",0) AS silver,
	   COALESCE("Bronze",0) AS bronze
FROM medals
ORDER BY gold DESC, silver DESC, bronze DESC


--List down total gold, silver and bronze medals won by each country corresponding to each olympic games

CREATE EXTENSION IF NOT EXISTS	tablefunc;
WITH  medals AS(
SELECT *
FROM CROSSTAB($$
		SELECT 
			CONCAT(games,'-',r.region) AS g_c,
			medal,
			COUNT(medal)  AS total_medals
		FROM athlete_events as e
		JOIN noc_regions as r
			ON e.noc=r.noc
		WHERE medal IN('Gold', 'Silver', 'Bronze')
		GROUP BY g_c, medal
		ORDER BY g_c, medal
$$) AS mdls (games TEXT,
			"Bronze" bigint,
			"Gold" bigint,
			"Silver" bigint)
ORDER BY games )
SELECT 
	   SPLIT_PART(games,'-',1) AS games,
	   SPLIT_PART(games,'-',2) AS country,
	   COALESCE("Gold",0) AS gold,
	   COALESCE("Silver",0) AS silver,
	   COALESCE("Bronze",0) AS bronze
FROM medals
ORDER BY games , country

--Identify which country won the most gold, most silver and most bronze medals in each olympic games

CREATE EXTENSION IF NOT EXISTS tablefunc;
WITH cte AS(
	SELECT * FROM CROSSTAB($$
		SELECT games, medal, CONCAT(country,'-', no_medals) AS medals
		FROM(
			SELECT 
				games,
				r.region AS country,
				medal,
				COUNT(medal) AS no_medals,
			RANK() OVER(PARTITION BY games, medal ORDER BY games, medal, COUNT(medal) DESC) AS rnk
			FROM athlete_events as e
			JOIN noc_regions as r
				ON e.noc = r.noc
			WHERE medal<>'NA'
			GROUP BY games, r.region, medal
			ORDER BY games, no_medals DESC) x
		WHERE rnk=1
		ORDER BY games, medal
	$$) AS gms (games VARCHAR,
			   "max_bronze" TEXT,
			   "max_gold" TEXT,
			   "max_silver" TEXT))
SELECT 
	games, "max_gold", "max_silver", "max_bronze"
FROM cte

--Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games
CREATE EXTENSION IF NOT EXISTS tablefunc;
SELECT games, "max_gold", "max_silver", "max_bronze", "max_medals"
FROM(
	SELECT * FROM CROSSTAB($$
		WITH roll AS(
			SELECT 
				games,
				r.region AS country,
				medal,
				COUNT(medal) AS no_medals,
			ROW_NUMBER() OVER(PARTITION BY games ORDER BY COUNT(medal) DESC) AS row_n
			FROM athlete_events as e
			JOIN noc_regions as r
				ON e.noc = r.noc
			WHERE medal<>'NA'
			GROUP BY ROLLUP(games, country, medal)
			ORDER BY games, no_medals DESC),
		top AS(
			SELECT games, country, medal, no_medals,
				DENSE_RANK() OVER (PARTITION BY games, medal ORDER BY games,no_medals DESC) AS rnk
			FROM roll
			WHERE row_n<>1)
		SELECT games, COALESCE(medal, 'max medals') AS medals, CONCAT(country, '-', no_medals)
		FROM top
		WHERE rnk=1
	$$) AS mdls (games VARCHAR,
				"max_bronze" TEXT,
				"max_gold" TEXT,
				"max_silver" TEXT,
				"max_medals" TEXT))x
				
				
-- Which countries have never won gold medal but have won silver/bronze medals

SELECT 
	r.region AS country,
	medal,
COUNT(medal) AS n_medals
FROM athlete_events as e
JOIN noc_regions as r
	ON e.noc=r.noc
WHERE medal<> 'NA' AND r.region NOT IN(
			SELECT country
			FROM(
				SELECT 
					r.region AS country,
					medal,
					COUNT(medal) AS n_medals
				FROM athlete_events as e
				JOIN noc_regions as r
					ON e.noc=r.noc
				WHERE medal<> 'NA' 
				GROUP BY 1,2
				ORDER BY 1,2, 3 DESC) x
			WHERE medal='Gold')
GROUP BY 1,2
ORDER BY 3 DESC




	





























