using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using DbUp;
using DbUp.Helpers;

namespace ScriptsRunner
{
    internal static partial class Program
    {
        private static int Main(string[] args)
        {
            var noWait = false;
            bool.TryParse(ConfigurationManager.AppSettings["AlwaysRun"], out var alwaysRun);
            var env = "--dev";
            var jobPublishName =
                ConfigurationManager.AppSettings["DevJobPublishName"];
            var waitForDelay =
                ConfigurationManager.AppSettings["WaitForDelay"];
            var connectionString =
                ConfigurationManager.ConnectionStrings["DevConnectionString"].ConnectionString;
            var scriptsPath =
                ConfigurationManager.AppSettings["ScriptsPath"];

            Arguments(args, ref noWait, ref alwaysRun, ref jobPublishName, ref env,ref connectionString);

            var exitCode = 0;

            try
            {
                WriteToConsole("Scripts Runner. " +
                               $"Version={typeof(Program).Assembly.GetName().Version}");

                var baseNamespace = typeof(Program).Namespace;
                var baseEnvironmentsNamespace = typeof(Program).Namespace;

                // You can use IConfiguration (Microsoft.Extensions.Configuration) to 
                // achieve the same thing in a .NET Core project as shown here 
                // https://stackoverflow.com/questions/38114761/asp-net-core-configuration-for-net-core-console-application

                WriteToConsole("\nListing command line args...\n");
                var variables = new Dictionary<string, string>();
                variables.Add("JobPublishName", jobPublishName);
                variables.Add("WaitForDelay", waitForDelay);
                // See how to use variables in your scripts: 
                // https://dbup.readthedocs.io/en/latest/more-info/variable-substitution/

                foreach (var item in args) WriteToConsole($"Command line arg = {item}");

                WriteToConsole("\nListing Config settings...\n");
                WriteToConsole($"Env Name = {env.Replace("-","")}");
                WriteToConsole($"Job Publish Name = {jobPublishName}");
                WriteToConsole($"Wait For Delay = {waitForDelay}");

                var builder = new SqlConnectionStringBuilder(connectionString) {Password = "********"};
                WriteToConsole($"{"ConnectionString"} = \"{builder}\"");

                WriteToConsole($"Scripts directory = {scriptsPath}");

                if (!noWait)
                {
                    Console.Write("\nPress return to run scripts...");
                    Console.ReadLine();
                }

                // Pre deployments
                //WriteToConsole("Start executing predeployment scripts...");
                //string preDeploymentScriptsPath = baseNamespace + ".PreDeployment";
                //RunMigrations(connectionString.ConnectionString,
                //    preDeploymentScriptsPath, variables, true);

                //if (!string.IsNullOrWhiteSpace(additionalPreDeploymentNamespace))
                //{
                //    RunMigrations(connectionString.ConnectionString,
                //        additionalPreDeploymentNamespace, variables, true);
                //}

                //// Migrations
                //WriteToConsole("Start executing migration scripts...");
                //var migrationScriptsPath = baseNamespace + ".Migrations";
                //RunMigrations(connectionString.ConnectionString,
                //    migrationScriptsPath, variables, false);

                // Code
                WriteToConsole("Start executing code scripts...");

                RunMigrationsFromFileSystem(connectionString,
                    scriptsPath, variables, alwaysRun);

                ////Post deployments
                //WriteToConsole("Start executing postdeployment scripts...");
                //string postdeploymentScriptsPath = baseNamespace + ".PostDeployment";
                //RunMigrationsFromFileSystem(connectionString.ConnectionString,
                //    postdeploymentScriptsPath, variables, true);

                //if (!string.IsNullOrWhiteSpace(additionalPostDeploymentNamespace))
                //{
                //    RunMigrations(connectionString.ConnectionString,
                //        additionalPostDeploymentNamespace, variables, true);
                //}
            }
            catch (Exception e)
            {
                WriteToConsole(e.Message, ConsoleColor.Red);

                exitCode = -1;
            }

            if (!noWait)
            {
                Console.Write("Press return key to exit...");
                Console.ResetColor();
                Console.ReadKey();
            }

            return exitCode;
        }

        private static void Arguments(string[] args, ref bool noWait, ref bool alwaysRun, ref string jobPublishName,
            ref string env, ref string connectionString)
        {
            foreach (var item in args)
                switch (item.ToLower())
                {
                    case "--nowait":
                        noWait = true;
                        break;
                    case "--alwaysrun":
                        alwaysRun = true;
                        break;
                    case "--runonce":
                        alwaysRun = false;
                        break;
                    case "--dev":
                        env = "--dev";
                        jobPublishName =
                            ConfigurationManager.AppSettings["DevJobPublishName"];
                        connectionString =
                            ConfigurationManager.ConnectionStrings["DevConnectionString"].ConnectionString;
                        break;
                    case "--test":
                        env = "--test";
                        jobPublishName =
                            ConfigurationManager.AppSettings["TestJobPublishName"];
                        connectionString =
                            ConfigurationManager.ConnectionStrings["TestConnectionString"].ConnectionString;
                        break;
                    case "--preprod":
                        env = "--preprod";
                        jobPublishName =
                            ConfigurationManager.AppSettings["PreProdJobPublishName"];
                        connectionString =
                            ConfigurationManager.ConnectionStrings["PreProdConnectionString"].ConnectionString;
                        break;
                    default:
                        break;
                }
            
        }

        private static void ShowSuccess()
        {
            WriteToConsole("Success!");
        }

        private static void WriteToConsole(string msg,
            ConsoleColor color = ConsoleColor.Green)
        {
            Console.ForegroundColor = color;
            Console.WriteLine(msg);
            Console.ResetColor();
        }
    }
}