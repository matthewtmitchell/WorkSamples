-- Developed by: Matt Mitchell
-- Date: 09/11/2017
-- Note: The purpose of this query is to parse the PrintSpecifications string in
--       order to determine the number of print jobs printed in a single trip to
--       the printer.
   
USE [BusinessProcessMgmt_SB]
GO

-- Create a temp table for the print specification data contained in the PrintSpecifications string.
CREATE TABLE #TempPrintSpecs (EID VARCHAR (255), PID VARCHAR(255), PDT DATETIME, SubSpecs VARCHAR(255))
-- CREATE TABLE #TempPrintSpecs2 (ID2 VARCHAR(255), PDT2 DATETIME, SubSpecs2 VARCHAR(255))

-- Insert data into the temp table.
INSERT INTO #TempPrintSpecs (EID, PID, PDT, SubSpecs)
SELECT EmployeeNumber,
       DeviceID, 
       PrintDateTime, 
       PrintSpecifications
FROM XEROX_UTILIZATION AS XU
CROSS APPLY STRING_SPLIT(XU.PrintSpecifications, ';') AS SPL
WHERE LEN(PrintSpecifications) > 25;

/*
INSERT INTO #TempPrintSpecs2 (ID2, PDT2, SubSpecs2)
SELECT ID,
       PDT,
	   SubSpecs
FROM #TempPrintSpecs AS TPS
CROSS APPLY STRING_SPLIT(TPS.SubSpecs, ';') AS SPL2;
*/

-- Select the parse PrintSpecifications string data to be used for analysis.
SELECT *
FROM #TempPrintSpecs
ORDER BY PDT, PID, EID

-- Drop the temp table.
DROP TABLE #TempPrintSpecs
-- DROP TABLE #TempPrintSpecs2