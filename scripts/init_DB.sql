-- Switched to the DWH database.
-- Created Bronze, Silver, and Gold schemas to organize the data warehouse layers.

--- creat DWh
USE master;
GO

USE DWH;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO  

