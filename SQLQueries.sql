SELECT *
FROM dbo.LastPitchYankees;

SELECT *
FROM dbo.YankeesPitchingStats;

--Question 1 AVG Pitches Per at Bat Analysis


--1a AVG Pitches Per At Bat

SELECT AVG(1.00 * Pitch_number) AS AvgNumPitchesPerAtBat
FROM dbo.LastPitchYankees;

--1b AVG Pitches Per At Bat Home Vs Away

SELECT 
	'Home' AS Home_or_Away,
	AVG(1.00 * Pitch_number) AS AvgNumPitchesPerAtBat
FROM dbo.LastPitchYankees
WHERE home_team = 'NYY'
UNION
SELECT 
	'Away' AS Home_or_Away,
	AVG(1.00 * Pitch_number) AS AvgNumPitchesPerAtBat
FROM dbo.LastPitchYankees
WHERE away_team = 'NYY'

--1c AVG Pitches Per At Bat Lefty Vs Righty

SELECT 
	AVG(Case when batter_handedness = 'R' Then 1.00 * Pitch_number end) AS RightyAtBats,
	AVG(Case when batter_handedness = 'L' Then 1.00 * Pitch_number end) AS LeftyAtBats
FROM dbo.LastPitchYankees

--1f AVG Pitches Per at Bat Per Pitcher with 20+ Innings | Order in descending

SELECT 
	YPS.Name,
	AVG(1.00 * Pitch_number) AS AVGPitches
FROM YankeesPitching2022.dbo.YankeesPitchingStats AS YPS
JOIN YankeesPitching2022.dbo.LastPitchYankees AS LPY ON YPS.Pitcher_ID = LPY.pitcher
WHERE IP >= 20
GROUP BY YPS.Name
ORDER BY AVG(1.00 * Pitch_number) DESC;
	

--Question 2 Last Pitch Analysis

--2a Count of the Last Pitches Thrown in Desc Order

SELECT 
	pitch_name,
	COUNT(*) AS TimesThrown
FROM dbo.LastPitchYankees
GROUP BY pitch_name
ORDER BY COUNT(*) DESC;

--2b Count of the different last pitches Fastball or Offspeed

SELECT 
	SUM(CASE WHEN pitch_name in ('4-Seam Fastball', 'Cutter', 'Sinker') then 1 else 0 end) Fastball,
	SUM(CASE WHEN pitch_name NOT in ('4-Seam Fastball', 'Cutter', 'Sinker') then 1 else 0 end) Offspeed
FROM dbo.LastPitchYankees;


--2c Percentage of the different last pitches Fastball or Offspeed

SELECT 
	100 * SUM(CASE WHEN pitch_name in ('4-Seam Fastball', 'Cutter', 'Sinker') then 1 else 0 end) / count(*) FastballPercent,
	100 * SUM(CASE WHEN pitch_name NOT in ('4-Seam Fastball', 'Cutter', 'Sinker') then 1 else 0 end) / count(*) OffspeedPercent
FROM dbo.LastPitchYankees;

--Question 3 Homerun analysis

--3a What pitches have given up the most HRs

SELECT pitch_name, COUNT(*) HRs
FROM YankeesPitching2022.dbo.LastPitchYankees
WHERE events = 'home_run'
GROUP BY pitch_name
ORDER BY COUNT(*) DESC;

--3b Show HRs given up by zone and pitch, show top 5 most common

SELECT TOP 5 zone, pitch_name
FROM YankeesPitching2022.dbo.LastPitchYankees
WHERE events = 'home_run'
GROUP BY zone, pitch_name
ORDER BY COUNT(*) DESC;


--3c Show HRs for each count type -> Balls/Strikes + Type of Pitcher

SELECT YPS.POS, LPY.balls, LPY.strikes, COUNT(*) HRs
FROM YankeesPitching2022.dbo.LastPitchYankees AS LPY
JOIN YankeesPitching2022.dbo.YankeesPitchingStats AS YPS ON YPS.Pitcher_ID = LPY.pitcher
WHERE events = 'home_run'
GROUP BY YPS.POS, LPY.balls, LPY.strikes
ORDER BY COUNT(*) DESC;


--3d Show Each Pitchers Most Common count to give up a HR (Min 30 IP)

WITH hrcountspitchers AS (
SELECT  YPS.name, LPY.balls, LPY.strikes, COUNT(*) HRs
FROM YankeesPitching2022.dbo.LastPitchYankees AS LPY
JOIN YankeesPitching2022.dbo.YankeesPitchingStats AS YPS ON YPS.Pitcher_ID = LPY.pitcher
WHERE events = 'home_run' and IP >= 30
GROUP BY YPS.name, LPY.balls, LPY.strikes
), 
hrcountsranks as(
	SELECT 
		hcp.name, 
		hcp.balls, 
		hcp.strikes, 
		hcp.HRs,
		RANK() OVER (Partition by Name ORDER BY HRS DESC) hr_rank
	FROM hrcountspitchers AS hcp
)
SELECT  
	ht.name, 
	ht.balls, 
	ht.strikes, 
	ht.HRs
FROM hrcountsranks AS ht
WHERE hr_rank = 1;


--Question 4 Gerrit Cole

--4a AVG Release speed, spin rate,  strikeouts, most popular zone 

SELECT 
	AVG(release_speed) AvgReleaseSpeed,
	AVG(release_spin_rate) AvgSpinRate,
	Sum(case when events = 'strikeout' THEN 1 ELSE 0 END) AS strikeouts,
	MAX(zones.zone) AS Zone
FROM YankeesPitching2022.dbo.LastPitchYankees AS LPY
join (

	SELECT TOP 1 pitcher, zone, COUNT(*) AS zonenum
	FROM YankeesPitching2022.dbo.LastPitchYankees AS LPY
	where player_name = 'Cole, Gerrit'
	group by pitcher, zone
	order by count(*) desc

) zones ON zones.pitcher = LPY.pitcher
WHERE player_name = 'Cole, Gerrit';


--4b Show different balls/strikes as well as frequency when someone is on base 

SELECT balls, strikes, count(*) frequency
FROM YankeesPitching2022.dbo.LastPitchYankees
WHERE (on_3b IS NOT NULL OR on_2b IS NOT NULL OR on_1b IS NOT NULL)
AND player_name = 'Cole, Gerrit'
GROUP BY balls, strikes
ORDER BY count(*) desc;

--4c What pitch causes the lowest launch speed

SELECT TOP 1 pitch_name, AVG(launch_speed * 1.00) LaunchSpeed
FROM YankeesPitching2022.dbo.LastPitchYankees
WHERE player_name = 'Cole, Gerrit'
GROUP BY pitch_name
ORDER BY AVG(launch_speed);