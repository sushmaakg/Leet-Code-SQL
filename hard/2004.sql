/********************************************************************************************
Source : Leet Code
2004. The Number of Seniors and Juniors to Join the Company

+-------------+------+
| Column Name | Type |
+-------------+------+
| employee_id | int  |
| experience  | enum |
| salary      | int  |
+-------------+------+
employee_id => Primary key.
experience  => enum('Senior', 'Junior').
Each row of this table indicates the id of a candidate, their monthly salary, and their experience.

A company wants to hire new employees. The budget of the company for the salaries is $70000. 
The company's criteria for hiring are:
	1) Hiring the largest number of seniors.
	2) After hiring the maximum number of seniors, use the remaining budget to hire the largest number of juniors.

Write an SQL query to find the number of seniors and juniors hired under the mentioned criteria.
Return the result table in any order.
The query result format is in the following example.


Example 1:

Input: Candidates table:
+-------------+------------+--------+
| employee_id | experience | salary |
+-------------+------------+--------+
| 1           | Junior     | 10000  |
| 9           | Junior     | 10000  |
| 2           | Senior     | 20000  |
| 11          | Senior     | 20000  |
| 13          | Senior     | 50000  |
| 4           | Junior     | 40000  |
+-------------+------------+--------+
Output: 
+------------+---------------------+
| experience | accepted_candidates |
+------------+---------------------+
| Senior     | 2                   |
| Junior     | 2                   |
+------------+---------------------+
Explanation: 
We can hire 2 seniors with IDs (2, 11). Since the budget is $70000 and the sum of their salaries is $40000, we still have $30000 but they are not enough to hire the senior candidate with ID 13.
We can hire 2 juniors with IDs (1, 9). Since the remaining budget is $30000 and the sum of their salaries is $20000, we still have $10000 but they are not enough to hire the junior candidate with ID 4.
Example 2:

Input: 
Candidates table:
+-------------+------------+--------+
| employee_id | experience | salary |
+-------------+------------+--------+
| 1           | Junior     | 10000  |
| 9           | Junior     | 10000  |
| 2           | Senior     | 80000  |
| 11          | Senior     | 80000  |
| 13          | Senior     | 80000  |
| 4           | Junior     | 40000  |
+-------------+------------+--------+
Output: 
+------------+---------------------+
| experience | accepted_candidates |
+------------+---------------------+
| Senior     | 0                   |
| Junior     | 3                   |
+------------+---------------------+
Explanation: 
We cannot hire any seniors with the current budget as we need at least $80000 to hire one senior.
We can hire all three juniors with the remaining budget.

*************************************************************************************************/
/************************************************************************************************
CREATE TABLE "Prep"."CANDIDATE"
(
EMPLOYEE_ID INTEGER,
EXPERIENCE VARCHAR(10),
SALARY INTEGER
) ;

Example 1 data:-
INSERT INTO "Prep"."CANDIDATE" VALUES (1,'Junior',10000);
INSERT INTO "Prep"."CANDIDATE" VALUES (9,'Junior',10000);
INSERT INTO "Prep"."CANDIDATE" VALUES (2,'Senior',20000);
INSERT INTO "Prep"."CANDIDATE" VALUES (11,'Senior',20000);
INSERT INTO "Prep"."CANDIDATE" VALUES (13,'Senior',50000);
INSERT INTO "Prep"."CANDIDATE" VALUES (4,'Junior',40000);

Example 2 data:-
DELETE FROM "Prep"."CANDIDATE";
INSERT INTO "Prep"."CANDIDATE" VALUES (1,'Junior',10000);
INSERT INTO "Prep"."CANDIDATE" VALUES (9,'Junior',10000);
INSERT INTO "Prep"."CANDIDATE" VALUES (2,'Senior',80000);
INSERT INTO "Prep"."CANDIDATE" VALUES (11,'Senior',80000);
INSERT INTO "Prep"."CANDIDATE" VALUES (13,'Senior',80000);
INSERT INTO "Prep"."CANDIDATE" VALUES (4,'Junior',40000);

*************************************************************************************************/

WITH CTE_Senior AS (
SELECT 
* 
FROM 
(
SELECT
EMPLOYEE_ID,EXPERIENCE,SALARY,SUM(SALARY) OVER(ORDER BY SALARY ASC  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CUMULATIVE_SUM_SALARY
FROM (
SELECT 
EMPLOYEE_ID,EXPERIENCE,SALARY
FROM "Prep"."CANDIDATE" 
WHERE SALARY <=70000 AND EXPERIENCE='Senior'
) a
) b
where CUMULATIVE_SUM_SALARY<=70000
),
CTE_JUNIOR AS 
(
SELECT 
*
FROM 
(
SELECT 
EMPLOYEE_ID,EXPERIENCE,SALARY,SUM(SALARY) OVER(ORDER BY SALARY ASC  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CUMULATIVE_SUM_SALARY
FROM "Prep"."CANDIDATE" 
WHERE 
	SALARY <=70000-COALESCE((SELECT SUM(SALARY) FROM CTE_Senior),0) AND 
	EXPERIENCE='Junior'
) a where CUMULATIVE_SUM_SALARY<=70000-COALESCE((SELECT SUM(SALARY) FROM CTE_Senior) ,0)
)
SELECT EXPERIENCE,COUNT(*) FROM 
(
SELECT * FROM CTE_Senior
UNION ALL
SELECT * FROM CTE_JUNIOR
) f group by EXPERIENCE;
