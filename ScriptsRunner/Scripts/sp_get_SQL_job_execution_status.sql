create procedure [dbo].[sp_get_SQL_job_execution_status]
(
    @job_name sysname
, @select_data int =0
, @execution_status int =null output

)
as

    set nocount on


    /*
        Is the execution status for the jobs. 
        Value Description 
        0 Returns only those jobs that are not idle or suspended.  
        1 Executing. 
        2 Waiting for thread. 
        3 Between retries. 
        4 Idle. 
        5 Suspended. 
        7 Performing completion actions 

    */

declare	@job_id UNIQUEIDENTIFIER
, @is_sysadmin INT
, @job_owner   sysname

select @job_id = job_id from msdb..sysjobs_view where name = @job_name
select @is_sysadmin = ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0)
select @job_owner = SUSER_SNAME()

DECLARE  @xp_results TABLE (job_id                UNIQUEIDENTIFIER NOT NULL,
                            last_run_date         INT              NOT NULL,
                            last_run_time         INT              NOT NULL,
                            next_run_date         INT              NOT NULL,
                            next_run_time         INT              NOT NULL,
                            next_run_schedule_id  INT              NOT NULL,
                            requested_to_run      INT              NOT NULL, -- BOOL
                            request_source        INT              NOT NULL,
                            request_source_id     sysname          COLLATE database_default NULL,
                            running               INT              NOT NULL, -- BOOL
                            current_step          INT              NOT NULL,
                            current_retry_attempt INT              NOT NULL,
                            job_state             INT              NOT NULL)


    IF ((@@microsoftversion / 0x01000000) >= 8) -- SQL Server 8.0 or greater
        INSERT INTO @xp_results
            EXECUTE master.dbo.xp_sqlagent_enum_jobs @is_sysadmin, @job_owner, @job_id
    ELSE
        INSERT INTO @xp_results
            EXECUTE master.dbo.xp_sqlagent_enum_jobs @is_sysadmin, @job_owner


    --declare @execution_status int
    set @execution_status = (select job_state from @xp_results)

    if @select_data =1
        select @job_name as 'job_name', @execution_status as 'execution_status'

    set nocount off
GO

