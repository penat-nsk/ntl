/*Fact_Flights - содержит совершенные перелеты. Если в рамках билета был сложный маршрут с пересадками - каждый сегмент учитываем независимо
Пассажир
Дата и время вылета (факт)
Дата и время прилета (факт)
Задержка вылета (разница между фактической и запланированной датой в секундах)
Задержка прилета (разница между фактической и запланированной датой в секундах)
Самолет
Аэропорт вылета
Аэропорт прилета
Класс обслуживания
Стоимость

Dim_Calendar - справочник дат
Dim_Passengers - справочник пассажиров
Dim_Aircrafts - справочник самолетов
Dim_Airports - справочник аэропортов
Dim_Tariff - справочник тарифов (Эконом/бизнес и тд)
*/

CREATE SCHEMA dwh AUTHORIZATION postgres;

-- Справочники 

-- Dim_Calendar

DROP TABLE IF EXISTS dwh.Dim_Calendar CASCADE ;
CREATE TABLE dwh.Dim_Calendar
AS
WITH dates AS (
    SELECT dd::date AS dt
    FROM generate_series
            ('2017-01-01'::timestamp
            , '2018-01-01'::timestamp
            , '1 day'::interval) dd
)
SELECT
    to_char(dt, 'YYYYMMDD') AS id,
    dt AS date,
    to_char(dt, 'YYYY-MM-DD') AS ansi_date,
    date_part('isodow', dt)::int AS day,
    date_part('week', dt)::int AS week_number,
    date_part('month', dt)::int AS month,
    date_part('isoyear', dt)::int AS year,
    (date_part('isodow', dt)::smallint BETWEEN 1 AND 5)::int AS week_day

FROM dates
ORDER BY dt;

ALTER TABLE dwh.Dim_Calendar ADD PRIMARY KEY (id);

-- Dim_Passengers

drop table dwh.Dim_Passengers;

CREATE TABLE dwh.Dim_Passengers (
    passenger_id varchar(100) primary key,
	passenger_name varchar(400) not null,
	phone varchar(400),
	email varchar(400)
);
drop table dwh.passengers_reject;
CREATE TABLE dwh.passengers_reject (
    passenger_id varchar(100),
	passenger_name varchar(400),
	phone varchar(400),
	email varchar(400)
);

-- Dim_Aircrafts

drop table dwh.Dim_Aircrafts;

CREATE TABLE dwh.Dim_Aircrafts (
--    id serial not null primary key,
    aircraft_code varchar(100) primary key,
	aircraft_model varchar(200) not null,
	aircraft_range varchar(200)
);

drop table dwh.aircrafts_reject;
CREATE TABLE dwh.aircrafts_reject (
  --  id serial not null primary key,
    aircraft_code varchar(100),
	aircraft_model varchar(200),
	aircraft_range varchar(200)
);


-- Dim_Airports 

drop table dwh.Dim_Airports ;

CREATE TABLE dwh.Dim_Airports (
 --   id serial not null primary key,
    airport_code varchar(100) primary key,
	airport_name varchar(200) not null,
	city varchar(200),
	coordinates varchar(200),
	timezone varchar(200)
);

DROP TABLE dwh.airports_reject;
CREATE TABLE dwh.airports_reject (
  --  id serial not null primary key,
    airport_code varchar(100),
	airport_name varchar(200),
	city varchar(200),
	coordinates varchar(200),
	timezone varchar(200)
);


-- Dim_Tariff 
drop table  dwh.Dim_Tariff;

CREATE TABLE dwh.Dim_Tariff (
    tariff_code varchar(100) primary key,
	tariff_name varchar(200)
);

DROP TABLE dwh.tariff_reject; 
CREATE TABLE dwh.tariff_reject (
    tariff_code varchar(100),
	tariff_name varchar(200)
);


-- Сбор ошибок
	CREATE TABLE dwh.output_log (
    id serial not null primary key,
	error varchar(2000),
	update_date timestamp DEFAULT now()
);

-- Факты

-- Fact_Flights 

drop table dwh.Fact_Flights;
drop table dwh.flights_reject;

CREATE TABLE dwh.Fact_Flights (
    id serial not null primary key,
    passenger_id varchar(100) references Dim_Passengers(passenger_id),
    departure_time timestamp,
    departure_date varchar(100) references dwh.Dim_Calendar(id),
    arrival_time timestamp,
    arrival_date varchar(100) references dwh.Dim_Calendar(id),
    dep_delay int,
    arr_delay int,
    aircraft_code varchar(100) references Dim_Aircrafts (aircraft_code),
    dep_airport varchar(100)  references Dim_Airports (airport_code),
    arr_airport varchar(100) references Dim_Airports (airport_code),
    tariff_code varchar(100) references Dim_Tariff (tariff_code),
	amount decimal(10,2)
);


CREATE TABLE dwh.flights_reject (
    id serial,
    passenger_id varchar(100),
    departure_time timestamp,
    departure_date varchar(100),
    arrival_time timestamp,
    arrival_date varchar(100),
    dep_delay int,
    arr_delay int,
    aircraft_code varchar(100), 
    dep_airport varchar(100),
    arr_airport varchar(100),
    tariff_code varchar(100),
	amount decimal(10,2)
);

