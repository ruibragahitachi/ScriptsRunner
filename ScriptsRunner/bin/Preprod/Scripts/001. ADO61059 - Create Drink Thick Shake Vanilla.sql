/* 
					?? HAS THIS BEEN RUN ON PRE PROD YET ??
					
 ???   ???      H  H  AA   SSS      TTTTTT H  H III  SSS      BBBB  EEEE EEEE N   N               
?   ? ?   ?     H  H A  A S           TT   H  H  I  S         B   B E    E    NN  N               
   ?     ?      HHHH AAAA  SSS        TT   HHHH  I   SSS      BBBB  EEE  EEE  N N N               
  ?     ?       H  H A  A     S       TT   H  H  I      S     B   B E    E    N  NN               
  ?     ?       H  H A  A SSSS        TT   H  H III SSSS      BBBB  EEEE EEEE N   N               
                                                                                                  
                                                                                                  
RRRR  U   U N   N      OOO  N   N     PPPP  RRRR  EEEE     PPPP  RRRR   OOO  DDD       ???   ???  
R   R U   U NN  N     O   O NN  N     P   P R   R E        P   P R   R O   O D  D     ?   ? ?   ? 
RRRR  U   U N N N     O   O N N N     PPPP  RRRR  EEE      PPPP  RRRR  O   O D  D        ?     ?  
R R   U   U N  NN     O   O N  NN     P     R R   E        P     R R   O   O D  D       ?     ?   
R  RR  UUU  N   N      OOO  N   N     P     R  RR EEEE     P     R  RR  OOO  DDD        ?     ?   
					?? HAS THIS BEEN RUN ON PRE PROD YET ??
*/
/*
	*** File name ***
	ADO61059 - Create Drink Thick Shake Vanilla
	*** Description ***
	Add New Drink Thick Shake Vanilla
	
	*** Variables and their uses ***
	@CommitChanges:				Rollback or Commit changes (0-rollback;1-commit) 
	@debug:						0 – off; 1-basic; 2-detailed
	
	*** PLEASE NOTE *** 
		
	*** History ***
	Version		ModifiedBy			Modified Date		Description
	1.0			Hugo Zacarias		2021-07-08			Initial Version	
*/
USE eCommMgr
GO
SET NOCOUNT ON
	
BEGIN TRY
	BEGIN TRAN 	
	
	--------------------------------------------------------------------------------------------------------------------------------------
	
	/* 
		SET VARIABLES:
		- Fill the variables with the new product data
		- Set price to null if the product is not mandatory and insert data only in temporary tables used 
	*/
	
	DECLARE @CommitChanges BIT 					= 1
	DECLARE @Debug BIT 							= 1
	
	DECLARE @FixedProductId INT					= 1688 -- Next Product ID available (it was requested that it needs to be fixed going forward)
		
	DECLARE @MenuCode VARCHAR(50)				= 'TSVAN3'
	DECLARE @Name VARCHAR(50) 					= 'Thick Shake Vanilla' 
	DECLARE @Description VARCHAR(300)			= 'Ice cold Vanilla flavoured Thickshake made from  deliciously smooth ice cream. Serves 1 -  371kcals / serving' 
	DECLARE @ImageURL VARCHAR(50)				= '2107-DRI-Thick-Shake-Vanilla.jpeg'
	DECLARE @DisplayOrder INT 					= 999
	DECLARE @ProductType CHAR(1) 				= 1  -- Standard        SELECT * FROM tProductType 	
	DECLARE @ProductCategoryID INT 				= 83 --  Drinks	        SELECT * FROM tProductCategory
	DECLARE @CampaignEditorCategoryID INT 		= 8	 --  Drinks         SELECT * FROM tCampaignEditorCategory  
	
	DECLARE @IsCurrent BIT						= 1
	DECLARE @IsVisible BIT						= 1	
	
	DECLARE @IsVegetarian BIT					= 0
	DECLARE @IsHot BIT							= 0
	DECLARE @IsGlutenFree BIT					= 0	
	DECLARE @IsDiscountable BIT					= 0
	DECLARE @IsHalfAndHalf BIT					= 0
	DECLARE @IsAlcoholic BIT					= 0
			
	DECLARE @RecAddUserName VARCHAR(50) 		= SUSER_NAME()
	DECLARE @AppId INT 							= -1
	DECLARE @RowCount INT 						= 0		
	DECLARE @LoopId INT 						= 1

	DECLARE @POSCode VARCHAR(8)					= '320ML'
	DECLARE @ProductSkuDescription VARCHAR(50)	= '320ml'
	DECLARE @SideDisplayOrder INT				= 1
	DECLARE @SizeId INT							= (SELECT UnvSizeId FROM tUnvSize WHERE POSCode COLLATE Latin1_General_CS_AS = @POSCode)

	DECLARE @UKTaxBand INT						= 101	-- UK Non-Taxable
	DECLARE @ROITaxBand INT						= 105	-- ROI Non-Prepared - Tax Rate
	
	
	
	-- temporary tables		
	DECLARE @Sizes TABLE (	Id INT IDENTITY(1,1),
							ProductSkuId INT, 
							SizeId INT,	
							MenuCode VARCHAR(50), 
							DisplayOrder INT, 
							ProductSkuDescription VARCHAR(50))

	DECLARE @TaxBands TABLE (	Id INT IDENTITY(1,1), 
								TaxBandId INT)

	-- SELECT * from tUnvSize
	INSERT INTO @Sizes (SizeId, MenuCode, DisplayOrder, ProductSkuDescription)	
	SELECT @SizeId, @MenuCode, @SideDisplayOrder, @ProductSkuDescription		 
	
	-- SELECT * FROM tTaxBand
	INSERT INTO @TaxBands (TaxBandId)
	VALUES (@UKTaxBand), (@ROITaxBand)
	
	
	--------------------------------------------------------------------------------------------------------------------------------------
	
	/* VERIFY IF PRODUCT EXIST */
	
	IF EXISTS(SELECT * FROM tProductSku WHERE MenuCode COLLATE Latin1_General_CI_AS = @MenuCode)
	BEGIN
		RAISERROR('The MenuCodes already exists', 16, 1, '')
	END
	
	IF NOT EXISTS(SELECT * FROM tUnvSize WHERE UnvSizeId = @SizeId)
	BEGIN
		RAISERROR('There is no Size in the tUnvSize table with the following description: %s', 16, 1, @ProductSkuDescription)
	END

	--------------------------------------------------------------------------------------------------------------------------------------
	
	/* DECLARE VARIABLES USED TO CREATE PRODUCT */
	
	DECLARE @ProductId int, 
			@ProductSkuId int,
			@TaxBandId int		
	
	--------------------------------------------------------------------------------------------------------------------------------------
	/* CREATE PRODUCT */
	
	SELECT 'Create product'	
	EXEC 
		@ProductId = pProduct_Add 
		@ProductId = @FixedProductId,
		@Name = @Name,
		@Description = @Description,
		@ImageURL = @ImageURL,
		@IsHot = @IsHot,
		@IsVegetarian = @IsVegetarian,
		@IsHalfAndHalf = @IsHalfAndHalf,
		@ProductCategoryID = @ProductCategoryID,
		@IsCurrent = @IsCurrent,
		@ProductType = @ProductType,
		@IsAlcoholic = @IsAlcoholic,
		@CampaignEditorCategoryID = @CampaignEditorCategoryID,
		@Username = @RecAddUserName,
		@AppId = @AppId,
		@DisplayOrder = @DisplayOrder,
		@DebugPrint = @Debug
		
	-- Update remaining product flags	
	UPDATE tProduct  
	SET 
		IsGlutenFree = @IsGlutenFree, 
		IsVisible = @IsVisible, 
		IsDiscountable = @IsDiscountable
	WHERE Name = @Name
	--------------------------------------------------------------------------------------------------------------------------------------
	
	/* CREATE PRODUCT SKUS */
		
	SELECT 'Create Skus'
			
	EXEC 
		@ProductSkuId = pProductSku_Add
		@Description = @ProductSkuDescription,
		@DisplayOrder = @SideDisplayOrder,
		@MenuCode = @MenuCode, 
		@FormalDescription = NULL,
		@UnvSizeId = @SizeId,
		@ProductId = @ProductId,
		@SubEPOSCrustCode = NULL,
		@UserName = @RecAddUserName,
		@AppID = @AppId,
		@DebugPrint = @debug
	
	--------------------------------------------------------------------------------------------------------------------------------------
	
	/* CREATE TAX BANDS */
	
	SET @RowCount = (SELECT COUNT(Id) FROM @TaxBands)
	SET @LoopId = 1
	
	SELECT 'Tax bands'
	
	WHILE (@LoopId <= @RowCount)
	BEGIN
		SELECT  @TaxBandId = TaxBandId
		FROM    @TaxBands
		WHERE	Id = @LoopId
		
		EXEC pProduct_TaxBand_Add
			@ProductId = @ProductId,
			@TaxBandId = @TaxBandId,
			@UserName = @RecAddUserName,
			@AppID = @AppId,
			@DebugPrint = @debug
		
		SET @LoopId = @LoopId + 1
	END
	
	--------------------------------------------------------------------------------------------------------------------------------------
		
	/* ROLLBACK/COMMIT */
	
	IF @CommitChanges = 0
	BEGIN
		ROLLBACK TRAN 
		SELECT ' ======== Rolled back ======== '
	END
	ELSE
	BEGIN
		COMMIT TRAN
		SELECT ' ======== Commited ======== '
	END
END TRY
--------------------------------------------------------------------------------------------------------------------------------------
/* START ERROR HANDLING */
BEGIN CATCH
	IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRAN
		print ' ======== Rolled back ======== '
	END
	DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT;  
  
    SELECT   
        @ErrorMessage = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(), 
        @ErrorState = ERROR_STATE()
  
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
--------------------------------------------------------------------------------------------------------------------------------------
	
/* SANITY CHECK TRAN COUNT */
SELECT @@trancount 'Transaction Count'