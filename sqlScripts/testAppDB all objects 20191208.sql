USE [master]
GO
/****** Object:  Database [testAppDB]    Script Date: 12/8/2019 5:03:13 PM ******/
CREATE DATABASE [testAppDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'testAppDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\testAppDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'testAppDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\testAppDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [testAppDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [testAppDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [testAppDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [testAppDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [testAppDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [testAppDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [testAppDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [testAppDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [testAppDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [testAppDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [testAppDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [testAppDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [testAppDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [testAppDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [testAppDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [testAppDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [testAppDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [testAppDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [testAppDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [testAppDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [testAppDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [testAppDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [testAppDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [testAppDB] SET RECOVERY FULL 
GO
ALTER DATABASE [testAppDB] SET  MULTI_USER 
GO
ALTER DATABASE [testAppDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [testAppDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [testAppDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [testAppDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [testAppDB] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'testAppDB', N'ON'
GO
ALTER DATABASE [testAppDB] SET QUERY_STORE = OFF
GO
USE [testAppDB]
GO
/****** Object:  User [TestLogin]    Script Date: 12/8/2019 5:03:18 PM ******/
CREATE USER [TestLogin] FOR LOGIN [TestLogin] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [jbaugh]    Script Date: 12/8/2019 5:03:18 PM ******/
CREATE USER [jbaugh] FOR LOGIN [jbaugh] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [jbaugh]
GO
/****** Object:  UserDefinedFunction [dbo].[get_DispatchLocation_ForCoordinates]    Script Date: 12/8/2019 5:03:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[get_DispatchLocation_ForCoordinates]
	(
@Longitude float
, @Latitude float
	)
RETURNS VARCHAR(100)
AS
	BEGIN
		DECLARE 
@DispatchLocationName VARCHAR(100)
,@addressLocation GEOGRAPHY
, @MatchCount INT


SET @addressLocation  = GEOGRAPHY::Point(@Latitude, @Longitude, 4326)

SELECT @matchCount = COUNT(*) FROM Mapping_Polygons WHERE @addressLocation.STWithin(Polygon) = 'True'

IF @MatchCount = 0 
SET @DispatchLocationName = 'None'


IF @MatchCount > 1
SET @DispatchLocationName = 'Multiple Dispatch Locations'

IF @MatchCount = 1
BEGIN

SELECT @DispatchLocationName = e.EntityName + ' / '+ dl.Dispatch_Location_Name
FROM Entity e
	INNER JOIN Dispatch_Location dl
		ON e.entityid = dl.entityid
	INNER JOIN addresses addr
		ON dl.DispatchLocationID = addr.ownerid
	INNER JOIN coordinates co
		ON addr.addressid = co.ownerid

END


RETURN @DispatchLocationName

	END



GO
/****** Object:  UserDefinedFunction [dbo].[udf_TrimLeadChars]    Script Date: 12/8/2019 5:03:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_TrimLeadChars] 
( 
@Input VARCHAR(100), 
@LeadingCharacter CHAR(1) 
)

RETURNS VARCHAR(100)

AS

--select dbo.[udf_TrimLeadChars]('0000123406','0')


BEGIN
    RETURN REPLACE(LTRIM(REPLACE(@Input, ISNULL(@LeadingCharacter, '0'), ' ')), 
                   ' ', ISNULL(@LeadingCharacter, '0'))
END


GO
/****** Object:  UserDefinedFunction [dbo].[UFN_report_Warehouse_Polygon_Coordinates]    Script Date: 12/8/2019 5:03:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[UFN_report_Warehouse_Polygon_Coordinates]
    (
      @Polygon VARCHAR(MAX)
	)
RETURNS @acData TABLE
    (
      RowNum INT	IDENTITY(1,1)
	  --,Longitude VARCHAR(MAX)
	  --, Latitude VARCHAR(MAX)
	  ,Longitude FLOAT
	  , Latitude FLOAT
	  , LongString VARCHAR(MAX)
	  , LatString VARCHAR(MAX)
	  , LongLat VARCHAR(MAX)
    )
AS
    BEGIN
        

    DECLARE @StartIndex INT, @EndIndex INT, @Character VARCHAR(5), @Character2 VARCHAR(5)
	SET @Character = ','
	SET @Character2 = ' '

 SET @Polygon = (REPLACE(@Polygon, ISNULL('POLYGON ((', '0'), ' '))
SET @Polygon = (REPLACE(@Polygon, ISNULL('))', '0'), ' '))


      SET @StartIndex = 1
      IF SUBSTRING(@Polygon, LEN(@Polygon) - 1, LEN(@Polygon)) <> @Character
      BEGIN
            SET @Polygon = @Polygon + @Character
      END
 
      WHILE CHARINDEX(@Character, @Polygon) > 0
      BEGIN
            SET @EndIndex = CHARINDEX(@Character, @Polygon)
           
            INSERT INTO @acData(LongLat)
            SELECT SUBSTRING(@Polygon, @StartIndex, @EndIndex - 1)
           
            SET @Polygon = SUBSTRING(@Polygon, @EndIndex + 1, LEN(@Polygon))
      END

	  BEGIN
	  UPDATE a
	  SET a.LongString = SUBSTRING(dbo.udf_TrimLeadChars(longlat,' '),1, CHARINDEX(@Character2,dbo.udf_TrimLeadChars(longlat, ' '))-1)
	  FROM @acData a

	    UPDATE a
	  SET a.LatString = LTRIM(RIGHT(LongLat,DATALENGTH(dbo.udf_TrimLeadChars(longlat,' ')) - LEN(LongString)))
	  FROM @acData a

	  UPDATE a
	  SET LongString = LEFT(LongString, 10)
	  FROM @acData a

	  UPDATE a
	  SET a.Longitude = CONVERT(FLOAT,LongString)
	  FROM @acData a



	   UPDATE a
	  SET a.LatString = LEFT(LatString, 10)
	  FROM @acData a

	  UPDATE a
	  SET a.Latitude = CONVERT(FLOAT,LatString)
	  FROM @acData a


	  END 
	  RETURN
      
    END;



GO
/****** Object:  Table [dbo].[Addresses]    Script Date: 12/8/2019 5:03:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Addresses](
	[AddressID] [uniqueidentifier] NOT NULL,
	[OwnerID] [uniqueidentifier] NOT NULL,
	[Address1] [nvarchar](100) NULL,
	[Address2] [nvarchar](100) NULL,
	[City] [nvarchar](50) NULL,
	[Region] [nvarchar](50) NULL,
	[Country] [nvarchar](3) NULL,
	[PostalCode] [nvarchar](20) NULL,
	[AddressType] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Coordinates]    Script Date: 12/8/2019 5:03:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Coordinates](
	[CoordinateID] [uniqueidentifier] NOT NULL,
	[Longitude] [float] NULL,
	[Latitude] [float] NULL,
	[OwnerID] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Mapping_Polygons]    Script Date: 12/8/2019 5:03:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Mapping_Polygons](
	[PolygonID] [uniqueidentifier] NOT NULL,
	[Polygon] [geography] NULL,
	[OwnerID] [uniqueidentifier] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dispatch_Location]    Script Date: 12/8/2019 5:03:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dispatch_Location](
	[DispatchLocationID] [uniqueidentifier] NOT NULL,
	[Dispatch_Location_Name] [nvarchar](100) NULL,
	[Dispatch_Location_Type] [nvarchar](100) NULL,
	[Active] [bit] NOT NULL,
	[DefaultRadius] [decimal](18, 4) NULL,
	[EntityID] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 12/8/2019 5:03:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[CustomerID] [uniqueidentifier] NOT NULL,
	[CustomerName] [nvarchar](100) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[Sex] [nvarchar](10) NULL,
	[DOB] [datetime] NULL,
	[EntityID] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Entity]    Script Date: 12/8/2019 5:03:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Entity](
	[EntityID] [uniqueidentifier] NOT NULL,
	[EntityName] [nvarchar](100) NULL,
	[Active] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_GeoMapping]    Script Date: 12/8/2019 5:03:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_GeoMapping]

AS

SELECT e.entityID
, e.entityname
, dl.dispatchlocationid AS ObjectID
, dispatch_location_name AS Description
, defaultradius
--, polygon
, polygonID
, latitude
, longitude
, addr.address1
, addr.address2
, addr.city
, addr.region
, addr.postalcode
, addr.country
, addr.AddressType
, addressid
FROM Entity e
	INNER JOIN Dispatch_Location dl
		ON e.entityid = dl.entityid
	INNER JOIN addresses addr
		ON dl.dispatchlocationid = addr.ownerid
	INNER JOIN coordinates co
		ON addr.addressid = co.ownerid
	LEFT JOIN Mapping_Polygons mp
		ON dl.dispatchlocationid = mp.ownerID
WHERE dl.active = 1


UNION 

SELECT e.entityID
, e.entityname
, dl.CustomerID AS ObjectID
, CustomerName AS Description
, NULL AS defaultradius
--, polygon
, polygonID
, latitude
, longitude
, addr.address1
, addr.address2
, addr.city
, addr.region
, addr.postalcode
, addr.country
, addr.AddressType
, addressid
FROM Entity e
	INNER JOIN Customers dl
		ON e.entityid = dl.entityid
	INNER JOIN addresses addr
		ON dl.customerid = addr.ownerid
	INNER JOIN coordinates co
		ON addr.addressid = co.ownerid
	LEFT JOIN Mapping_Polygons mp
		ON dl.customerID = mp.ownerID
GO
/****** Object:  Table [dbo].[Users]    Script Date: 12/8/2019 5:03:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [uniqueidentifier] NOT NULL,
	[Email] [nvarchar](200) NULL,
	[FName] [nvarchar](100) NULL,
	[LName] [nvarchar](100) NULL,
	[Active] [bit] NOT NULL,
	[PasswordText] [nvarchar](100) NULL,
	[LastLogin] [datetime] NULL,
	[SuperUser] [bit] NOT NULL,
	[EntityID] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Addresses] ADD  DEFAULT (newid()) FOR [AddressID]
GO
ALTER TABLE [dbo].[Coordinates] ADD  DEFAULT (newid()) FOR [CoordinateID]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT (newid()) FOR [CustomerID]
GO
ALTER TABLE [dbo].[Dispatch_Location] ADD  DEFAULT (newid()) FOR [DispatchLocationID]
GO
ALTER TABLE [dbo].[Dispatch_Location] ADD  DEFAULT ((0)) FOR [Active]
GO
ALTER TABLE [dbo].[Entity] ADD  DEFAULT (newid()) FOR [EntityID]
GO
ALTER TABLE [dbo].[Entity] ADD  DEFAULT ((0)) FOR [Active]
GO
ALTER TABLE [dbo].[Mapping_Polygons] ADD  DEFAULT (newid()) FOR [PolygonID]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (newid()) FOR [UserID]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((0)) FOR [Active]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((0)) FOR [SuperUser]
GO
/****** Object:  StoredProcedure [dbo].[Geomapping_Delete_Polygon]    Script Date: 12/8/2019 5:03:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[Geomapping_Delete_Polygon]
(@DispatchLocationID uniqueidentifier

)

as




delete Mapping_Polygons
where ownerID = @DispatchLocationID

return

GO
/****** Object:  StoredProcedure [dbo].[get_User]    Script Date: 12/8/2019 5:03:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[get_User]
(@UserEmail VARCHAR(100)
)

AS

SELECT Email
, FName
, u.Lname
, u.active
, u.passwordtext
, u.lastlogin
, u.superuser
, u.entityid
FROM users u
WHERE email = @useremail
GO
/****** Object:  StoredProcedure [dbo].[report_Customer_List]    Script Date: 12/8/2019 5:03:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[report_Customer_List]

@userID uniqueidentifier

AS


SELECT e.EntityID
, e.entityName
, c.customerID
, c.CustomerName
, C.FirstName
, c.LastName
, c.Sex
, c.DOB
, co.longitude
, co.latitude
, addr.addressid
, addr.address1
, addr.address2
, addr.city
, addr.region
, addr.country
, addr.postalcode
, addr.addresstype
, [dbo].[get_DispatchLocation_ForCoordinates](co.longitude, co.latitude) AS DispatchLocationForAddress
FROM Entity e
	INNER JOIN customers c
		ON e.entityid = c.entityid
	INNER JOIN addresses addr
		ON c.customerid = addr.ownerid
	INNER JOIN coordinates co
		ON addr.addressid = co.ownerid
GO
/****** Object:  StoredProcedure [dbo].[report_Generic_List_Coordinates_ForGeoMapping]    Script Date: 12/8/2019 5:03:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[report_Generic_List_Coordinates_ForGeoMapping]
@userID				uniqueidentifier,
@IDN		UNIQUEIDENTIFIER			= NULL


as
/*

DECLARE @totalPages INT ,
    @pageRecords INT ,
    @totalRecords INT;
EXEC dbo.[report_Generic_List_Coordinates_ForGeoMapping] @userID = NULL, -- uniqueidentifier
    @lang = 'en', -- nvarchar(50)
    @pageNumber = 1, -- int
    @pageSize = 50, -- int
    @totalPages = @totalPages OUTPUT, -- int
    @pageRecords = @pageRecords OUTPUT, -- int
    @totalRecords = @totalRecords OUTPUT, -- int
    @sortString = NULL, -- varchar(3000)
    @filterString = null,
	@IDN = '05F458AC-6E6F-E23A-4FAA-8E487882B0B2'

*/


--SET @totalPages = 1


DECLARE 
	@polygon VARCHAR(MAX),
	@whseid VARCHAR(255),
	@objecttype varchar(100),
	@ShortDesc varchar(100),
	@Description varchar(100),
	@polygonCenterLat float,
	@polygonCenterLong	FLOAT,
	@objectID UNIQUEIDENTIFIER,
	@totalRecords int
	--, 
	--@IDN UNIQUEIDENTIFIER

	SELECT DISTINCT @polygon = polygon.ToString()
	, @whseid = g.ObjectID
	, @objecttype= g.addresstype
	,@ShortDesc = g.description
	, @Description = g.description
	, @IDN = g.PolygonID
	, @objectID = g.ObjectID
	FROM dbo.vw_GeoMapping g
		INNER JOIN dbo.Mapping_Polygons p
			ON p.PolygonID = g.PolygonID
	WHERE g.PolygonID = @IDN

	PRINT @polygon

IF @polygon IS NULL OR @polygon = ''
RETURN


SELECT @totalRecords= COUNT(*)
FROM [dbo].[UFN_report_Warehouse_Polygon_Coordinates](@polygon)

SET @totalRecords = @totalRecords - 1

SELECT TOP( @totalRecords )RowNum
, Longitude, Latitude, @ObjectID AS WarehouseID
, @whseid AS WhseID, @objecttype as ObjectType
, @ShortDesc as ShortDesc
, @Description as Description
, @polygonCenterLat as polygonCenterLat
, @polygonCenterLong as polygonCenterLong
, @IDN AS GeoIDN
FROM [dbo].[UFN_report_Warehouse_Polygon_Coordinates](@polygon)

SELECT @totalRecords= COUNT(*)
FROM [dbo].[UFN_report_Warehouse_Polygon_Coordinates](@polygon)

--SET @pageRecords = @totalRecords

return

GO
/****** Object:  StoredProcedure [dbo].[report_Generic_ListForGeoMapping]    Script Date: 12/8/2019 5:03:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[report_Generic_ListForGeoMapping]
@userID				UNIQUEIDENTIFIER
--,@lang				nvarchar(50)			= 'en',
--@pageNumber			int						= 1,
--@pageSize			int						= 50,
--@totalPages			int						= 0 OUTPUT,
--@pageRecords		int						= 0 OUTPUT,
--@totalRecords		int						= 0 OUTPUT,
--@sortString			varchar(3000)			= null,
--@filterString		nvarchar(4000)			= NULL


as
/*
DECLARE @totalPages INT ,
    @pageRecords INT ,
    @totalRecords INT;
EXEC dbo.report_Generic_ListForGeoMapping @userID = NULL, -- uniqueidentifier
    @lang = 'en', -- nvarchar(50)
    @pageNumber = 1, -- int
    @pageSize = 50, -- int
    @totalPages = @totalPages OUTPUT, -- int
    @pageRecords = @pageRecords OUTPUT, -- int
    @totalRecords = @totalRecords OUTPUT, -- int
    @sortString = NULL, -- varchar(3000)
    @filterString = '~~~~~~C:::ShortDesc like '%fl-mia%'~~~~~~F:::ObjectType:::WAREHOUSE:::string' -- nvarchar(4000)


*/




--DECLARE 
--	@rowStart		int,
--	@rowEnd			int,
--	@hasSort		bit,
--	@sortField		varchar(255),
--	@sortDirection	varchar(50),
--	@sql nvarchar(3000),
--	@where nvarchar(3000),
--	@where_init nvarchar(3000),
--	@sort nvarchar(3000)

----need a temp table to hold the value (SelectAddressFlag) for later comparison
----now build table to hold the filtered data
--CREATE TABLE #TMP(
--	rowNumber				INT	IDENTITY(1,1)
--	, IDN					uniqueidentifier
--)

----show the warehouses for the addresses linked to this quote
--set @sql = 'select objectid
--FROM vw_GeoMapping
--'
--set @where_init = null


----SET @where = quoter.reporting_build_filter(@where_init, @filterString, null) + '
----'

----SET @sort = quoter.reporting_build_sort(null, @sortString, null) 
----SET @sql = @sql + @where + @sort

--print 'sql: ' + isnull(@sql, 'null')

--INSERT INTO #TMP( IDN)
--EXEC sp_executesql @sql

--EXEC report_process_tmp @pageNumber
--	, @pageSize
--	, @totalPages OUTPUT
--	, @pageRecords OUTPUT
--	, @totalRecords OUTPUT

--now get only the address info
SELECT DISTINCT
 w.dispatch_location_name AS ShortDesc
 , w.dispatch_location_name AS Description
 --, g.ObjectType
	
	, w.address1
	, w.address2
	, w.city
	, w.region
	, w.postalcode
	, w.country
	, w.latitude, w.longitude
	, w.dispatchlocationid
	, w.addressID
	,g.polygon.ToString() AS geographySpan
	, w.AddressType AS ObjectType
	, w.defaultradius AS objectRadius
	, g.PolygonID AS GeoIDN
FROM  vw_GeoMapping w
	--inner join #tmp t
	--	on w.objectid = t.idn
	left JOIN Mapping_Polygons g
		ON w.PolygonID = g.PolygonID




return







GO
/****** Object:  StoredProcedure [dbo].[Update_GeoMapping_Coordinates]    Script Date: 12/8/2019 5:03:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Update_GeoMapping_Coordinates]
(
	@DispatchLocationID					uniqueidentifier		,
	@userID						UNIQUEIDENTIFIER,
	@Polygon						NVARCHAR(max)			= NULL, 
	@PolygonID UNIQUEIDENTIFIER
)
AS
/*
EXEC Update_GeoMapping_Coordinates
'CB811D4C-3C58-4252-8271-30046BD18BC3'
, '1A3FEA98-4BB3-4A82-A827-88D647A551D1'
, '-74.00597379999999 40.71435,-76 40.71435,-76 38,-74.00597379999999 38,'
*/


BEGIN

--RETURN

DECLARE @geoPolygon GEOGRAPHY,
@polylen INT,
@validPolygon BIT,
@FirstPoint VARCHAR(MAX)

SET @FirstPoint = SUBSTRING(dbo.udf_TrimLeadChars(@Polygon,' '),1, CHARINDEX(',',dbo.udf_TrimLeadChars(@Polygon, ' '))-1)

SET @Polygon = @Polygon+@FirstPoint


SET @Polygon = 'POLYGON (('+ @Polygon
SET @Polygon = @Polygon + '))'

PRINT @Polygon

SET @geoPolygon = geography::STPolyFromText(@Polygon,4326)

SET @validPolygon = @geoPolygon.STIsValid()

IF @validPolygon = 1
BEGIN
UPDATE dbo.Mapping_Polygons
SET Polygon = @geoPolygon
WHERE PolygonID = @PolygonID
END


IF @validPolygon = 1 AND NOT EXISTS (SELECT 1 FROM dbo.Mapping_Polygons WHERE PolygonID = @PolygonID) and @PolygonID != '00000000-0000-0000-0000-000000000000'
BEGIN




INSERT INTO Mapping_Polygons
(Polygon, OwnerID, polygonID)
VALUES(@geoPolygon, @DispatchLocationID, @polygonID)

END 
	 
END

GO
USE [master]
GO
ALTER DATABASE [testAppDB] SET  READ_WRITE 
GO
