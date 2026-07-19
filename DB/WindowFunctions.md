Difference between ROW_NUMBER(), RANK() and DENSE_RANK()?

| Function   | Duplicate Rank | Gap?  |
| ---------- | -------------- | ----- |
| ROW_NUMBER | ❌ No           | No    |
| RANK       | ✅ Yes          | ✅ Yes |
| DENSE_RANK | ✅ Yes          | ❌ No  |


Employee Table

| EmpId | Name   | Department | Salary |
|-------|--------|------------|--------|
| 1     | Amit   | IT         | 100000 |
| 2     | Rahul  | IT         | 90000  |
| 3     | Priya  | IT         | 90000  |
| 4     | John   | HR         | 80000  |
| 5     | Alice  | HR         | 70000  |
-----------------------------------


Window Function --> "Calculate something for each row without removing the row."
Unlike GROUP BY, every employee is still shown.


Example 1 - ROW_NUMBER()
Requirement

**Give every employee a unique number based on salary.**
SELECT Name,
       Salary,
       ROW_NUMBER() OVER(ORDER BY Salary DESC) AS RowNum
FROM Employee;

| Name  | Salary | RowNum |
| ----- | ------ | -----: |
| Amit  | 100000 |      1 |
| Rahul | 90000  |      2 |
| Priya | 90000  |      3 |
| John  | 80000  |      4 |
| Alice | 70000  |      5 |

Explanation : Even though Rahul and Priya have the same salary, they get different numbers.
Think:
Teacher gives roll numbers

Amit  → Roll No 1

Rahul → Roll No 2

Priya → Roll No 3

Everyone gets a unique number.
**Example 2 - RANK()**  --  **Rank employees by salary.**
SELECT Name,
       Salary,
       RANK() OVER(ORDER BY Salary DESC) RankNo
FROM Employee;

| Name  | Salary | Rank |
| ----- | ------ | ---: |
| Amit  | 100000 |    1 |
| Rahul | 90000  |    2 |
| Priya | 90000  |    2 |
| John  | 80000  |    4 |
| Alice | 70000  |    5 |


Example 3 - DENSE_RANK()
Same example.
SELECT Name,
       Salary,
       DENSE_RANK() OVER(ORDER BY Salary DESC) RankNo
FROM Employee;
| Name  | Salary | Rank |
| ----- | ------ | ---: |
| Amit  | 100000 |    1 |
| Rahul | 90000  |    2 |
| Priya | 90000  |    2 |
| John  | 80000  |    3 |
| Alice | 70000  |    4 |


Example 4 - PARTITION BY

Requirement

Find ranking inside each department.
SELECT Name,
       Department,
       Salary,
       RANK() OVER(
           PARTITION BY Department
           ORDER BY Salary DESC
       ) AS DeptRank
FROM Employee;

| Department | Name  | Salary | Rank |
| ---------- | ----- | ------ | ---: |
| IT         | Amit  | 100000 |    1 |
| IT         | Rahul | 90000  |    2 |
| IT         | Priya | 90000  |    2 |
| HR         | John  | 80000  |    1 |
| HR         | Alice | 70000  |    2 |

Example 5 - Running Total

Requirement

Show cumulative salary.
SELECT Name,
       Salary,
       SUM(Salary)
OVER(ORDER BY EmpId) RunningTotal
FROM Employee;

| Name  | Salary | Running Total |
| ----- | ------ | ------------: |
| Amit  | 100000 |        100000 |
| Rahul | 90000  |        190000 |
| Priya | 90000  |        280000 |
| John  | 80000  |        360000 |
| Alice | 70000  |        430000 |

100000

100000+90000

190000+90000

280000+80000

360000+70000

Example 6 - LAG()
Show previous employee's salary.
SELECT Name,
       Salary,
       LAG(Salary)
OVER(ORDER BY Salary DESC) PreviousSalary
FROM Employee;
| Name  | Salary | Previous Salary |
| ----- | ------ | --------------: |
| Amit  | 100000 |            NULL |
| Rahul | 90000  |          100000 |
| Priya | 90000  |           90000 |
| John  | 80000  |           90000 |
| Alice | 70000  |           80000 |

Example 7 - LEAD()
Show next employee's salary.
SELECT Name,
       Salary,
       LEAD(Salary)
OVER(ORDER BY Salary DESC) NextSalary
FROM Employee;
| Name  | Salary | Next Salary |
| ----- | ------ | ----------: |
| Amit  | 100000 |       90000 |
| Rahul | 90000  |       90000 |
| Priya | 90000  |       80000 |
| John  | 80000  |       70000 |
| Alice | 70000  |        NULL |
