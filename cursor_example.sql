-- Example of how to use a cursor to iterate through a result set.

CREATE PROCEDURE [dbo].[cursorExample]

AS
BEGIN

	SET NOCOUNT ON;

	-- vars from select
	DECLARE 
	@userID VARCHAR(10),
	@role   VARCHAR(50);

	-- select result set
	DECLARE cursor_user CURSOR
	FOR SELECT [userID], [Role]
	FROM [dbo].[testUserTBL];

	OPEN cursor_user;

	FETCH NEXT FROM cursor_user INTO 
		@userID, 
		@role;

	WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Do stuff here
			PRINT @userID + @role;

			-- Next Row
			FETCH NEXT FROM cursor_user INTO 
				@userID, 
				@role;
		END;

	CLOSE cursor_user;

DEALLOCATE cursor_user;
END
