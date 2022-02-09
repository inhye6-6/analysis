CREATE TABLE rectangles (
  id INTEGER NOT NULL PRIMARY KEY,
  width INTEGER NOT NULL CHECK(width > 0),
  height INTEGER NOT NULL CHECK(height > 0)
);

INSERT INTO rectangles(id, width, height) VALUES(1, 4, 3);
INSERT INTO rectangles(id, width, height) VALUES(2, 2, 7);
INSERT INTO rectangles(id, width, height) VALUES(3, 6, 2);

-- Expected output (in any order):
-- area  number of rectangles
-- --------------------------
-- 12    2
-- 14    1

select a.area, count(a.area) as numberofrectangles
from (select width*height as area 
    from rectangles
    ) as a
group by a.area
order by 1


-- Suggested testing environments

CREATE TABLE customers (
  id INTEGER NOT NULL PRIMARY KEY,
  name VARCHAR(30) NOT NULL
);

CREATE TABLE transactions (
  id INTEGER NOT NULL PRIMARY KEY,
  customerId INTEGER,
  amount DECIMAL(15,2) NOT NULL,
  FOREIGN KEY (customerId) REFERENCES customers(id)
);

INSERT INTO customers(id, name) VALUES(1, 'Steve');
INSERT INTO customers(id, name) VALUES(2, 'Jeff');
INSERT INTO transactions(id, customerId, amount) VALUES(1, 1, 100);
INSERT INTO transactions(id, customerId, amount) VALUES(2, 1, 150);

-- Expected output (in any order):
-- name     transactions
-- -------------------------------
-- Steve    2
-- Jeff     0

-- Explanation:
-- In this example.
-- There are two customers, Steve and Jeff.
-- Steve has made two transactions. Jeff has made zero transactions.



select c.name , ifnull(t.transactions,0)
from customers as c left join (select distinct b.customerId, count(*) over(partition by b.customerId) as transactions
    from transactions) as t
    on c.id = t.customerId


-- Example case create statement:
CREATE TABLE companies (
  id INTEGER PRIMARY KEY,
  name VARCHAR(30) NOT NULL,
  country VARCHAR(30) NOT NULL
);

INSERT INTO companies(id, name, country) VALUES(1, 'Walmart', 'United States');
INSERT INTO companies(id, name, country) VALUES(2, 'State Grid', 'China');
INSERT INTO companies(id, name, country) VALUES(3, 'Volkswagen', 'Germany');

-- Expected output:
-- country
-- -------------
-- China
-- Germany
-- United States


select distinct country
from companies
order by 1


-- Example case create statement:
CREATE TABLE fsia (
  companyName VARCHAR(30) NOT NULL PRIMARY KEY,
  marketCapitalization FLOAT NOT NULL
);

CREATE TABLE fsib (
  companyName VARCHAR(30) NOT NULL PRIMARY KEY,
  sharePrice FLOAT NOT NULL,
  sharesOutstanding INTEGER NOT NULL
);

INSERT INTO fsia(companyName, marketCapitalization) VALUES('Baggage Enterprise.', 12500);
INSERT INTO fsia(companyName, marketCapitalization) VALUES('Fun Book Corporation', 10000);

INSERT INTO fsib(companyName, sharePrice, sharesOutstanding) VALUES('Macaroni Inc.', 8, 1000);
INSERT INTO fsib(companyName, sharePrice, sharesOutstanding) VALUES('Solitude Ltd.', 12.5, 600);
INSERT INTO fsib(companyName, sharePrice, sharesOutstanding) VALUES('Universal Exports LLC', 1.2, 2300);

-- Expected output:
-- companyName           marketCapitalization
-- ---------------------------------------------
-- Baggage Enterprise    12500 
-- Fun Book Corporation  10000 
-- Macaroni Inc.         8000 
-- Solitude Ltd.         7500 
-- Universal Exports LLC 2760  

-- Explanation:
-- In this example.
-- Baggage Enterprise is the largest company, it therefore appears first in the results.
-- The companies descend in order by marketCapitalization until Universal Exports LLC which is the smallest.


select c.companyName, c.marketCapitalization
from(
    select *
    from fsia
    union all
    select companyName, cast(sharePrice*sharesOutstanding) as marketCapitalization
    from fsib 
) as c
order by 2 desc


-- Suggested testing environments
-- For MS SQL:
-- https://sqliteonline.com/ with language set as MS SQL
-- For MySQL:
-- https://www.db-fiddle.com/ with MySQL version set to 8
-- For SQLite:
-- http://sqlite.online/
-- Put the following without '--' at the top to enable foreign key support in SQLite.
-- PRAGMA foreign_keys = ON;

-- Example case create statement:
CREATE TABLE colleges (
  id INTEGER PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE students (
  id INTEGER PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  collegeId INTEGER,
  FOREIGN KEY (collegeId) REFERENCES colleges(id)
);

CREATE TABLE rankings (
  studentId INTEGER,
  ranking INTEGER NOT NULL,
  year INTEGER NOT NULL,
  FOREIGN KEY (studentId) REFERENCES students(id)
);

INSERT INTO colleges(id, name) VALUES(1, 'Pi Institute Of Engineering');
INSERT INTO colleges(id, name) VALUES(2, 'Kappa Institute Of Technology');
INSERT INTO colleges(id, name) VALUES(3, 'Omega Science Academy');

INSERT INTO students(id, name, collegeId) VALUES(1, 'Rob', 1);
INSERT INTO students(id, name, collegeId) VALUES(2, 'Shawn', 1);
INSERT INTO students(id, name, collegeId) VALUES(3, 'Bill', 2);
INSERT INTO students(id, name, collegeId) VALUES(4, 'Steve', 2);
INSERT INTO students(id, name, collegeId) VALUES(5, 'Roger', 3);
INSERT INTO students(id, name, collegeId) VALUES(6, 'Megan', 3);

INSERT INTO rankings(studentId, ranking, year) VALUES(1, 1, 2014);
INSERT INTO rankings(studentId, ranking, year) VALUES(6, 2, 2014);
INSERT INTO rankings(studentId, ranking, year) VALUES(3, 1, 2015);
INSERT INTO rankings(studentId, ranking, year) VALUES(4, 2, 2015);
INSERT INTO rankings(studentId, ranking, year) VALUES(2, 3, 2015);
INSERT INTO rankings(studentId, ranking, year) VALUES(5, 4, 2015);
INSERT INTO rankings(studentId, ranking, year) VALUES(3, 1, 2016);
INSERT INTO rankings(studentId, ranking, year) VALUES(4, 2, 2016);

-- Expected output (rows in any order):
-- Name                             TopRank     NumberOfStudents
-- ----------------------------------------------------------------
-- Kappa Institute of Technology      1               2
-- Pi Institute of Engineering        3               1

-- 2015년에 한애들 빼ㅓㅅ 3안에 든사람 빼기 rank를 더해줘야함 일studentId 별로 묶자
select c.name, a.TopRank, count(a.collegeId) as NumberOfStudents
from colleges as c,
(select s.id ,s.collegeId, min(r.ranking) over(partition by s.collegeId ) as TopRank
from students as s , rankings as r
where s.id=r.studentId and r.year = 2015 and r.ranking <=3
)as a
where a.collegeId = c.id
group by a.collegeId