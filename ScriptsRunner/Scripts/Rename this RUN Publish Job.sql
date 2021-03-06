declare @execution_status int
declare @job_name varchar(50)

set @execution_status=0
set @job_name = N'$JobPublishName$'

EXEC msdb.dbo.sp_start_job @job_name;

WHILE @execution_status not in (4,5)
BEGIN
    WAITFOR DELAY '$WaitForDelay$';
	IF OBJECT_ID('sp_get_SQL_job_execution_status', 'P') IS NOT NULL
        BEGIN
            EXEC	[dbo].[sp_get_SQL_job_execution_status]
                    @job_name = @job_name,
                    @execution_status = @execution_status OUTPUT
        END
    ELSE
        BEGIN
             BREAK
        END
END
    IF  (@execution_status=4)
        BEGIN
            select 'Job '''+ @job_name +''' finished successfully'
        END