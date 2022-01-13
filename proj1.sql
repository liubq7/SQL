-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

DROP VIEW IF EXISTS cacollege;
DROP VIEW IF EXISTS slg;
DROP VIEW IF EXISTS lslg;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst, namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, playerid, yearid
  FROM people NATURAL JOIN halloffame AS h
  WHERE h.inducted = 'Y'
  ORDER BY yearid DESC, playerid
;

-- Question 2ii
CREATE VIEW cacollege(playerid, schoolid)
AS 
  SELECT c.playerid, c.schoolid 
  FROM collegeplaying c NATURAL JOIN schools s
  WHERE s.schoolState = 'CA'
;

CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, q.playerid, schoolid, yearid
  FROM q2i q NATURAL JOIN cacollege c
  ORDER BY yearid DESC, schoolid, q.playerid;
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q.playerid, namefirst, namelast, schoolid
  FROM q2i q LEFT OUTER JOIN collegeplaying c
  ON q.playerid = c.playerid
  ORDER BY q.playerid DESC, schoolid;
;

-- Question 3i
CREATE VIEW slg(playerid, yearid, slgval)
AS 
  SELECT playerid, yearid, (h + h2b + 2 * h3b + 3 * hr + 0.0) / (ab + 0.0)
  FROM batting
  WHERE ab > 50
;

CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT s.playerid, namefirst, namelast, yearid, slgval
  FROM slg s LEFT OUTER JOIN people p
  ON s.playerid = p.playerid
  ORDER BY slgval DESC, yearid, s.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW lslg(playerid, lslgval)
AS
  SELECT playerid, (SUM(h) + SUM(h2b) + 2 * SUM(h3b) + 3 * SUM(hr) + 0.0) / (SUM(ab) + 0.0)
  FROM batting
  GROUP BY playerid
  HAVING SUM(ab) > 50
;

CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT l.playerid, namefirst, namelast, lslgval
  FROM lslg l LEFT OUTER JOIN people p
  ON l.playerid = p.playerid
  ORDER BY lslgval DESC, l.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, lslgval
  FROM lslg l LEFT OUTER JOIN people p
  ON l.playerid = p.playerid
  WHERE lslgval > (
    SELECT lslgval
    FROM lslg
    WHERE playerid = 'mayswi01'
  )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
DROP VIEW IF EXISTS helper;
DROP VIEW IF EXISTS binids;
CREATE VIEW helper(min, max, width)
AS
  SELECT MIN(salary), MAX(salary), (MAX(salary) - MIN(salary)) / 10
  FROM salaries
  WHERE yearid = 2016
;

CREATE VIEW binids(salary, binid, min, max, width)
AS
  SELECT salary, 
    (CASE WHEN salary = max THEN 
      9 
    ELSE 
      CAST((salary - min) / width AS INT) 
    END), 
    min, 
    max, 
    width
  FROM salaries s, helper h
  WHERE yearid = 2016
;

CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid, min + binid * width, min + (binid + 1) * width, COUNT(*)
  FROM binids
  GROUP BY binid
  ORDER BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT s1.yearid, s1.min - s2.min, s1.max - s2.max, s1.avg - s2.avg
  FROM q4i s1 INNER JOIN q4i s2
  ON s1.yearid - 1 = s2.yearid
  ORDER BY s1.yearid
;

-- Question 4iv
DROP VIEW IF EXISTS maxsalary;
CREATE VIEW maxsalary(playerid, max, yearid)
AS
  SELECT playerid, salary, yearid
  FROM salaries
  WHERE (yearid = 2000 AND salary = (SELECT MAX(salary) FROM salaries WHERE yearid = 2000)) OR
    (yearid = 2001 AND salary = (SELECT MAX(salary) FROM salaries WHERE yearid = 2001))
;

CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT m.playerid, namefirst, namelast, max, yearid
  FROM maxsalary m LEFT OUTER JOIN people p
  ON m.playerid = p.playerid
;

-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid, MAX(salary) - MIN(salary)
  FROM allstarfull a LEFT OUTER JOIN salaries s
  ON a.playerid = s.playerid AND a.teamid = s.teamid AND a.yearid = s.yearid
  WHERE a.yearid = 2016
  GROUP BY a.teamid
;
