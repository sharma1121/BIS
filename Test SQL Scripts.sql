CREATE TABLE [dbo].[Call] (
    [id]     BIGINT  NOT NULL IDENTITY(1,1),
    [callid]    BIGINT  NOT NULL,
    [starttime] VARCHAR (100) NOT  NULL,
    [endtime]    VARCHAR (100) NOT  NULL,
    [calledfrom] VARCHAR (100) NULL,
    [calledto]   VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

-- Note : We can also take DateTime Datatype for  DateFields



CREATE TABLE [dbo].[Events]
(
	[Id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
    [name] VARCHAR(15) NOT NULL
)


CREATE TABLE [dbo].[CallProgress]
(
	[id] BIGINT  NOT NULL IDENTITY(1,1),
	[callid] BIGINT NOT NULL, 
    [eventtypeid] INT NOT NULL, 
    [eventime] VARCHAR (100) NOT NULL,  
    CONSTRAINT [FK_CallProgress_Call] FOREIGN KEY ([callid]) REFERENCES [Call]([callid]), 
    CONSTRAINT [FK_CallProgress_Events] FOREIGN KEY ([eventtypeid]) REFERENCES [Events]([id])
)
=============================Storeed Procedures======================================

CREATE PROCEDURE dbo.uspGetSummaryReport @eventStartTime nvarchar(30) = NULL,@eventEndTime nvarchar(30) = NULL
AS
select Convert(varchar(10),cp.eventime,103) as date,
case when cp.eventtypeid in (1,2, 3) then  count (cp.eventtypeid) else 0 end as 'CallRecieved' ,
case when cp.eventtypeid =2 then  count (cp.eventtypeid) else 0 end as 'CallAnswered',
case when cp.eventtypeid in (1, 3) then count (cp.eventtypeid) else 0 end as 'CallMissed',
case when cp.eventtypeid =2 then Convert(VARCHAR(8),DATEADD(SECOND,DATEDIFF(SECOND,c.starttime,c.endtime),0),108) end as TotalTalkTime, /*time in HH:MM:SS*/
case when cp.eventtypeid =2 then CONVERT(VARCHAR(5),DATEADD(SECOND,AVG(DATEDIFF(SECOND,'00:00:00',Convert(VARCHAR(8),DATEADD(SECOND,DATEDIFF(SECOND,c.starttime,c.endtime),0),108))),0),114) end as AverageTalkTime /*time in MM:SS*/
from [dbo].[call] c
join [dbo].[CallProgress] cp on cp.callid=c.callid
join [dbo].[Events] e on e.Id=cp.eventtypeid
where Convert(varchar(10), cp.eventime,103) between Convert(varchar(10),@EventStartTime,103)  and  Convert(varchar(10),@EventEndTime,103) 
group by Convert(varchar(10),cp.eventime,103),cp.eventtypeid,c.starttime,c.endtime
GO

Create PROCEDURE dbo.uspGetMissedCallReport @callId bigint=0 ,@eventStartTime nvarchar(30) = NULL,@eventEndTime nvarchar(30) = NULL
AS
select Convert(varchar(10),cp.eventime,103) as date,
c.calledFrom,
c.calledTo,
case when cp.eventtypeid in (1, 3) then count (cp.eventtypeid) else 0 end as 'CallMissed'
from [dbo].[call] c
join [dbo].[CallProgress] cp on cp.callid=c.callid
join [dbo].[Events] e on e.Id=cp.eventtypeid
where c.callid=@callId and Convert(varchar(10), cp.eventime,103) between Convert(varchar(10),@EventStartTime,103)  and  Convert(varchar(10),@EventEndTime,103) 
group by Convert(varchar(10),cp.eventime,103),c.calledFrom,c.calledTo,cp.eventtypeid
GO



