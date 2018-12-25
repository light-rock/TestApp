
/* 
   The database administrator shall create TestAPP database 
   and/or update the following line to reference the database in 
   which these tables are to exist 
   
   THIS PROCESS IS DESTRUCTIVE
   --------------------------------------------------------------
*/
use TestAPP;
GO

SET NOCOUNT ON
GO

/* Clean out previous versions */
DROP TABLE IF EXISTS [dbo].[person];
GO

DROP TABLE IF EXISTS [dbo].[states];
GO

DROP PROCEDURE IF EXISTS [dbo].[appendState];
GO  

DROP PROCEDURE IF EXISTS [dbo].[uspPersonUpsert];
GO

DROP PROCEDURE IF EXISTS [dbo].[uspPersonSearch];
GO

DROP PROCEDURE IF EXISTS [dbo].[uspStatesList];
GO


/* CREATE TABLES */
CREATE TABLE states (
    state_id int IDENTITY(1,1) PRIMARY KEY,
    state_code char(2) NOT NULL
);
GO

CREATE TABLE person (
    person_id int IDENTITY(1,1) PRIMARY KEY,
    first_name varchar(50),
    last_name varchar(50),
	state_id int,
	gender char(1),
	dob datetime,
    CONSTRAINT FK_state_id FOREIGN KEY (state_id)     
    REFERENCES dbo.states (state_id)  
);
GO


/* CREATE STORED PROCEDURES */

/* 
   Append one state 
   Out of scope at this time
*/
CREATE PROCEDURE dbo.appendState @statecode char(2)
AS   
   insert into [dbo].[states] ([state_code]) values (@statecode)
GO  

/*
  Get all states, ordered by state_code 'AZ', etc.,
*/
CREATE PROCEDURE dbo.uspStatesList 
AS
  select * from states order by state_code
GO

/*
  Search for a person, in all fields using a single parameter
*/
CREATE PROCEDURE dbo.uspPersonSearch @search varchar(50)
AS
  SELECT 
    person_id, 
	first_name, 
	last_name, 
	gender, 
	person.state_id,
	states.state_code 
  FROM [dbo].[person] 
  INNER JOIN states on states.state_id = person.state_id
  WHERE first_name like @search or last_name like @search or gender like @search or dob like @search or states.state_code like @search
GO

/*
   Append/Update a person record 
   Try to prevent locking issues, race conditions
*/
CREATE PROCEDURE dbo.uspPersonUpsert @personid int, @firstname varchar(50), @lastname varchar(50), @stateid int, @gender char(1), @dob datetime
AS   

SET NOCOUNT, XACT_ABORT ON

BEGIN TRAN
  IF EXISTS(SELECT * FROM dbo.person WITH (UPDLOCK, HOLDLOCK) WHERE person_id = @personid)
  BEGIN
	UPDATE dbo.person
	  SET first_name = @firstname, last_name = @lastname, state_id = @stateid, gender = @gender, dob = @dob
	  WHERE person_id = @personid
  END
  ELSE
  BEGIN
    INSERT INTO [dbo].[person] ([first_name],[last_name],[state_id],[gender],[dob])
      VALUES(@firstname, @lastname, @stateid, @gender, @dob);
  END
COMMIT

RETURN @@ERROR
GO  

/* CREATE TEST DATA */
/* and exercise the stored procedures */

/* Pre-populate the states table */
execute [dbo].[appendState] @statecode = 'AL'
execute [dbo].[appendState] @statecode = 'AK'
execute [dbo].[appendState] @statecode = 'AZ'
execute [dbo].[appendState] @statecode = 'AR'
execute [dbo].[appendState] @statecode = 'CA'
execute [dbo].[appendState] @statecode = 'CO'
execute [dbo].[appendState] @statecode = 'CT'
execute [dbo].[appendState] @statecode = 'DE'
execute [dbo].[appendState] @statecode = 'DC'
execute [dbo].[appendState] @statecode = 'FL'
execute [dbo].[appendState] @statecode = 'GA'
execute [dbo].[appendState] @statecode = 'HI'
execute [dbo].[appendState] @statecode = 'ID'
execute [dbo].[appendState] @statecode = 'IL'
execute [dbo].[appendState] @statecode = 'IN'
execute [dbo].[appendState] @statecode = 'IA'
execute [dbo].[appendState] @statecode = 'KS'
execute [dbo].[appendState] @statecode = 'KY'
execute [dbo].[appendState] @statecode = 'LA'
execute [dbo].[appendState] @statecode = 'ME'
execute [dbo].[appendState] @statecode = 'MD'
execute [dbo].[appendState] @statecode = 'MA'
execute [dbo].[appendState] @statecode = 'MI'
execute [dbo].[appendState] @statecode = 'MN'
execute [dbo].[appendState] @statecode = 'MS'
execute [dbo].[appendState] @statecode = 'MO'
execute [dbo].[appendState] @statecode = 'MT'
execute [dbo].[appendState] @statecode = 'NE'
execute [dbo].[appendState] @statecode = 'NV'
execute [dbo].[appendState] @statecode = 'NH'
execute [dbo].[appendState] @statecode = 'NJ'
execute [dbo].[appendState] @statecode = 'NM'
execute [dbo].[appendState] @statecode = 'NY'
execute [dbo].[appendState] @statecode = 'NC'
execute [dbo].[appendState] @statecode = 'ND'
execute [dbo].[appendState] @statecode = 'OH'
execute [dbo].[appendState] @statecode = 'OK'
execute [dbo].[appendState] @statecode = 'OR'
execute [dbo].[appendState] @statecode = 'PA'
execute [dbo].[appendState] @statecode = 'PR'
execute [dbo].[appendState] @statecode = 'RI'
execute [dbo].[appendState] @statecode = 'SC'
execute [dbo].[appendState] @statecode = 'SD'
execute [dbo].[appendState] @statecode = 'TN'
execute [dbo].[appendState] @statecode = 'TX'
execute [dbo].[appendState] @statecode = 'UT'
execute [dbo].[appendState] @statecode = 'VT'
execute [dbo].[appendState] @statecode = 'VA'
execute [dbo].[appendState] @statecode = 'WA'
execute [dbo].[appendState] @statecode = 'WV'
execute [dbo].[appendState] @statecode = 'WI'
execute [dbo].[appendState] @statecode = 'WY'
GO

/* populate person table with test data */
execute [dbo].[uspPersonUpsert] 0, @firstname = 'TestPerson1', @lastname = 'TestLastname1', @stateid = 1, @gender = 'M', @dob ='12/24/2018'
execute [dbo].[uspPersonUpsert] 0, @firstname = 'TestPerson2', @lastname = 'TestLastname2', @stateid = 1, @gender = 'F', @dob ='12/24/2018'
execute [dbo].[uspPersonUpsert] 0, @firstname = 'TestPerson3', @lastname = 'TestLastname3', @stateid = 1, @gender = 'M', @dob ='12/24/2018'
execute [dbo].[uspPersonUpsert] 0, @firstname = 'TestPerson4', @lastname = 'TestLastname4', @stateid = 2, @gender = 'F', @dob ='12/24/2018'
execute [dbo].[uspPersonUpsert] 0, @firstname = 'TestPerson5', @lastname = 'TestLastname5', @stateid = 3, @gender = 'M', @dob ='12/24/2018'
execute [dbo].[uspPersonUpsert] 0, @firstname = 'TestPerson6', @lastname = 'TestLastname6', @stateid = 4, @gender = 'F', @dob ='12/24/2018'
execute [dbo].[uspPersonUpsert] 0, @firstname = 'TestPerson7', @lastname = 'TestLastname7', @stateid = 5, @gender = 'M', @dob ='12/24/2018'
execute [dbo].[uspPersonUpsert] 0, @firstname = 'TestPerson8', @lastname = 'TestLastname8', @stateid = 6, @gender = 'F', @dob ='12/24/2018'
execute [dbo].[uspPersonUpsert] 0, @firstname = 'TestPerson9', @lastname = 'TestLastname9', @stateid = 7, @gender = 'M', @dob ='12/24/2018'
execute [dbo].[uspPersonUpsert] 0, @firstname = '01234567890123456789012345678901234567890123456789', @lastname = '01234567890123456789012345678901234567890123456789', @stateid = 1, @gender = 'M', @dob ='12/24/2018'
GO

/* validate that the upsert method for person table works */
execute [dbo].[uspPersonUpsert] 1, @firstname = 'Newsomebody', @lastname = 'Someone', @stateid = 7, @gender = 'F', @dob = '1/1/2019'
GO

/* Count 52 states including PR and DC or investigate what went wrong */
select count(*) from states;

/* Count 10 persons */
select count(*) from person;

/* Check the procedure that lists all the states */
exec uspStatesList;

/* Find the updated person 'Newsomebody' */
exec uspPersonSearch 'New%';

/* Find customer(s) located in AL */
exec uspPersonSearch 'AL';