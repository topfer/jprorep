create database tst;
create table searches (sid int(4) auto_increment, name varchar(32) not null, primary key sid);
grant all on tst.* to arcore@'%';
