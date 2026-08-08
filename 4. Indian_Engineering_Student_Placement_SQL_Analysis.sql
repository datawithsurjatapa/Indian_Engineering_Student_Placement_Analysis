CREATE TABLE stud_data (
    student_id                     VARCHAR(10) PRIMARY KEY,
    age                            SMALLINT,
    gender                         VARCHAR(10),
    state                          VARCHAR(30),
    branch                         VARCHAR(20),
    college_tier                   VARCHAR(10),
    cgpa                           DECIMAL(4,2),
    attendance_percentage          DECIMAL(5,2),
    dsa_problems_solved            INT,
    aptitude_score                 SMALLINT,
    communication_score            SMALLINT,
    projects_count                 SMALLINT,
    internships_count              SMALLINT,
    certifications_count           SMALLINT,
    open_source_contributions      DECIMAL(6,1),
    github_contributions           INT,
    linkedin_activity_score        DECIMAL(5,1),
    hackathons_participated        SMALLINT,
    competitive_programming_rating INT,
    study_hours_per_week           SMALLINT,
    soft_skills_score              SMALLINT,
    leadership_experience          VARCHAR(5),
    extracurricular_activities     SMALLINT,
    placement_status               VARCHAR(15),
    package_lpa                    DECIMAL(6,2),
    tier_rank                      SMALLINT,
    cgpa_level                     VARCHAR(10)
);
SELECT * FROM stud_data;

SELECT COUNT(*) AS total_students FROM stud_data;

--Placement rate overall
SELECT
    Placement_Status,
    COUNT(*) AS student_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM stud_data), 2) AS percentage
FROM stud_data
GROUP BY Placement_Status;

--Placement rate by college tier
SELECT
    College_Tier,
    Placement_Status,
    COUNT(*) AS student_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY College_Tier), 2) AS pct_within_tier
FROM stud_data
GROUP BY College_Tier, Placement_Status
ORDER BY College_Tier;

--Average package by branch (highest to lowest)
SELECT
    Branch,
    ROUND(AVG(Package_LPA), 2) AS avg_package_lpa,
    COUNT(*) AS student_count
FROM stud_data
WHERE Placement_Status = 'Placed'
GROUP BY Branch
ORDER BY avg_package_lpa DESC;

--Top 10 highest-paid placements
SELECT Student_ID, Branch, College_Tier, CGPA, Package_LPA
FROM stud_data
WHERE Placement_Status = 'Placed'
ORDER BY Package_LPA DESC
LIMIT 10;
--CGPA comparison — placed vs not placed
SELECT
    Placement_Status,
    ROUND(AVG(CGPA), 2) AS avg_cgpa,
    ROUND(MIN(CGPA), 2) AS min_cgpa,
    ROUND(MAX(CGPA), 2) AS max_cgpa
FROM stud_data
GROUP BY Placement_Status;

--Placement rate by gender
SELECT
    Gender,
    ROUND(SUM(CASE WHEN Placement_Status = 'Placed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
	AS placement_rate_pct
FROM stud_data
GROUP BY Gender;
--Students with strong technical profile but not placed
SELECT Student_ID, Branch, CGPA, DSA_Problems_Solved, Competitive_Programming_Rating
FROM stud_data
WHERE Placement_Status = 'Not Placed'
  AND DSA_Problems_Solved > 200
  AND CGPA > 8.0
ORDER BY DSA_Problems_Solved DESC
LIMIT 15;

--State-wise placement rate (top 10 states)
SELECT
    State,
    COUNT(*) AS total_students,
    ROUND(SUM(CASE WHEN Placement_Status = 'Placed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS placement_rate_pct
FROM stud_data
GROUP BY State
HAVING COUNT(*) > 100
ORDER BY placement_rate_pct DESC
LIMIT 10;
--STUDY HOURS vs OUTCOME — IS MORE STUDYING ALWAYS BETTER?
SELECT
    CASE
        WHEN study_hours_per_week < 10 THEN 'Under 10 hrs'
        WHEN study_hours_per_week < 20 THEN '10-19 hrs'
        WHEN study_hours_per_week < 30 THEN '20-29 hrs'
        ELSE '30+ hrs'
    END AS study_hours_bucket,
    COUNT(*) AS total_students,
    ROUND(100.0 * SUM(CASE WHEN placement_status = 'Placed' THEN 1 ELSE 0 END) / COUNT(*), 2) 
	AS placement_rate_pct
FROM stud_data
GROUP BY study_hours_bucket
ORDER BY study_hours_bucket;
--RANK STUDENTS BY PACKAGE WITHIN COLLEGE TIER
SELECT
    student_id,
    college_tier,
    package_lpa,
    ROW_NUMBER() OVER (PARTITION BY college_tier ORDER BY package_lpa DESC) AS rank_in_tier
FROM stud_data
WHERE placement_status = 'Placed';