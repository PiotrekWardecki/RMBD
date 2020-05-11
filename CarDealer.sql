create database CarDealer;

use CarDealer;
go

------MODEL-------------
create table xmlFile
(
Id int identity primary key,
xmlData xml,
LoadDateTime datetime
)


create table carBrand
(
	Id int identity primary key,
	name varchar(100)
);

create table gearbox
(
	Id int identity primary key,
	name varchar(100)
);

create table carEngine
(
	Id int identity primary key,
	capacity varchar(100),
	power int
);

create table carBody
(
	Id int identity primary key,
	type varchar(100),
	doors int,
);

create table car
(
	Id int identity primary key,
	type varchar(100),
	model varchar(100),
	yearOfProduction int,
	mileage varchar(100),
	price varchar(100),
	carBrandId int foreign key references carBrand(Id),
	gearboxId int foreign key references gearbox(Id),
	carEngineId int foreign key references carEngine(Id),
	carBodyId int foreign key references carBody(Id)
);

-----------DANE---------------
insert into carBrand (name) values ('Mercedes-Benz');
insert into carBrand (name) values ('BMW');
insert into carBrand (name) values ('Audi');
insert into carBrand (name) values ('Skoda');

insert into gearbox (name) values ('manualna');
insert into gearbox (name) values ('polautomatyczna');
insert into gearbox (name) values ('automatyczna');

insert into carEngine (capacity, power) values ('1.0', 85);
insert into carEngine (capacity, power) values ('1.2', 120);
insert into carEngine (capacity, power) values ('1.4', 145);
insert into carEngine (capacity, power) values ('1.6', 160);
insert into carEngine (capacity, power) values ('1.8', 180);
insert into carEngine (capacity, power) values ('2.0', 200);
insert into carEngine (capacity, power) values ('2.3', 230);

insert into carBody (doors,  type) values (3,'hatchback');
insert into carBody (doors,  type) values (5,'kombi');
insert into carBody (doors,  type) values (3,'coupe');
insert into carBody (doors,  type) values (5,'sedan');

insert into car (type, Model, yearOfProduction,  mileage, price,carBrandId, gearboxId, carEngineId, carBodyId)
values ('osobowy', 'CLA', 2020,  '0', '200000', 1, 1, 4, 4);
insert into car (type, Model, yearOfProduction,  mileage, price, carBrandId, gearboxId, carEngineId, carBodyId)
values ('osobowy', 'CLS', 2019,  '10000', '250000', 1, 1, 1, 2);
insert into car (type, Model, yearOfProduction,  mileage, price,carBrandId, gearboxId, carEngineId, carBodyId)
values ('osobowy', 'GLS', 2018,  '0', '400000', 1, 3, 5, 2);
insert into car (type, Model, yearOfProduction,  mileage, price, carBrandId, gearboxId, carEngineId, carBodyId)
values ('osobowy', 'F4', 2019,  '0', '130000',  2, 2, 6, 3);
insert into car (type, Model, yearOfProduction, mileage, price,  carBrandId, gearboxId, carEngineId, carBodyId)
values ('osobowy', 'A8', 2015,  '50000', '120000', 3, 3, 4, 4);
insert into car (type, Model, yearOfProduction,  mileage, price, carBrandId, gearboxId, carEngineId, carBodyId)
values ('osobowy', 'E90', 2016,  '100000', '90000', 2, 1, 7, 1);
insert into car (type, Model, yearOfProduction,  mileage, price, carBrandId, gearboxId, carEngineId, carBodyId)
values ('osobowy', 'superb', 2019,  '20000', '140000',  4, 1, 6, 4);
insert into car (type, Model, yearOfProduction, mileage, price, carBrandId, gearboxId, carEngineId, carBodyId)
values ('osobowy', 'octavia', 2017,  '5000', '80000', 4, 1, 1, 3);









--Procedury----------------------------------------------------------------------------------------------------------------------------------------

EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO
-----------------------------------------------------------------------------------------------------------------------------------------------------
--Import XML-----------------------------------------------------------------------------------------------------------------------------------------
create procedure insertXML @xmlPath varchar(1000)
as
begin
	declare @query varchar(1000);
	set @query = 'insert into xmlFile(xmlData, LoadDateTime)
					select convert(xml, BulkColumn) as BulkColumn, getDate() 
					from openrowset(bulk ''' + @xmlPath + ''', SINGLE_BLOB) as data'
	exec (@query)
end
GO

exec insertXML 'C:\xml\CarDealer.xml';
go
------------------------------------------------------------------------------------------------------------------------------------------------------
--wyswietla wszystkie informacje o samochodzie z pliku xml--------------------------------------------------------------------------------------------
create procedure getAllData
as
begin

DECLARE @XML AS XML, @hDoc AS INT

select @XML = xmlData from xmlFile;

exec sp_xml_preparedocument @hDoc OUTPUT, @XML

select  *
from OPENXML(@hDoc, 'CarDealer/cars/car')
with
(
	brand varchar(20) 'brand',
	type varchar(20) 'type',
	model varchar(20) 'model',
	engine varchar(20) 'engine',
	body varchar(20) 'body',
	year [int] 'year',
	mileage int 'mileage',
	gearbox varchar(20) 'gearbox',
	price money 'price'
);

EXEC sp_xml_removedocument @hDoc

end
GO

EXEC getAllData
GO

-------------------------------------------------------------------------------------------------------------------------------------------------
--wyswietla samochod o podanym id----------------------------------------------------------------------------------------------------------------
create procedure getCarsByID @id varchar(100)
as
begin

DECLARE @XML AS XML, @hDoc AS INT

select @XML = xmlData from xmlFile;

exec sp_xml_preparedocument @hDoc OUTPUT, @XML

declare @xmlPath varchar(1000) = 'CarDealer/cars/car[@id =''' + @id + ''']';

select *
from OPENXML(@hDoc, @xmlPath)
with
(
		id int,
	type varchar(20) 'type',
	model varchar(20) 'model',
	year [int] 'year',
	mileage int 'mileage',
	price money 'price',
	brand varchar(20) 'brand',
	gearbox varchar(20) 'gearbox',
	engine varchar(20) 'engine',
	body varchar(20) 'body'
);

EXEC sp_xml_removedocument @hDoc

end;
GO

exec getCarsByID '9';

go

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Pobiera liste samochodow z pliku xml z przebiegiem wiekszym niz 120000 km oraz rokiem produkcji wiekszym niz 2017---------------------------------------------------

create procedure getCarsByMileageAndYear @id int, @year int
as
begin

DECLARE @XML AS XML, @hDoc AS INT

select @XML = xmlData from xmlFile;

exec sp_xml_preparedocument @hDoc OUTPUT, @XML

declare @xmlPath varchar(1000) = 'CarDealer/cars/car[mileage>'+cast(@id as varchar)+'][year>'+cast(@year as varchar)+']';

select *
from OPENXML(@hDoc, @xmlPath)
with
(
	id int,
	type varchar(20) 'type',
	model varchar(20) 'model',
	year [int] 'year',
	mileage int 'mileage',
	price money 'price',
	brand varchar(20) 'brand',
	gearbox varchar(20) 'gearbox',
	engine varchar(20) 'engine',
	body varchar(20) 'body'
);

EXEC sp_xml_removedocument @hDoc

end;
GO

exec getCarsByMileageAndYear 120000,2017;
go
------------------------------------------------------------------------------------------------------------------------------------------------
--Importuje plik xml i rozdziela go na wiele wierszy--------------------------------------------------------------------------------------------

create procedure importXmlToSeveralRows @path varchar(1000)
as
begin

IF OBJECT_ID ('tempdb..#temp') is not null
drop table #temp;

create table #temp
(
	xmlData xml
);

declare @query varchar(1000);
	set @query = 'insert into #temp(xmlData)
					select convert(xml, BulkColumn) as BulkColumn
					from openrowset(bulk ''' + @path + ''', SINGLE_BLOB) as data'
	exec (@query)

insert into xmlFile(xmlData, LoadDateTime)
select x.query('.'), getDate()
from xmlFile t
cross apply t.xmlData.nodes('/CarDealer/cars/car') a(x)

drop table #temp;

select * from xmlFile;
end;
GO

exec importXmlToSeveralRows 'C:\xml\CarDealer.xml';
go

----------------------------------------------------------------------------------------------------------------------------------------------
-- Insertuje marki z xml do tabeli carBrand---------------------------------------------------------------------------------------------------

create procedure insertBrandFromXMLt
as
begin
 DECLARE @XML AS XML, @hDoc AS INT

select top 1 @XML = xmlData from xmlFile;

exec sp_xml_preparedocument @hDoc OUTPUT, @XML

INSERT INTO carBrand
SELECT 
	 *
FROM
OPENXML(@hDoc, '/CarDealer/brands/brand')
WITH
(	
	brand [varchar](100) '.'
)

EXEC sp_xml_removedocument @hDoc
SELECT * from dbo.carBrand
end
go

EXEC insertBrandFromXMLt
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--Insertuje samochody z xmla do tabeli car-----------------------------------------------------------------------------------------------------------

create procedure insertCarsFromXML
as
begin

DECLARE @XML AS XML, @hDoc AS INT

select top 1 @XML = xmlData from xmlFile;

exec sp_xml_preparedocument @hDoc OUTPUT, @XML

INSERT INTO car
SELECT *
FROM
OPENXML(@hDoc, '/CarDealer/cars/car')
WITH
(	
    type varchar(20) 'type',
	model varchar(20) 'model',
	year [int] 'year',
	mileage int 'mileage',
	price money 'price',
	brand varchar(20) 'brand',
	gearbox varchar(20) 'gearbox',
	engine varchar(20) 'engine',
	body varchar(20) 'body'
)
EXEC sp_xml_removedocument @hDoc
SELECT * from dbo.car
END
GO

exec insertCarsFromXML


-----------------------------------------------------------------------------------------------------------------------------------------------------
--exportuje tabele do xmla---------------------------------------------------------------------------------------------------------------------------
create procedure exportXml @path varchar(1000)
as
begin
	declare @parameter varchar(1000);
	set @parameter = 'bcp "SELECT * FROM CarDealer.dbo.car FOR XML AUTO, ELEMENTS" queryout "' + @path + '" -c -T';
	EXEC xp_cmdshell @parameter;
end
GO

EXEC exportXml 'C:\xml\exportCarDealer.xml'
GO