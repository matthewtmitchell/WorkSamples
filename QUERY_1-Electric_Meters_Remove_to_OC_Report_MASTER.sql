-- Pull data for meters that have been removed from service for required meter testing.
WITH Meter_Removal (SerialNumber, AssetID, ValidFrom, Material, Manufacturer, ModelNumber, AssetStatusID, RemovalDate, ShopStatus)
     AS (SELECT PMAD.UtilitySerialNumber AS SerialNumber,
                PMAD.AssetID,
				MAX(PMAD.ValidFromTS) AS ValidFrom,
                PMAD.AssetModelCode AS Material,
				PMAD.ManufacturerName AS Manufacturer,
				PMAD.ModelNumber,
				PMAD.AssetStatusID,
				MAX(PMAD.AssetStatusDate) AS RemovalDate,
				PMAD.ShopStatus
         FROM [Asset].[dbo].[PowerMeterAssetDetail] AS PMAD
         JOIN [Asset].[dbo].[SummaryToDetailLocations] AS SDL ON (SDL.AssetLocation = PMAD.[Location])
         LEFT JOIN [Asset].[dbo].[PowerMeterTestResults] AS PMTR ON (PMTR.UtilitySerialNumber = PMAD.UtilitySerialNumber AND PMTR.StepNumber = 1 AND PMTR.TestDateStart > PMAD.AssetStatusDate)
         JOIN [Asset].[dbo].[Asset] AS A ON (A.AssetID = PMAD.AssetID)
         WHERE 1 = 1
           AND NOT PMAD.PurgeIndicator = 'Y'
		   -- Do NOT included meters that have been retired from service.
           AND NOT EXISTS (SELECT DISTINCT UtilitySerialNumber
                           FROM [Asset].[dbo].[PowerMeterAssetDetail]
                           WHERE PowerMeterAssetDetail.UtilitySerialNumber = PMTR.UtilitySerialNumber
                             AND ShopStatus LIKE 'Retire%')
           AND PMAD.AssetStatusID = 'Removed'
           AND PMAD.ShopStatus = 'Removed'
         GROUP BY PMAD.UtilitySerialNumber, PMAD.AssetID, PMAD.AssetModelCode, PMAD.ManufacturerName, PMAD.ModelNumber, PMAD.AssetStatusID, PMAD.ShopStatus),

-- Pull data for meters that have been removed from service for required meter testing and have been received at the Operations Center.
Received_at_OC (SerialNumber, AssetID, ValidFrom, Material, Manufacturer, ModelNumber, ShortLocation, SummaryLocation, AssetStatusID, ShopStatus)
     AS (SELECT PMAD.UtilitySerialNumber AS SerialNumber,
                PMAD.AssetID,
				MIN(PMAD.ValidFromTS) AS ValidFrom,
				PMAD.AssetModelCode AS Material,
				PMAD.ManufacturerName AS Manufacturer,
				PMAD.ModelNumber,
				PMAD.[Location],
				SDL.SummaryLocation,
				PMAD.AssetStatusID,
				PMAD.ShopStatus
         FROM [Asset].[dbo].[PowerMeterAssetDetail] AS PMAD
         JOIN [Asset].[dbo].[SummaryToDetailLocations] AS SDL ON (SDL.AssetLocation = PMAD.[Location])
         LEFT JOIN [Asset].[dbo].[PowerMeterTestResults] AS PMTR ON (PMTR.UtilitySerialNumber = PMAD.UtilitySerialNumber AND PMTR.StepNumber = 1 AND PMTR.TestDateStart > PMAD.AssetStatusDate)
         JOIN [Asset].[dbo].[Asset] AS A ON(A.AssetID = PMAD.AssetID)
         WHERE 1 = 1
           AND NOT PMAD.PurgeIndicator = 'Y'
		   -- Do NOT included meters that have been retired from service.
           AND NOT EXISTS (SELECT DISTINCT UtilitySerialNumber
                           FROM [Asset].[dbo].[PowerMeterAssetDetail]
                           WHERE PowerMeterAssetDetail.UtilitySerialNumber = PMTR.UtilitySerialNumber
                             AND ShopStatus LIKE 'Retire%')
           AND PMAD.AssetStatusID = 'Removed'
           AND PMAD.ShopStatus = 'Received at OC'
         GROUP BY PMAD.UtilitySerialNumber, PMAD.AssetID, PMAD.AssetModelCode, PMAD.ManufacturerName, PMAD.ModelNumber, PMAD.[Location], SDL.SummaryLocation, PMAD.AssetStatusID, PMAD.ShopStatus),

-- Pull data for meters that have been removed from service for required meter testing and have been received at the meter shop.
Received_at_Shop (SerialNumber, AssetID, ValidFrom, Material, Manufacturer, ModelNumber, ShortLocation, SummaryLocation, AssetStatusID, ShopStatus)
     AS (SELECT PMAD.UtilitySerialNumber AS SerialNumber,
				PMAD.AssetID,
				MAX(PMAD.ValidFromTS) AS ValidFrom,
				PMAD.AssetModelCode AS Material,
				PMAD.ManufacturerName AS Manufacturer,
				PMAD.ModelNumber,
				PMAD.[Location],
				SDL.SummaryLocation,
				PMAD.AssetStatusID,
				PMAD.ShopStatus
	     FROM [Asset].[dbo].[PowerMeterAssetDetail] AS PMAD
		 JOIN [Asset].[dbo].[SummaryToDetailLocations] AS SDL ON (SDL.AssetLocation = PMAD.[Location])
		 LEFT JOIN [Asset].[dbo].[PowerMeterTestResults] AS PMTR ON (PMTR.UtilitySerialNumber = PMAD.UtilitySerialNumber AND PMTR.StepNumber = 1 AND PMTR.TestDateStart > PMAD.AssetStatusDate)
		 JOIN [Asset].[dbo].[Asset] AS A ON(A.AssetID = PMAD.AssetID)
		 WHERE 1 = 1
            AND NOT PMAD.PurgeIndicator = 'Y'
			-- Do NOT included meters that have been retired from service.
            AND NOT EXISTS (SELECT DISTINCT UtilitySerialNumber
						    FROM [Asset].[dbo].[PowerMeterAssetDetail]
							WHERE PowerMeterAssetDetail.UtilitySerialNumber = PMTR.UtilitySerialNumber
							  AND ShopStatus LIKE 'Retire%')
			AND PMAD.[Location] LIKE '%Cleaning'
			AND PMAD.AssetStatusID = 'Removed'
			AND PMAD.ShopStatus = 'Received at Shop'
		 GROUP BY PMAD.UtilitySerialNumber, PMAD.AssetID, PMAD.AssetModelCode, PMAD.ManufacturerName, PMAD.ModelNumber, PMAD.[Location], SDL.SummaryLocation, PMAD.AssetStatusID, PMAD.ShopStatus),

-- Pull data for meters that have been removed from service for required meter testing and have been pulled from a pallet for testing.
Received_for_Testing (SerialNumber, AssetID, ValidFrom, Material, Manufacturer, ModelNumber, ShortLocation, SummaryLocation, AssetStatusID, AssetStatusDate, ShopStatus, TestDate)
     AS (SELECT PMAD.UtilitySerialNumber AS SerialNumber,
				PMAD.AssetID,
				MAX(PMAD.ValidFromTS) AS ValidFrom,
				PMAD.AssetModelCode AS Material,
				PMAD.ManufacturerName AS Manufacturer,
				PMAD.ModelNumber,
				PMAD.[Location],
				SDL.SummaryLocation,
				PMAD.AssetStatusID,
				MAX(PMAD.AssetStatusDate) AS StatusDate,
				PMAD.ShopStatus,
				MAX(PMTR.TestDateStart) AS TestDate
		 FROM [Asset].[dbo].[PowerMeterAssetDetail] AS PMAD
		 JOIN [Asset].[dbo].[SummaryToDetailLocations] AS SDL ON (SDL.AssetLocation = PMAD.[Location])
		 LEFT JOIN [Asset].[dbo].[PowerMeterTestResults] AS PMTR ON (PMTR.UtilitySerialNumber = PMAD.UtilitySerialNumber AND PMTR.StepNumber = 1 AND PMTR.TestDateStart > PMAD.AssetStatusDate)
		 JOIN [Asset].[dbo].[Asset] AS A ON(A.AssetID = PMAD.AssetID)
		 WHERE 1 = 1
		   AND NOT PMAD.PurgeIndicator = 'Y'
		   -- Do NOT included meters that have been retired from service.
		   AND NOT EXISTS (SELECT DISTINCT UtilitySerialNumber
						   FROM [Asset].[dbo].[PowerMeterAssetDetail]
						   WHERE PowerMeterAssetDetail.UtilitySerialNumber = PMTR.UtilitySerialNumber
							 AND ShopStatus LIKE 'Retire%')
           AND PMAD.AssetStatusID = 'Removed'
           AND PMAD.ShopStatus = 'Received at Cleaning'
		 GROUP BY PMAD.UtilitySerialNumber, PMAD.AssetID, PMAD.AssetModelCode, PMAD.ManufacturerName, PMAD.ModelNumber, PMAD.[Location], SDL.SummaryLocation, PMAD.AssetStatusID, PMAD.ShopStatus)

-- Show meters that have been removed from service for required meter testing and show their length of time in each stage from removal to testing.
SELECT DISTINCT MR.SerialNumber,
				MR.AssetID,
				MR.Material,
				MR.Manufacturer,
				MR.ModelNumber,
				MR.RemovalDate,
				RAO.ValidFrom AS ReceivedAtOC,
				RAO.SummaryLocation AS OCLocation,
				DATEDIFF(DAY, MR.RemovalDate, RAO.ValidFrom) AS RemoveToOCDaysOutstanding,
				RAS.ValidFrom AS ReceivedAtShop,
				RAS.SummaryLocation AS ShopLocation,
				DATEDIFF(DAY, RAO.ValidFrom, RAS.ValidFrom) AS OCToShopDaysOutstanding,
				RFT.TestDate AS MeterTestDate,
				DATEDIFF(DAY, RAS.ValidFrom, RFT.TestDate) AS ShopToTestDaysOutstanding
FROM Meter_Removal AS MR
LEFT JOIN Received_at_OC AS RAO ON (RAO.SerialNumber = MR.SerialNumber)
LEFT JOIN Received_at_Shop AS RAS ON (RAS.SerialNumber = MR.SerialNumber)
LEFT JOIN Received_for_Testing AS RFT ON (RFT.SerialNumber = MR.SerialNumber)
WHERE 1 = 1
  AND DATEDIFF(DAY, MR.RemovalDate, RAO.ValidFrom) >= 0
  AND DATEDIFF(DAY, RAO.ValidFrom, RAS.ValidFrom) >= 0
  AND DATEDIFF(DAY, RAS.ValidFrom, RFT.TestDate) >= 0
ORDER BY DATEDIFF(DAY, MR.RemovalDate, RAO.ValidFrom) DESC;