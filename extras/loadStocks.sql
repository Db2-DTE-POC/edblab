-- -rw-r--r-- 1 bob bob   201458 Mar  5 17:25 accou00103.unl accounts
-- -rw-r--r-- 1 bob bob  1222176 Mar  5 17:25 custo00106.unl customer
-- -rw-r--r-- 1 bob bob 23936052 Mar  5 17:25 stock00101.unl stock_transactions
-- -rw-r--r-- 1 bob bob   389480 Mar  5 17:25 stock00102.unl stock_history
-- -rw-r--r-- 1 bob bob     1010 Mar  5 17:25 stock00100.unl stock_symbols
 
create table IF NOT EXISTS stock_symbols 
  (
    symbol varchar(4) not null ,
    company varchar(64) not null 
  );


create table IF NOT EXISTS stock_transactions 
  (
    tx_no integer not null ,
    tx_date char(10) not null ,
    custid integer not null ,
    symbol varchar(4) not null ,
    price decimal(9,2) not null ,
    quantity integer not null 
  );

create table IF NOT EXISTS stock_history 
  (
    symbol varchar(4) not null ,
    tx_date char(10) not null ,
    high decimal(9,2) not null ,
    low decimal(9,2) not null ,
    open decimal(9,2) not null ,
    close decimal(9,2) not null ,
    volume integer not null 
  );


create table IF NOT EXISTS accounts 
  (
    custid integer not null ,
    tx_count integer not null ,
    balance decimal(9,2) not null 
  );


create table IF NOT EXISTS customer 
  (
    customerid integer,
    firstname varchar(20),
    lastname varchar(20),
    birthdate varchar(20),
    street varchar(30),
    city varchar(30),
    state varchar(2),
    zipcode varchar(10),
    email varchar(40),
    phone varchar(12),
    card_type varchar(5),
    card_no varchar(16)
  );


--
-- truncate the tables
--
truncate table stock_symbols      ;
truncate table stock_transactions ;
truncate table stock_history      ;
truncate table accounts           ;
truncate table customer           ;

--
-- load the tables
--
\COPY stock_symbols      FROM 'stock00100.unl' DELIMITER '|';
\COPY stock_transactions FROM 'stock00101.unl' DELIMITER '|';
\COPY stock_history      FROM 'stock00102.unl' DELIMITER '|';
\COPY accounts           FROM 'accou00103.unl' DELIMITER '|';
\COPY customer           FROM 'custo00106.unl' DELIMITER '|';

--
-- count the rows in each table
--
select count(*),'stock_symbols     ' from stock_symbols      ;
select count(*),'stock_transactions' from stock_transactions ;
select count(*),'stock_history     ' from stock_history      ;
select count(*),'accounts          ' from accounts           ;
select count(*),'customer          ' from customer           ;
