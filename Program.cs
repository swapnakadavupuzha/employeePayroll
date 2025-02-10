using System;

using System.Collections.Generic;

using System.Data.SqlClient;

// Base Employee class

class BaseEmployee

{

    public string Name { get; set; }

    public int ID { get; set; }

    public double BasicPay { get; set; }

    public double Allowances { get; set; }

    public virtual double CalculateSalary()

    {

        return BasicPay + Allowances;

    }

    public virtual void DisplayInfo()

    {

        Console.WriteLine($"ID: {ID}, Name: {Name}, Salary: {CalculateSalary()}");

    }

}

// Derived classes

class Manager : BaseEmployee

{

    public double Bonus { get; set; }

    public override double CalculateSalary()

    {

        return base.CalculateSalary() + Bonus;

    }

}

class Developer : BaseEmployee

{

    public double PerformanceBonus { get; set; }

    public override double CalculateSalary()

    {

        return base.CalculateSalary() + PerformanceBonus;

    }

}

class Intern : BaseEmployee

{

    public double Stipend { get; set; }

    public override double CalculateSalary()

    {

        return Stipend;

    }

}

class PayrollSystem

{

    static string connectionString = "Data Source=REFL-LP167\\SQLEXPRESS2019;Initial Catalog=EmployeePayroll;Integrated Security=False;Persist Security Info=False;User ID=sa;Password=P@ssw0rd;MultipleActiveResultSets=True";

    static List<BaseEmployee> employees = new List<BaseEmployee>();

    static void Main()

    {

        LoadEmployeesFromDatabase();

        while (true)

        {

            Console.WriteLine("\nEmployee Payroll System");

            Console.WriteLine("1. Add Employee\n2. Display Employees\n3. Calculate Total Payroll\n4. Exit");

            int choice = int.Parse(Console.ReadLine());

            switch (choice)

            {
                case 1: AddEmployee(); break;

                case 2: DisplayEmployees(); break;

                case 3: CalculateTotalPayroll(); break;

                case 4: return;

            }

        }

    }

    static void LoadEmployeesFromDatabase()

    {

        using (var conn = new SqlConnection(connectionString))

        {

            conn.Open();

            string query = "SELECT e.EmployeeID, e.Name, s.BaseSalary, s.Bonus, s.Deductions FROM Employees e JOIN Salaries s ON e.EmployeeID = s.EmployeeID";

            using (SqlCommand cmd = new SqlCommand(query, conn))

            {

                using (SqlDataReader reader = cmd.ExecuteReader())

                {

                    while (reader.Read())

                    {

                        employees.Add(new BaseEmployee

                        {

                            ID = reader.GetInt32(0),

                            Name = reader.GetString(1),

                            BasicPay = (double) reader.GetDecimal(2),

                            Allowances = (double)reader.GetDecimal(3) - (double)reader.GetDecimal(4) // Allowances = Bonus - Deductions

                        });

                    }

                }

            }

        }

    }

    static void AddEmployee()
    {
        Console.Write("Enter Employee Name: ");
        string name = Console.ReadLine();
        Console.Write("Enter Department ID: ");
        if (!int.TryParse(Console.ReadLine(), out int departmentId))
        {
            Console.WriteLine("Invalid Department ID.");
            return;
        }
        Console.Write("Enter HireDate: ");
        if (!DateTime.TryParse(Console.ReadLine(), out DateTime hireDate))
        {
            Console.WriteLine("Invalid Date.");
            return;
        }
        Console.Write("Enter Base Salary: ");
        if (!decimal.TryParse(Console.ReadLine(), out decimal baseSalary))
        {
            Console.WriteLine("Invalid Salary Amount.");
            return;
        }
        Console.Write("Enter Bonus: ");
        if (!decimal.TryParse(Console.ReadLine(), out decimal bonus))
        {
            Console.WriteLine("Invalid Bonus Amount.");
            return;
        }
        Console.Write("Enter Deductions: ");
        if (!decimal.TryParse(Console.ReadLine(), out decimal deductions))
        {
            Console.WriteLine("Invalid Deductions Amount.");
            return;
        }

        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            conn.Open();
            string query = "EXEC AddEmployee @Name, @DepartmentID, @HireDate,@BaseSalary,@Bonus,@Deductions";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@Name", name);
                cmd.Parameters.AddWithValue("@DepartmentID", departmentId);
                cmd.Parameters.AddWithValue("@HireDate",hireDate);
                cmd.Parameters.AddWithValue("@BaseSalary", baseSalary);
                cmd.Parameters.AddWithValue("@Bonus", bonus);
                cmd.Parameters.AddWithValue("@Deductions", deductions);

                int rowsAffected = cmd.ExecuteNonQuery();                
            }
        }
    }

    static void DisplayEmployees()

    {

        Console.WriteLine("\nEmployee List:");

        foreach (var emp in employees)

        {

            emp.DisplayInfo();

        }

    }

    static void CalculateTotalPayroll()

    {

        double totalPayroll = 0;
        Console.WriteLine("1. Enter Employee Id");

        if (!int.TryParse(Console.ReadLine(), out int employeeId))
        {
            Console.WriteLine("Invalid Employee ID. Please enter a valid number.");
            return;
        }

        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            conn.Open();
            string query = "EXEC CalculateEmployeeSalary @EmployeeID";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@EmployeeID", employeeId);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())  // Check if data exists
                    {
                        int empId = reader.GetInt32(0);
                        string empName = reader.GetString(1);
                        decimal baseSalary = reader.GetDecimal(2);
                        decimal bonus = reader.GetDecimal(3);
                        decimal deductions = reader.GetDecimal(4);
                        decimal netSalary = reader.GetDecimal(5);

                        Console.WriteLine("\nEmployee Salary Details:");
                        Console.WriteLine($"ID: {empId}");
                        Console.WriteLine($"Name: {empName}");
                        Console.WriteLine($"Base Salary: {baseSalary}");
                        Console.WriteLine($"Bonus: {bonus:C}");
                        Console.WriteLine($"Deductions: {deductions:C}");
                        Console.WriteLine($"Net Salary: {netSalary:C}");
                    }
                    else
                    {
                        Console.WriteLine("No employee found with the given ID.");
                    }
                }
            }
        }


    }

}

