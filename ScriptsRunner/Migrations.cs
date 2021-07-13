using System;
using System.Collections.Generic;
using DbUp;
using DbUp.Helpers;

namespace ScriptsRunner
{
    internal static partial class Program
    {
        private static int RunMigrationsFromFileSystem(string connectionString,
            string @namespace,
            Dictionary<string, string> variables,
            bool alwaysRun = false)
        {
            WriteToConsole($"Executing scripts in {@namespace}");

            var builder = DeployChanges.To
                .SqlDatabase(connectionString)
                .WithScriptsFromFileSystem(@namespace)
                .WithVariables(variables)
                .WithVariablesEnabled()
                .LogScriptOutput()
                .LogToConsole();

            builder = alwaysRun
                ? builder.JournalTo(new NullJournal())
                : builder.JournalToSqlTable("dbo", "DatabaseMigrations");

            var executor = builder.Build();
            var result = executor.PerformUpgrade();

            if (!result.Successful) throw new Exception(result.Error.ToString());

            ShowSuccess();
            return 0;
        }
    }
}