USE Parking
GO
-----------
----P4-----
-----------
--Create table from RAW data, filter hours--
SELECT CAST((DATEADD(S, rpi_time, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time') AS DATE) AS [Date] /*Converts RPI time to readable EST time and casts to numeric date*/
	  ,CAST((DATEADD(S, rpi_time, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time') AS TIME) AS [Time] /*Converts RPI time to readable EST time and casts to time of day*/
	  ,DATENAME(dw, (DATEADD(S, rpi_time, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time')) AS [Weekday] /*Converts RPI time to readable EST time and casts to day of week*/
      ,[obj_class] AS [Class]
      ,[obj_id] AS [ID]
      ,CAST([obj_age] as int) AS [Age]
      ,CAST([xmin] as int) AS [xMin]
      ,CAST([ymin] as int) AS [yMin]
      ,CAST([xmax] as int) AS [xMax]
      ,CAST([ymax] as int) AS [yMax]
INTO P4_WRK /*Destination table*/
FROM P4_RAW
WHERE obj_class = 'car' AND CAST((DATEADD(S, rpi_time, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time') AS TIME) >= '08:30:00' AND CAST((DATEADD(S, rpi_time, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time') AS TIME) <= '22:30:00';


--Converts to working table--
SELECT [Date], MIN([Time]) as StartTime, [Weekday], ID, Max(AGE) as MaxAge
INTO P4_WRK_A
FROM P4_WRK
GROUP BY ID, [Weekday], [Date]
ORDER BY [Date], ID, StartTime;

--Gets start and end positions of x-y--
SELECT DISTINCT [Date], ID,
       CAST(FIRST_VALUE(xMin) OVER (PARTITION BY DATE, ID ORDER BY Age) as int) as xstart,
       CAST(FIRST_VALUE(xMin) OVER (PARTITION BY DATE, ID ORDER BY Age desc) as int) as xend,
	   CAST(FIRST_VALUE(yMin) OVER (PARTITION BY DATE, ID ORDER BY Age) as int) as ystart,
       CAST(FIRST_VALUE(yMin) OVER (PARTITION BY DATE, ID ORDER BY Age desc) as int) as yend
INTO P4_WRK_B
FROM P4_WRK;

--JOIN WRK A&B, ADD DIRECTION VALUE--
SELECT   [P4_WRK_A].[Date]
		,[P4_WRK_A].StartTime
		,[P4_WRK_A].[Weekday]
		,[P4_WRK_A].ID
			,CASE WHEN [P4_WRK_B].xstart > [P4_WRK_B].xend THEN 'EXIT'
			ELSE 'ENTER' END AS DirectionX /*Use DirectionX for Founder's lot, as vehicles move left to right in frame*/
			,CASE WHEN [P4_WRK_B].ystart < [P4_WRK_B].yend THEN 'EXIT'
			ELSE 'ENTER' END AS DirectionY /*Use DirectionY for P4 lot, as vehicles move up and down in frame*/
		,'P4' as Lot
INTO P4_DRV
FROM P4_WRK_A
LEFT JOIN P4_WRK_B
ON P4_WRK_A.ID = P4_WRK_B.ID AND P4_WRK_A.[Date] = P4_WRK_B.[Date]
WHERE MaxAge > 16; /*Measured in frames. This varies between lots as Founders has a much smaller FOV than P4. FRAMES = SECONDS*4 */



----------
----P20---
----------

--Create table from RAW data, filter hours--
SELECT CAST((DATEADD(S, rpi_time, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time') AS DATE) AS [Date] /*Converts RPI time to readable EST time and casts to numeric date*/
	  ,CAST((DATEADD(S, rpi_time, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time') AS TIME) AS [Time] /*Converts RPI time to readable EST time and casts to time of day*/
	  ,DATENAME(dw, (DATEADD(S, rpi_time, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time')) AS [Weekday] /*Converts RPI time to readable EST time and casts to day of week*/
      ,[obj_class] AS [Class]
      ,[obj_id] AS [ID]
      ,CAST([obj_age] as int) AS [Age]
      ,CAST([xmin] as int) AS [xMin]
      ,CAST([ymin] as int) AS [yMin]
      ,CAST([xmax] as int) AS [xMax]
      ,CAST([ymax] as int) AS [yMax]
INTO P20_WRK /*Destination table*/
FROM P20_RAW
WHERE obj_class = 'car' AND CAST((DATEADD(S, rpi_time, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time') AS TIME) >= '08:30:00' AND CAST((DATEADD(S, rpi_time, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time') AS TIME) <= '22:30:00';


--Converts to working table--
SELECT [Date], MIN([Time]) as StartTime, [Weekday], ID, Max(AGE) as MaxAge
INTO P20_WRK_A
FROM P20_WRK
GROUP BY ID, [Weekday], [Date]
ORDER BY [Date], ID, StartTime;

--Gets start and end positions of x-y--
SELECT DISTINCT [Date], ID,
       CAST(FIRST_VALUE(xMin) OVER (PARTITION BY DATE, ID ORDER BY Age) as int) as xstart,
       CAST(FIRST_VALUE(xMin) OVER (PARTITION BY DATE, ID ORDER BY Age desc) as int) as xend,
	   CAST(FIRST_VALUE(yMin) OVER (PARTITION BY DATE, ID ORDER BY Age) as int) as ystart,
       CAST(FIRST_VALUE(yMin) OVER (PARTITION BY DATE, ID ORDER BY Age desc) as int) as yend
INTO P20_WRK_B
FROM P20_WRK;

--JOIN WRK A&B, ADD DIRECTION VALUE--
SELECT   [P20_WRK_A].[Date]
		,[P20_WRK_A].StartTime
		,[P20_WRK_A].[Weekday]
		,[P20_WRK_A].ID
			,CASE WHEN [P20_WRK_B].xstart > [P20_WRK_B].xend THEN 'EXIT'
			ELSE 'ENTER' END AS DirectionX /*Use DirectionX for Founder's lot, as vehicles move left to right in frame*/
			,CASE WHEN [P20_WRK_B].ystart < [P20_WRK_B].yend THEN 'EXIT'
			ELSE 'ENTER' END AS DirectionY /*Use DirectionY for P20 lot, as vehicles move up and down in frame*/
		,'P20' as Lot
INTO P20_DRV
FROM P20_WRK_A
LEFT JOIN P20_WRK_B
ON P20_WRK_A.ID = P20_WRK_B.ID AND P20_WRK_A.[Date] = P20_WRK_B.[Date]
WHERE MaxAge > 8; /*Measured in frames. This varies between lots as Founders has a much smaller FOV than P20. FRAMES = SECONDS*4 */


-----------
--MASTER---
-----------
--Merge P4 and P20--
SELECT * INTO PARK_WRK FROM P20_DRV;
INSERT INTO PARK_WRK SELECT * FROM P4_DRV;

--Filter Directions
SELECT [Date]
      ,[StartTime]
      ,[Weekday]
      ,[ID]
      ,[Lot]
	  ,CASE WHEN Lot = 'P4' THEN 
DirectionY ELSE DirectionX
END AS Direction INTO PARK_WRK_2 FROM PARK_WRK;

SELECT *, [DateTime] = CAST([Date] as DATETIME) + CAST([StartTime] as DATETIME)
INTO PARK_WRK_3 FROM PARK_WRK_2

SELECT * INTO PARK_DRV FROM PARK_WRK_3