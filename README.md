# sql-amazing-project
Developed a comprehensive SQL-based Library Management System to manage books, members, employees, branches, and book issuance/return processes.


The project involved designing and querying a relational database to perform tasks such as tracking overdue books, updating book statuses, generating branch performance reports, and identifying active members and top-performing employees. Additionally, stored procedures were implemented to automate book issuance and return processes, enhancing operational efficiency. The project was initially built using PostgreSQL and later converted to SQL Server (T-SQL) to demonstrate cross-platform compatibility and adaptability.

Technologies Used
Databases: PostgreSQL, SQL Server (T-SQL)
Languages: SQL, PL/pgSQL (PostgreSQL), T-SQL (SQL Server)
Tools: pgAdmin, SQL Server Management Studio (SSMS)
Concepts: Relational Database Management, Stored Procedures, Common Table Expressions (CTEs), Joins, Window Functions
4. Key Features or Tasks
Overdue Books Tracking: Wrote a query to identify members with books overdue by more than 30 days, calculating days overdue and joining multiple tables (books, members, issued_status, return_status).
Book Status Updates: Created a stored procedure (add_return_records) to update book availability status upon return and log return details.
Branch Performance Report: Generated a report summarizing the number of books issued, returned, and total revenue per branch.
Active Members Table: Used a CREATE TABLE AS (CTAS) statement to create a table of members who issued books in the last 2 months.
Top Employees Query: Identified the top 3 employees who processed the most book issues, including their branch details.
Book Issuance Automation: Developed a stored procedure (issue_book) to check book availability and automate issuance while updating statuses.
SQL Server Conversion: Adapted all queries and stored procedures from PostgreSQL to SQL Server, handling differences in syntax (e.g., CURRENT_DATE to GETDATE(), EXTRACT to DATEPART).
5. Challenges and Solutions
Challenge: Handling date calculations for overdue books in a cross-platform manner.
Solution: Used CURRENT_DATE - issued_date in PostgreSQL and converted to DATEDIFF(DAY, issued_date, GETDATE()) in SQL Server for accurate day calculations.
Challenge: Preventing errors in stored procedures when books were unavailable.
Solution: Implemented conditional logic (IF...ELSE) to check book status before issuance and provided user-friendly error messages.
Challenge: Converting PostgreSQL-specific syntax (e.g., ::numeric, ordinal GROUP BY) to SQL Server.
Solution: Replaced ::numeric with CAST(... AS FLOAT) and used explicit column names in GROUP BY and ORDER BY clauses.
