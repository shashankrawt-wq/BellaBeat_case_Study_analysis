--Fetch all the details of Table
	


-- Total Dataset(Rows)

select count(*) from dailyActivity_merged

-- Total No. of Unique Rows

select count(distinct id) as unique_users from dailyActivity_merged

-- Date between Dataset 



select min(ActivityDate) first_date,max(ActivityDate) as last_date
from dailyActivity_merged

-- Avg total Steps

Select avg(TotalSteps) from dailyActivity_merged


-- Avg. Calories 

select avg(calories) as avg_calories_burned from dailyActivity_merged

--Avg Distance Covered Daily

select Concat(round(avg(totalDistance),2), ' ','Km') as avg_distance_covered_daily
from dailyActivity_merged


-- Categorize user by activity level 
	select *, 
	case when TotalSteps< 5000 then 'sedentary'
		 when TotalSteps< 7500 then 'Lightly Active'
		 when TotalSteps< 10000 then 'Fairly Active'
		 else 'Very Active'
		 end as category
	from dailyActivity_merged


--  Analyze user activity patterns
select id, round(avg(totalSteps),2) Avg_steps_per_user,
concat(round(avg(TotalDistance),2),' ','Km') Avg_TotalDistance_per_use,
round(avg(Calories),2) Avg_Calories_burned_per_user,
round(avg(VeryActiveMinutes),2) Avg_VeryActiveMinutes_per_user ,
round(avg(FairlyActiveMinutes),2) Avg_FairlyActiveMinutes_per_user,
round(avg(LightlyActiveMinutes),2) Avg_LightlyActiveMinutes_per_user,
round(avg(SedentaryMinutes),2) Avg_SedentaryMinutes_per_user
from DailyActivity_merged
group by Id

-- Activity level distribution

select category,count(category) as activity_level_distribution
from (	select *, 
	case when TotalSteps< 5000 then 'sedentary'
		 when TotalSteps< 7500 then 'Lightly Active'
		 when TotalSteps< 10000 then 'Fairly Active'
		 else 'Very Active'
		 end as category
	from dailyActivity_merged) s
group by category

 -- Day of week analysis

SET DATEFIRST 1;  

SELECT FORMAT(activitydate,'dddd') AS weekdays,
       AVG(TotalSteps) AS avg_steps
FROM dailyActivity_merged
GROUP BY FORMAT(activitydate,'dddd'), DATEPART(WEEKDAY, activitydate)
ORDER BY DATEPART(WEEKDAY, activitydate);



-- Step goal attainment
-- Daily goal rate per user and overall:

WITH days AS 
(SELECT Id,
ActivityDate, 
TotalSteps
FROM dailyActivity_merged) 


SELECT COUNT(*)Total , 
count(Case when TotalSteps >= 10000
then totalsteps end) AS goal_days,
COUNT(*) AS total_days,
ROUND(CAST(Count(CASE WHEN TotalSteps >= 10000 THEN TotalSteps END) AS float) * 100.0 /
CAST(Count(*) AS float), 2) AS goal_rate_pct
from days

--Rolling trends and deltas
--7-day rolling steps and day-over-day change:

SELECT Id, ActivityDate, TotalSteps,
SUM(TotalSteps) OVER (PARTITION BY Id ORDER BY ActivityDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS steps_7d,
TotalSteps - LAG(TotalSteps) OVER (PARTITION BY Id ORDER BY ActivityDate) AS delta_steps FROM dailyActivity_merged;


--Weekly aggregation with WoW(Week On WeeK):

WITH wk AS
(SELECT Id, DATEFROMPARTS(YEAR(ActivityDate),
MONTH(ActivityDate), 1) AS month_key, DATEPART(ISO_WEEK, ActivityDate) AS iso_week,
SUM(TotalSteps) AS week_steps FROM dailyActivity_merged GROUP BY Id,
DATEPART(ISO_WEEK, ActivityDate), DATEFROMPARTS(YEAR(ActivityDate),
MONTH(ActivityDate), 1))


SELECT Id, iso_week, week_steps,
week_steps - LAG(week_steps) OVER (PARTITION BY Id ORDER BY iso_week) AS wow_change FROM wk;


