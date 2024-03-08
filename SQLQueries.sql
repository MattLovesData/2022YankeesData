--Question 1 AVG Pitches Per at Bat Analysis


--1a AVG Pitches Per At Bat

SELECT AVG(1.00 * Pitch_number) AS AvgNumPitchesPerAtBat
FROM dbo.LastPitchYankees;


	AvgNumPitchesPerAtBat
	3.904577

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

		
	Home_or_Away	AvgNumPitchesPerAtBat
	Home	           3.893518
	Away	           3.916038

--1c AVG Pitches Per At Bat Lefty Vs Righty

SELECT 
	AVG(Case when batter_handedness = 'R' Then 1.00 * Pitch_number end) AS RightyAtBats,
	AVG(Case when batter_handedness = 'L' Then 1.00 * Pitch_number end) AS LeftyAtBats
FROM dbo.LastPitchYankees

	
	RightyAtBats	LeftyAtBats
	3.840168	4.019176
	
--1f AVG Pitches Per at Bat Per Pitcher with 20+ Innings | Order in descending

SELECT 
	YPS.Name,
	AVG(1.00 * Pitch_number) AS AVGPitches
FROM YankeesPitching2022.dbo.YankeesPitchingStats AS YPS
JOIN YankeesPitching2022.dbo.LastPitchYankees AS LPY ON YPS.Pitcher_ID = LPY.pitcher
WHERE IP >= 20
GROUP BY YPS.Name
ORDER BY AVG(1.00 * Pitch_number) DESC;


	Name	        AVGPitches
	Aroldis Chapman   4.231250
	Ron Marinaccio	  4.159340
	Gerrit Cole	  4.113065
	Albert Abreu	  4.111111
	Luis Severino	  4.036945
	Nestor Cortes	  4.001623
	Clarke Schmidt	  3.957264
	Miguel Castro	  3.939393
	Michael King	  3.923857
	Lucas Luetge	  3.884000
	Jameson Taillon	  3.847736
	Lou Trivino	  3.838709
	Clay Holmes	  3.798449
	Jonathan Loaisiga 3.797029
	Frankie Montas	  3.756756
	JP Sears	  3.702380
	Wandy Peralta	  3.675675
	Domingo German	  3.627516
	Jordan Montgomery 3.622881
	
--Question 2 Last Pitch Analysis

--2a Count of the Last Pitches Thrown in Desc Order

SELECT 
	pitch_name,
	COUNT(*) AS TimesThrown
FROM dbo.LastPitchYankees
GROUP BY pitch_name
ORDER BY COUNT(*) DESC;


	pitch_name	TimesThrown
	4-Seam Fastball	1669
	Sinker	        1197
	Changeup	803
	Slider	        727
	Cutter	        545
	Curveball	408
	Sweeper	        387
	Knuckle Curve	120
	Split-Finger	74
	NULL	        9
	Slurve	        2
	Eephus	        1

--2b Count of the different last pitches Fastball or Offspeed

SELECT 
	SUM(CASE WHEN pitch_name in ('4-Seam Fastball', 'Cutter', 'Sinker') then 1 else 0 end) Fastball,
	SUM(CASE WHEN pitch_name NOT in ('4-Seam Fastball', 'Cutter', 'Sinker') then 1 else 0 end) Offspeed
FROM dbo.LastPitchYankees;


	Fastball	Offspeed
	3411	        2522

--2c Percentage of the different last pitches Fastball or Offspeed

SELECT 
	100 * SUM(CASE WHEN pitch_name in ('4-Seam Fastball', 'Cutter', 'Sinker') then 1 else 0 end) / count(*) FastballPercent,
	100 * SUM(CASE WHEN pitch_name NOT in ('4-Seam Fastball', 'Cutter', 'Sinker') then 1 else 0 end) / count(*) OffspeedPercent
FROM dbo.LastPitchYankees;


	FastballPercent	OffspeedPercent
	      57	      42

--Question 3 Homerun analysis

--3a What pitches have given up the most HRs

SELECT pitch_name, COUNT(*) HRs
FROM YankeesPitching2022.dbo.LastPitchYankees
WHERE events = 'home_run'
GROUP BY pitch_name
ORDER BY COUNT(*) DESC;


	pitch_name	HRs
	4-Seam Fastball	57
	Slider	        23
	Cutter	        20
	Changeup	19
	Sinker	        18
	Curveball	9
	Sweeper	        7
	Split-Finger	2
	Knuckle Curve	2
	
--3b Show HRs given up by zone and pitch, show top 5 most common

SELECT TOP 5 zone, pitch_name
FROM YankeesPitching2022.dbo.LastPitchYankees
WHERE events = 'home_run'
GROUP BY zone, pitch_name
ORDER BY COUNT(*) DESC;

	zone	pitch_name
	2	4-Seam Fastball
	6	4-Seam Fastball
	5	4-Seam Fastball
	8	Changeup
	5	Slider
	
--3c Show HRs for each count type -> Balls/Strikes + Type of Pitcher

SELECT YPS.POS, LPY.balls, LPY.strikes, COUNT(*) HRs
FROM YankeesPitching2022.dbo.LastPitchYankees AS LPY
JOIN YankeesPitching2022.dbo.YankeesPitchingStats AS YPS ON YPS.Pitcher_ID = LPY.pitcher
WHERE events = 'home_run'
GROUP BY YPS.POS, LPY.balls, LPY.strikes
ORDER BY COUNT(*) DESC;


	POS	balls	strikes	HRs
	SP	0	0	22
	SP	1	1	21
	SP	0	1	13
	SP	2	2	12
	SP	1	2	11
	SP	1	0	11
	SP	3	2	9
	RP	1	1	8
	RP	0	0	7
	RP	1	0	7
	SP	2	1	6
	RP	0	1	6
	RP	1	2	5
	SP	0	2	3
	RP	2	2	3
	RP	3	2	3
	SP	2	0	3
	SP	3	0	2
	SP	3	1	2
	RP	2	1	2
	RP	0	2	1
	
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


	name	      balls  strikes	HRs
	Aroldis Chapman	1	0	1
	Aroldis Chapman	1	1	1
	Aroldis Chapman	1	2	1
	Aroldis Chapman	2	2	1
	Clarke Schmidt	0	0	2
	Clay Holmes	1	2	2
	Domingo German	0	1	2
	Domingo German	0	2	2
	Domingo German	1	1	2
	Domingo German	2	2	2
	Frankie Montas	1	0	3
	Gerrit Cole	1	1	7
	Jameson Taillon	0	0	5
	Jameson Taillon	3	2	5
	Jonathan Loaisiga	0	0	1
	Jonathan Loaisiga	0	1	1
	Jonathan Loaisiga	1	1	1
	Jordan Montgomery	0	1	4
	Lucas Luetge	0	0	1
	Lucas Luetge	0	1	1
	Lucas Luetge	1	0	1
	Lucas Luetge	3	2	1
	Luis Severino	0	0	6
	Michael King	1	0	1
	Michael King	1	1	1
	Michael King	2	2	1
	Nestor Cortes	1	1	7
	Ron Marinaccio	0	1	1
	Ron Marinaccio	1	0	1
	Wandy Peralta	0	1	1
	Wandy Peralta	2	1	1
		
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


	AvgReleaseSpeed	    AvgSpinRate	strikeouts	Zone
	93.1532662741503	2435	    257	         14
	
--4b Show different balls/strikes as well as frequency when someone is on base 

SELECT balls, strikes, count(*) frequency
FROM YankeesPitching2022.dbo.LastPitchYankees
WHERE (on_3b IS NOT NULL OR on_2b IS NOT NULL OR on_1b IS NOT NULL)
AND player_name = 'Cole, Gerrit'
GROUP BY balls, strikes
ORDER BY count(*) desc;


	balls	strikes	frequency
	1	2	56
	3	2	43
	2	2	42
	0	2	29
	0	0	26
	1	1	18
	0	1	13
	2	1	10
	1	0	9
	3	1	8
	3	0	5
	2	0	4
	
--4c What pitch causes the lowest launch speed

SELECT TOP 1 pitch_name, AVG(launch_speed * 1.00) LaunchSpeed
FROM YankeesPitching2022.dbo.LastPitchYankees
WHERE player_name = 'Cole, Gerrit'
GROUP BY pitch_name
ORDER BY AVG(launch_speed);


pitch_name	LaunchSpeed
Cutter	         84.4473687222129
