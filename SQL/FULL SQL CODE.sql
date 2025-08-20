
            --DATA EXPLORATION

/*
The following SQL exploration is based on the Uber dataset from Kaggle.  
It is intended to demonstrate an exploratory mindset for preparing data before analysis.  
Please note: these scripts may not run directly on the ride-hailing database due to data splitting, merging, and transformation steps applied during preprocessing.
*/


UPDATE [dbo].[UberDataset]
SET [START]= 'Karachi'
WHERE [START] = 'Kar?chi';

UPDATE [dbo].[UberDataset]
SET [STOP] = 'Karachi'
WHERE [STOP] = 'Kar?chi';

SELECT [START_DATE], [END_DATE]
FROM [dbo].[UberDataset]
WHERE [PURPOSE] IS NULL
ORDER BY [START_DATE] desc

SELECT DISTINCT [PURPOSE] FROM [dbo].[UberDataset]

    -- UNIT CONVERSIONS

SELECT [START_DATE]
,[END_DATE]
,[CATEGORY]
,[START]
,[STOP]
,[MILES]/10 as MILES
,[PURPOSE]
FROM [dbo].[UberDataset]
WHERE [START]=[STOP]

SELECT * FROM [dbo].[UberDataset]

UPDATE [dbo].[UberDataset]
SET [MILES] = [MILES]/10

SELECT *,DATEDIFF(MINUTE, [START_DATE], [END_DATE]) AS 'WAIT'
FROM [dbo].[UberDataset]
ORDER BY WAIT

-- FIND "WAIT TIME" BY DISTANCE
SELECT [START_DATE]
, [END_DATE]
,[CATEGORY]
,[MILES]
,DATEDIFF(MINUTE, [START_DATE], [END_DATE]) AS 'WAIT TIME (MINUTES)'
FROM [dbo].[UberDataset] 
ORDER BY [START_DATE]

-- FIND PEAK HOURS

WITH TIME_CTE
AS (
    SELECT [START_DATE]
    ,[END_DATE]
    ,[CATEGORY]
    ,[MILES]
    ,DATEDIFF(MINUTE, [START_DATE], [END_DATE]) *60  AS 'WAIT'
    FROM [dbo].[UberDataset] 
)
SELECT 
FORMAT([START_DATE], 'HH:mm') as 'hour', WAIT
FROM TIME_CTE 
ORDER BY hour

-- FILTER VIRTUAL TRANSACTIONS
EXEC sp_rename '[dbo].[UberDataset].[MILES]', 'KILOMETERS', 'COLUMN'
WITH TIME_CTE
AS (
    SELECT [START_DATE]
    ,[END_DATE]
    ,[CATEGORY]
    ,[START]
    ,[STOP]
    ,KILOMETERS
    ,DATEDIFF(MINUTE, [START_DATE], [END_DATE])*60  AS 'SECOND'
    FROM [dbo].[UberDataset] 
)
SELECT*
,[KILOMETERS]*3.6*1000/ NULLIF(DATEDIFF(MINUTE, [START_DATE], [END_DATE])*60, 0) AS 'SPEED (km/h)'
FROM TIME_CTE 
ORDER BY 'SPEED (km/h)'DESC

UPDATE [dbo].[UberDataset]
SET [MILES] = [MILES]*1.60934 

ALTER TABLE[dbo].[UberDataset] ADD TIME_SECOND INT
UPDATE [dbo].[UberDataset] 
SET TIME_SECOND = DATEDIFF(MINUTE, [START_DATE], [END_DATE])*60

ALTER TABLE [dbo].[UberDataset] ADD  SPEED_Km_h FLOAT
UPDATE [dbo].[UberDataset]  
SET [SPEED_Km_h] = [KILOMETERS]*3.6*1000/ NULLIF(DATEDIFF(MINUTE, [START_DATE], [END_DATE])*60, 0)

-- SPEED OVER 100KM/H AND DISTANCE LOWER THAN 100KM
SELECT *
FROM [dbo].[UberDataset]
WHERE [SPEED_Km_h] >100 AND [KILOMETERS] <100
ORDER BY SPEED_Km_h DESC 


-- WAITING TIME TOO SHORT (LESS THAN 4 MINUTES)  WITH HIGH SPEED (OVER 85 KM/H)

SELECT * 
FROM [dbo].[UberDataset]
WHERE  (TIME_SECOND <= 240 and [SPEED_Km_h] > 85) or SPEED_Km_h is null 
ORDER BY SPEED_Km_h desc


            -- AFTER FILTERING VIRTUAL TRANSACTIONS

--TABLE DATA CLEANED
SELECT * 
FROM [dbo].[UberDataset]
WHERE NOT (((TIME_SECOND <= 240 and [SPEED_Km_h] > 85) or SPEED_Km_h is null) OR (([SPEED_Km_h] >100 AND [KILOMETERS] <100)OR [SPEED_Km_h]>100))
ORDER BY [SPEED_Km_h]ASC


                    --ANALYTICS

        --TABLE 1: TRIP DISTRIBUTION
--COMPARE INZONE_TRIP AND OUTZONE_TRIP

        WITH INZONE AS (
            SELECT [START], [STATE_START], COUNT([START]) AS INZONE_TRIP
            FROM [dbo].[FULL_DATA]
            WHERE [START] = [STOP]
                AND [START] <> 'Unknown Location'
                AND[STOP] <>'Unknown Location'
                AND [STATE_START] IS NOT NULL
                AND [NATION_START] = 'USA'
                AND [NATION_STOP] = 'USA'
                AND [SPEED_Km_h] < 120
            GROUP BY [START], [STATE_START]
        ),
        OUTZONE AS (
            SELECT [START], [STATE_START], COUNT([START]) AS OUT_ZONE_TRIP
            FROM [dbo].[FULL_DATA]
            WHERE [START] <> [STOP]
                AND [START] <> 'Unknown Location'
                AND[STOP] <>'Unknown Location'
                AND [STATE_START] IS NOT NULL
                AND [NATION_START] = 'USA'
                AND [NATION_STOP] = 'USA'
                AND [SPEED_Km_h] < 120
            GROUP BY [START], [STATE_START]
        )
        SELECT DISTINCT
            COALESCE(I.[START], O.[START]) AS [START],
            COALESCE(O.[STATE_START], I.[STATE_START]) AS [STATE_START],
            ISNULL(I.[INZONE_TRIP], 0) AS INZONE_TRIP,
            ISNULL(O.[OUT_ZONE_TRIP], 0) AS OUT_ZONE_TRIP,
            ISNULL(I.[INZONE_TRIP], 0) + ISNULL(O.[OUT_ZONE_TRIP], 0) AS TOTAL_TRIP
        FROM INZONE I
        FULL OUTER JOIN OUTZONE O ON I.[START] = O.[START] AND I.[STATE_START] = O.[STATE_START]
        ORDER BY TOTAL_TRIP DESC;


        --TABLE 2: TIME BOOKING TREND

    WITH TIME_SLOT_DATA AS (
        SELECT 
            RIGHT('0' + CAST(DATEPART(HOUR, START_DATE) AS VARCHAR), 2) + ':00-' +
            RIGHT('0' + CAST((DATEPART(HOUR, START_DATE) + 1) % 24 AS VARCHAR), 2) + ':00' AS TIME_SLOT,
            ISNULL([STATE_START], 'OTHER') AS STATE
        FROM [dbo].[FULL_DATA] DT
            WHERE [START] <> 'Unknown Location' 
                AND [STOP] <>'Unknown Location'
                AND [STATE_START] IS NOT NULL 
                AND [NATION_START] = 'USA'
                AND [NATION_STOP] = 'USA'
                AND [SPEED_Km_h]< 120
    )
    SELECT 
        STATE,
        TIME_SLOT,
        COUNT(*) AS TOTAL_BOOK
    FROM TIME_SLOT_DATA
    GROUP BY 
        STATE,
        TIME_SLOT
    ORDER BY 
        CASE 
            WHEN STATE = 'OTHER' THEN 'ZZZ' 
            ELSE STATE 
        END,
        TIME_SLOT;


        --TABLE 3 PURPOSE & DISTANCE

-- ANALYSE TRIP PURPOSE BY DISTANCE

    WITH DISTANCE_SLOT_DATA AS (
        SELECT 
            CASE 
                WHEN DT.DISTANCE >= 0 AND DT.DISTANCE < 5 THEN '00-05'
                WHEN DT.DISTANCE >= 5 AND DT.DISTANCE < 20 THEN '05-20'
                WHEN DT.DISTANCE >= 20 AND DT.DISTANCE < 50 THEN '20-50'
                WHEN DT.DISTANCE >= 50 AND DT.DISTANCE < 70 THEN '50-70'
                ELSE '70+ km'
            END AS DISTANCE_Km,
            ISNULL([STATE_START], 'OTHER') AS STATE,
            ISNULL(DT.PURPOSE,'Unknown') AS 'PURPOSE'
        FROM [dbo].[FULL_DATA] DT
            WHERE [START] <> 'Unknown Location' 
            AND [STATE_START] IS NOT NULL 
            AND [NATION_START] = 'USA'
            AND [NATION_STOP] = 'USA'
            AND [SPEED_Km_h]< 120
    )
    SELECT 
        STATE,
        DISTANCE_Km,
        PURPOSE,
        COUNT(*) AS TOTAL_BOOK
    FROM DISTANCE_SLOT_DATA
    GROUP BY 
        STATE,
        DISTANCE_Km
        ,PURPOSE
    ORDER BY 
        STATE, 
        DISTANCE_Km;

        --TABLE 4 TRIP_MATRIX

-- TRIPS BETWEEN STATES AND CITIES
    WITH START_LOC AS (
        SELECT 
            [START],
            [STATE_START],
            [STOP],   
            [STATE_STOP],
            [PURPOSE], 
            [DISTANCE]
        FROM [dbo].[FULL_DATA]
        WHERE [START] <> 'Unknown Location' 
                AND [STATE_START] IS NOT NULL 
                AND [NATION_START] = 'USA'
                AND [NATION_STOP] = 'USA'
                AND [SPEED_Km_h]< 120
            )
    SELECT 
        [START],
        [STATE_START],
        [STOP],   
        [STATE_STOP], 
        ISNULL([PURPOSE],'Unknown') AS 'PURPOSE' ,
        COUNT(*) AS TOTAL_BOOK
    FROM START_LOC 
    GROUP BY 
        [START],
        [STATE_START],
        [STOP],   
        [STATE_STOP],
        ISNULL([PURPOSE],'Unknown') 
    ORDER BY 1

        -- TABLE 5 TRAFFIC JAMS

-- NUMBER OF TRIPS WITH SLOW SPEED, MAY BE TRAFFIC JAMS
-- INDENTIFY PEAK HOURS OF STATES

    SELECT 
        [STATE_START]
        ,RIGHT('0' + CAST(DATEPART(HOUR, [START_DATE]) AS VARCHAR), 2) + ':00-' + RIGHT('0' + CAST((DATEPART(HOUR, [START_DATE]) + 1) % 24 AS VARCHAR), 2) + ':00' AS TIME_RANGE
        ,[STATE_STOP]
        ,COUNT(*) AS TOTAL_BOOK
    FROM [dbo].[FULL_DATA]
    WHERE [START] <> 'Unknown Location' 
        AND [STATE_START] IS NOT NULL 
        AND [NATION_START] = 'USA'
        AND [NATION_STOP] = 'USA' 
        AND [SPEED_Km_h]< 120
        AND (CAST([SPEED_Km_h] AS FLOAT) < 20 )
    GROUP BY 
        [STATE_START]
        ,RIGHT('0' + CAST(DATEPART(HOUR, [START_DATE]) AS VARCHAR), 2) + ':00-' + RIGHT('0' + CAST((DATEPART(HOUR, [START_DATE]) + 1) % 24 AS VARCHAR), 2) + ':00'
        ,[STATE_STOP]
    ORDER BY 1,2 ;


        --TABLE 6 SUPPLY AND DEMAND

-- INDENTIFY BOOKING TENDENCY AND MARKET SHARE OF BOOKING
-- DEMONSTRATE CITIES HAS EXHAUSTED ITS GROWTH POTENTIAL
-- LOOKING FOR OTHER POTENTIAL CITIES 


    WITH START_LOC AS (
        SELECT 
            DT.[START],
            DT.[STATE_START],
            DT.[STOP],
            DT.[STATE_STOP],
            DT.[PURPOSE], 
            DT.[DISTANCE]
        FROM [dbo].[FULL_DATA] DT
        WHERE [START] <> 'Unknown Location' 
            AND [STATE_START] IS NOT NULL 
            AND [NATION_START] = 'USA'
            AND [NATION_STOP] = 'USA'
            AND [SPEED_Km_h]< 120
    )
    SELECT 
        UD.[State] AS STATE_START,
        COUNT(ST.STATE_START) AS TOTAL_BOOK,
        UD.[Population_2016],
        UD.[Total_Area_km] as'Total_Area_km_Square',
        UD.[Total_GDP_M],
        UD.[GDP per Capita],
        UD.[Population Density]    
    FROM [dbo].[US_STATE] UD
    LEFT JOIN START_LOC ST 
        ON UD.[State] = ST.[STATE_START]
    GROUP BY 
        UD.[State],
        UD.[Population_2016],
        UD.[Total_Area_km],
        UD.[Total_GDP_M],
        UD.[GDP per Capita],
        UD.[Population Density]
    ORDER BY 2 DESC;

