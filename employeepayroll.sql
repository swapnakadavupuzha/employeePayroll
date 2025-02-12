USE [EmployeePayroll]
GO
/****** Object:  Table [dbo].[Departments]    Script Date: 10-02-2025 23:53:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Departments](
	[DepartmentID] [int] IDENTITY(1,1) NOT NULL,
	[DepartmentName] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[DepartmentName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 10-02-2025 23:53:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employees](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[HireDate] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Salaries]    Script Date: 10-02-2025 23:53:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Salaries](
	[EmployeeID] [int] NOT NULL,
	[BaseSalary] [decimal](10, 2) NOT NULL,
	[Bonus] [decimal](10, 2) NULL,
	[Deductions] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalaryHistory]    Script Date: 10-02-2025 23:53:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalaryHistory](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [int] NULL,
	[OldBaseSalary] [decimal](10, 2) NULL,
	[OldBonus] [decimal](10, 2) NULL,
	[OldDeductions] [decimal](10, 2) NULL,
	[NewBaseSalary] [decimal](10, 2) NULL,
	[NewBonus] [decimal](10, 2) NULL,
	[NewDeductions] [decimal](10, 2) NULL,
	[ChangeDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Salaries] ADD  DEFAULT ((0)) FOR [Bonus]
GO
ALTER TABLE [dbo].[Salaries] ADD  DEFAULT ((0)) FOR [Deductions]
GO
ALTER TABLE [dbo].[SalaryHistory] ADD  DEFAULT (getdate()) FOR [ChangeDate]
GO
ALTER TABLE [dbo].[Employees]  WITH CHECK ADD FOREIGN KEY([DepartmentID])
REFERENCES [dbo].[Departments] ([DepartmentID])
GO
ALTER TABLE [dbo].[Salaries]  WITH CHECK ADD FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employees] ([EmployeeID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SalaryHistory]  WITH CHECK ADD FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employees] ([EmployeeID])
GO
ALTER TABLE [dbo].[Salaries]  WITH CHECK ADD CHECK  (([BaseSalary]>=(0)))
GO
ALTER TABLE [dbo].[Salaries]  WITH CHECK ADD CHECK  (([Bonus]>=(0)))
GO
ALTER TABLE [dbo].[Salaries]  WITH CHECK ADD CHECK  (([Deductions]>=(0)))
GO
/****** Object:  StoredProcedure [dbo].[AddEmployee]    Script Date: 10-02-2025 23:53:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec AddEmployee 'sss',2,'2020-01-01',20000,1000,100
-- =============================================
CREATE PROCEDURE [dbo].[AddEmployee]
    @Name NVARCHAR(100),
    @DepartmentID INT,
    @HireDate DATE,
	@BaseSalary DECIMAL(10,2),
	@Bonus DECIMAL(10,2),
	@Deductions DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @NewEmployeeID INT
    -- Insert the new employee record
    INSERT INTO Employees (Name, DepartmentID, HireDate)
    VALUES (@Name, @DepartmentID, @HireDate);

    -- Return the new EmployeeID
    --SELECT  SCOPE_IDENTITY() AS NewEmployeeID;
	SET @NewEmployeeID = SCOPE_IDENTITY()
	SELECT  @NewEmployeeID AS NewEmployeeID;
	-- Insert salary detailsSCOPE_IDENTITY()of  new employee .
	insert into Salaries(EmployeeID,BaseSalary,Bonus,Deductions)  values (@NewEmployeeID,@BaseSalary,@Bonus,@Deductions)
END;


--select * from Employees
--delete from Employees where EmployeeID = 7
GO
/****** Object:  StoredProcedure [dbo].[CalculateEmployeeSalary]    Script Date: 10-02-2025 23:53:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CalculateEmployeeSalary]
    @EmployeeID INT  -- Employee ID parameter
AS
BEGIN
    SET NOCOUNT ON;

    IF @EmployeeID IS NOT NULL
    BEGIN
        -- Return salary details for a specific employee
        SELECT 
            E.EmployeeID,
            E.Name,
            S.BaseSalary,
            S.Bonus,
            S.Deductions,
            (S.BaseSalary + S.Bonus - S.Deductions) AS NetSalary
        FROM Employees E
        JOIN Salaries S ON E.EmployeeID = S.EmployeeID
        WHERE E.EmployeeID = @EmployeeID;
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[CalculateTotalPayroll]    Script Date: 10-02-2025 23:53:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec CalculateTotalPayroll 1
-- =============================================
CREATE PROCEDURE [dbo].[CalculateTotalPayroll]
    @DepartmentID INT = NULL  -- Optional parameter, NULL means entire organization
AS
BEGIN
    SET NOCOUNT ON;

    -- Calculate total payroll cost (BaseSalary + Bonus - Deductions)
    SELECT SUM(BaseSalary + Bonus - Deductions) AS TotalPayrollCost
    FROM Employees E
    JOIN Salaries S ON E.EmployeeID = S.EmployeeID
    WHERE @DepartmentID IS NULL OR E.DepartmentID = @DepartmentID;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateEmployeeSalary]    Script Date: 10-02-2025 23:53:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEmployeeSalary]
    @EmployeeID INT,
    @NewBaseSalary DECIMAL(10,2),
    @NewBonus DECIMAL(10,2),
    @NewDeductions DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables to store current salary details
    DECLARE @OldBaseSalary DECIMAL(10,2);
    DECLARE @OldBonus DECIMAL(10,2);
    DECLARE @OldDeductions DECIMAL(10,2);

    -- Fetch current salary details before updating
    SELECT 
        @OldBaseSalary = BaseSalary, 
        @OldBonus = Bonus, 
        @OldDeductions = Deductions
    FROM Salaries
    WHERE EmployeeID = @EmployeeID;

    -- If no record found, return an error message
    IF @OldBaseSalary IS NULL
    BEGIN
        PRINT 'Error: Employee salary record not found!';
        RETURN;
    END

    -- Insert old and new values into SalaryHistory
    INSERT INTO SalaryHistory (EmployeeID, OldBaseSalary, OldBonus, OldDeductions, 
                               NewBaseSalary, NewBonus, NewDeductions, ChangeDate)
    VALUES (@EmployeeID, @OldBaseSalary, @OldBonus, @OldDeductions, 
            @NewBaseSalary, @NewBonus, @NewDeductions, GETDATE());

    -- Update salary details in Salaries table
    UPDATE Salaries
    SET BaseSalary = @NewBaseSalary, 
        Bonus = @NewBonus, 
        Deductions = @NewDeductions
    WHERE EmployeeID = @EmployeeID;

    PRINT 'Salary updated successfully and changes logged in SalaryHistory.';
END;
--View For EmployeeSalaryView


CREATE VIEW EmployeeSalaryView AS
SELECT 
    E.EmployeeID,
    E.Name AS EmployeeName,
    D.DepartmentName,
    S.BaseSalary,
    S.Bonus,
    S.Deductions,
    (S.BaseSalary + ISNULL(S.Bonus, 0) - ISNULL(S.Deductions, 0)) AS NetSalary
FROM Employees E
JOIN Departments D ON E.DepartmentID = D.DepartmentID
JOIN Salaries S ON E.EmployeeID = S.EmployeeID;

---View For HighEarnerView

CREATE VIEW HighEarnerView AS
SELECT 
    E.EmployeeID,
    E.Name AS EmployeeName,
    D.DepartmentName,
    S.BaseSalary,
    S.Bonus,
    S.Deductions,
    (S.BaseSalary + ISNULL(S.Bonus, 0) - ISNULL(S.Deductions, 0)) AS NetSalary
FROM Employees E
JOIN Departments D ON E.DepartmentID = D.DepartmentID
JOIN Salaries S ON E.EmployeeID = S.EmployeeID
WHERE (S.BaseSalary + ISNULL(S.Bonus, 0) - ISNULL(S.Deductions, 0)) > 50000;

---Trigger for Salary updates

CREATE TRIGGER trg_LogSalaryUpdate
ON Salaries
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO SalaryHistory (EmployeeID, OldBaseSalary, OldBonus, OldDeductions, 
                               NewBaseSalary, NewBonus, NewDeductions, ChangeDate)
    SELECT 
        i.EmployeeID,
        d.BaseSalary AS OldBaseSalary,
        d.Bonus AS OldBonus,
        d.Deductions AS OldDeductions,
        i.BaseSalary AS NewBaseSalary,
        i.Bonus AS NewBonus,
        i.Deductions AS NewDeductions,
        GETDATE()
    FROM inserted i
    JOIN deleted d ON i.EmployeeID = d.EmployeeID;
END;
-- Index for Employees table to optimize joins
CREATE NONCLUSTERED INDEX IDX_Employees_DepartmentID
ON Employees (DepartmentID);

-- Index for Salaries table to optimize salary lookups
CREATE NONCLUSTERED INDEX IDX_Salaries_EmployeeID
ON Salaries (EmployeeID);

-- Index for SalaryHistory to optimize employee-specific queries
CREATE NONCLUSTERED INDEX IDX_SalaryHistory_EmployeeID
ON SalaryHistory (EmployeeID);

GO
