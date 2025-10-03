

-- No. of Unique users
select COUNT(distinct Id) as Total_users
from fitbit_Analysis


-- Data Range

select MIN(activityDate) Start_Date , MAX(activityDate) End_date
from fitbit_Analysis


-- How many records per user do we have (days tracked)?
select ID,COUNT(ActivityDate) 
from fitbit_Analysis
group by ID
order by ID


-- What is the average number of daily steps across all users?

Select ID,AVG(totalsteps) as Avg_Steps_per_user
from fitbit_Analysis
group by ID


-- What is the maximum and minimum steps recorded by any user on any day?

select ID,MIN(totalsteps)as min_steps ,MAX(totalsteps) as max_steps
from fitbit_Analysis
group by id

-- How many users achieve 10,000+ steps on average?

SELECT count(id) as User_With_10K_steps
FROM (
    SELECT id, AVG(totalsteps) AS avg_steps
    FROM fitbit_Analysis
    GROUP BY id
    HAVING AVG(totalsteps) > 10000
) AS t;

-- What is the average sedentary minutes vs active minutes across users?


select id,
AVG(sedentaryMinutes) avg_sedentary_minutes, 
avg(fairlyactiveminutes+lightlyactiveminutes+sedentaryminutes) avg_active_minutes
from fitbit_Analysis
group by id


-- Goal Achievement Analysis



-- Q1. What % of days meet the 10,000 step goal?

with cte as
(Select ID,
case when totalsteps>=10000 then 'Completed Goal' else 'Incomplete Goal' end as goal_status
from fitbit_Analysis)


select 
concat(round(cast(SUM(case when goal_status='Completed Goal' then 1 else 0 end) as float)
*100.00/COUNT(id),2), ' ','%') as days_goal_met_percentage
from cte


-- Which users meet the goal most consistently?

with cte as
(Select ID,
case when totalsteps>=10000 then 'Completed Goal' else 'Incomplete Goal' end as goal_status
from fitbit_Analysis)

select ID,
concat(round(cast(SUM(case when goal_status='Completed Goal' then 1 else 0 end) as float)
*100.00/COUNT(id),2), ' ','%')as Most_consistent_users
from cte
group by id
order by Most_consistent_users desc


-- On how many days did no users meet the step goal?

With daily_check AS (
    SELECT ActivityDate,
           MAX(CASE WHEN TotalSteps >= 10000 THEN 1 ELSE 0 END) AS any_user_goal
    FROM fitbit_Analysis
    GROUP BY ActivityDate
)
SELECT COUNT(*) AS days_no_user_met_goal
FROM daily_check
WHERE any_user_goal = 0;


--Trends & Time Patterns

-- What is the average steps per weekday (Mon–Sun)?

select DATEName(weekday,ActivityDate) as Weekdays , AVG(totalsteps) Average_steps
from fitbit_Analysis
group by DATEname(weekday,ActivityDate),DATEPART(weekday,activitydate)
order by DATEPART(weekday,ActivityDate)


-- Do users burn more calories on weekends vs weekdays?

select case 
      when DATEPART(weekday,ActivityDate) in (1,7) then 'weekend' else 'weekday' end as date_category,
avg(calories) Average_calories
from fitbit_Analysis
group by case
      when DATEPART(weekday,ActivityDate) in (1,7) then 'weekend' else 'weekday' end


-- What is the average sedentary minutes per weekday?

select datename(WEEKDAY,activitydate) as Weekdays,
AVG(sedentaryminutes) as Average_Sedentary_minutes
from fitbit_Analysis
group by DATEPART(weekday,activitydate), DATENAME(WEEKDAY,activitydate)
order by DATEPART(WEEKDAY, ActivityDate)


-- User Segmentation

--Segment users into groups:

--> Low Active (<8,000 steps/day)
--> Moderate (8,000–12,000 steps/day)
--> Highly Active (>12,000 steps/day)

--  How many users fall into each group?

with cte as 
(select 
case 
     when totalsteps<8000 then 'Low Active'
	  when totalsteps between 8000 and 12000 then 'Moderate'
	   when totalsteps>12000 then 'Highly Active'
end as Activity_level,id
from fitbit_analysis)


select Activity_level,COUNT(id)
from cte
group by activity_level

-- Find the top 5 most active days (highest avg steps across all users).

-- Top 5 days by average steps
SELECT TOP 5 ActivityDate, AVG(TotalSteps) AS avg_steps
FROM fitbit_Analysis
GROUP BY ActivityDate
ORDER BY avg_steps DESC;

-- Find the least 5 most active days (highest avg steps across all users).

-- Bottom 5 days by average steps
SELECT TOP 5 ActivityDate, AVG(TotalSteps) AS avg_steps
FROM fitbit_Analysis
GROUP BY ActivityDate
ORDER BY avg_steps ASC;


/*
---------------------------------------------------
 Insights for Bellabeat from SQL Analysis
---------------------------------------------------

1. Goal Achievement:
   - Only a fraction of days meet the 10,000 step goal.
   - Many users rarely or never achieve it, while a few are very consistent.
    Bellabeat can introduce gamification (badges, streaks) to boost motivation.

2. Activity Patterns:
   - Users burn more calories and take more steps on weekends compared to weekdays.
   - Sedentary minutes are consistently high, even on goal days.
   --  Weekday push notifications and “move reminders” can help reduce sedentary time.

3. User Segmentation:
   - Majority of users fall into the "Low Active" (<8k steps/day) category.
   - Only a small group achieves 12k+ steps regularly.
     -- Bellabeat should design campaigns focused on converting Low Active users into Moderate users.

4. Trends:
   - Certain days show peak activity (likely weekends or holidays).
   - Lowest activity days could signal drop-offs or fatigue.
    -- Bellabeat can target these low-activity periods with challenges or reminders.

*/ 
