create database rent_info;

create table if not exists addresses(
                                        id serial primary key,
                                        city varchar,
                                        region varchar,
                                        street varchar
);

create type gender as enum('Male', 'Female');

create type family_status as enum('Single', 'Married', 'Divorced', 'Widow', 'Separated', 'Other');

create table if not exists customers (
                                         id serial primary key ,
                                         first_name varchar,
                                         last_name varchar,
                                         email varchar,
                                         date_of_birth date,
                                         gender gender,
                                         nationality varchar,
                                         family_status family_status
);

create type house_type as enum('House', 'Apartment');


create table if not exists agencies(
                                       id serial primary key,
                                       agency_name varchar,
                                       phone_number varchar,
                                       address_id int references addresses(id)
    );

create table if not exists owners(
                                     id serial primary key ,
                                     first_name varchar,
                                     last_name varchar,
                                     email varchar,
                                     date_of_birth date,
                                     gender gender
);


create table if not exists houses(
                                     id serial primary key,
                                     house_type house_type,
                                     price numeric,
                                     rating float,
                                     description text,
                                     room int,
                                     furniture boolean,
                                     address_id int references addresses(id),
    owner_id int references owners(id)
    );


create table if not exists rent_info(
                                        owner_id int references owners(id),
    customer_id int references customers(id),
    agency_id int references agencies(id),
    house_id int references houses(id)
    );


--DDL----

alter table agencies alter column agency_name set not null ;
alter table  agencies add constraint phone_number_check check ( phone_number like '+996%' );

alter table owners add constraint email_unique unique(email);
alter table customers add constraint email_un unique(email);


alter table rent_info add column check_in date;
alter table rent_info add column check_out date;



alter table customers rename column family_status to marital_status;





--1# Owner_лердин аттарынын арасынан эн коп символ камтыган owner_ди жана анын уйун(House) чыгар.
select o.*,  h.* from owners o join houses h on o.id = h.owner_id order by length(o.first_name) desc limit 5;

--2# Уйлордун баалары 1500, 2000 дин аралыгында бар болсо true чыгар, жок болсо false чыгар.
select id, rating, furniture from houses where price between 1500 and 2000;

--3# id_лери 5, 6, 7, 8, 9, 10 го барабар болгон адресстерди жана ал адрессте кайсы уйлор бар экенин чыгар.
select * from houses h join addresses a on h.address_id = a.id where a.id in (5,6,7,8,9,10);

--4# Бардык уйлорду, уйдун ээсинин атын, клиенттин атын, агенттин атын чыгар.
select h.*, o.first_name, c.first_name, a.agency_name from houses h join rent_info ri
                                                                         on h.id = ri.house_id join agencies a on ri.agency_id = a.id join owners o on h.owner_id = o.id
                                                                    join customers c on ri.customer_id = c.id;


--5# Клиенттердин 10-катарынан баштап 1999-жылдан кийин туулган 15 клиентти чыгар.
select * from customers where extract(year from date_of_birth) > 1999 offset 10 limit 15;

--6# Рейтинги боюнча уйлорду сорттоп, уйлордун тайптарын, рейтингин жана уйдун ээлерин чыгар. (asc and desc)
select h.house_type, h.rating, o.first_name from houses h join owners o on h.owner_id = o.id
order by h.rating;

select h.house_type, h.rating, o.first_name from houses h join owners o on h.owner_id = o.id
order by h.rating desc ;

--7#  Уйлордун арасынан квартиралардын (apartment) санын жана алардын баасынын суммасын чыгар.
select count(*), sum(price) from houses where house_type = 'Apartment';

--8# Агентсволардын арасынан аты ‘My_House’ болгон агентсвоны, агентсвонын
-- адресин жана анын бардык уйлорун, уйлордун адрессин чыгар.
select ad.city, h.*, h.address_id, ad.region from agencies a join addresses ad on a.address_id = ad.id
                                                             join houses h on ad.id = h.address_id where a.agency_name = 'My House';

--9# Уйлордун арасынан мебели бар уйлорду, уйдун ээсин жана уйдун адрессин чыгар.
select o.first_name, a.city from houses h join owners o on h.owner_id = o.id
                                          join addresses a on h.address_id = a.id where furniture = 'true';

--10# Кленти жок уйлордун баарын жана анын адрессин жана ал уйлор кайсыл агентсвога тийешелуу экенин чыгар.
select * from houses h join addresses a on a.id = h.address_id
                       join owners o on h.owner_id = o.id join agencies ag on a.id = ag.address_id
                       join rent_info ri on h.id = ri.house_id where ri.customer_id is null ;

--11# Клиенттердин улутуна карап, улутуну жана ал улуутта канча клиент жашайт санын чыгар
select c.nationality , count(*) from customers c group by c.nationality;

--12# .Уйлордун арасынан рейтингтери чон, кичине, орточо болгон 3 уйду чыгар.
select max(rating), min(rating), avg(rating) from houses;


--13# Уйлору жок киленттерди, клиенттери жок уйлорду чыгар.
select * from houses h full join rent_info ri on h.id = ri.house_id
                       full join customers c on ri.customer_id = c.id where ri.customer_id is null ;


--14# Уйлордун бааларынын орточо суммасын чыгар.
select avg(houses.price) from houses;

--15# ‘A’ тамга менен башталган уйдун ээсинин аттарын, клиенттердин аттарын чыгар.
select o.first_name, c.first_name from owners o join rent_info ri on o.id = ri.owner_id
                                                join customers c on ri.customer_id = c.id where o.first_name ilike 'a%';

--16# Эн уйу коп owner_ди жана анын уйлорунун санын чыгар.
select o.first_name, count(h.id) from owners o join houses h on o.id = h.owner_id
group by o.first_name;

--17# Улуту Kyrgyzstan уй-булолу customerлерди чыгарыныз.
select * from customers where marital_status = 'Married' and nationality = 'Kyrgyz';


--18# .Эн коп болмолуу уйду жана анын адресин ал уй кайсыл ownerге таандык ошону чыгарыныз.
select o.first_name, h.room, a.street, max(h.room) as count from houses h join addresses a on a.id = h.address_id
    join owners o on h.owner_id = o.id group by o.first_name, h.room, a.street order by count desc limit 1;


--19# Бишкекте жайгашкан уйлорду жана клиентерин кошо чыгарыныз.
select * from houses h join addresses a on a.id = h.address_id
                       join rent_info ri on h.id = ri.house_id join customers c on ri.customer_id = c.id
where a.city = 'Bishkek';

--20# Жендерине карап группировка кылыныз
select gender from customers group by gender;
select gender from owners group by gender;

--21# Эн коп моонотко ижарага алынган уйду чыгарыныз.
select h.house_type, h.room, h.description, max(ri.check_out) as max from houses h join rent_info ri on h.id = ri.house_id
group by h.house_type, h.room, h.description order by max desc limit 1;

--22# Эн кымбат уйду жана анын ээсин чыгарыныз.
select o.first_name, max(h.price) as max from owners o join houses h on o.id = h.owner_id
group by o.first_name order by max desc limit 1;

--23# Бир региондо жайгашкан баардык агентстволорду чыгарыныз
select a.agency_name, ad.region from agencies a join addresses ad on a.address_id = ad.id group by ad.region, a.agency_name;




--24# Рейтинг боюнча эн популярдуу 5 уйду чыгар.
select id, max(rating) as max from houses group by id order by max desc limit 5;

--25# Орто жаштагы owner_ди , анын уйун , уйдун адрессин чыгар.
select avg(extract(year from o.date_of_birth)) from owners o join houses h on o.id = h.owner_id join addresses a on a.id = h.address_id

