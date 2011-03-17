DROP DATABASE IF EXISTS arcoremgmt;
CREATE DATABASE arcoremgmt;

USE arcoremgmt;

CREATE TABLE searches (
       id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
       srcname VARCHAR(32) NOT NULL,
       created TIMESTAMP DEFAULT NOW(),  
       settingsinheritance BOOL,
       upward_inheritance INT(2) NOT NULL,
       downward_inheritance INT(2) NOT NULL,
       settings_overwrite BOOL,
       include_container_comment BOOL,
       include_property_comment BOOL,
       dereference_links BOOL,
       prefix_keys BOOL,
       prefix_keys_separator CHAR NOT NULL
);

GRANT ALL ON arcoremgmt.* TO arcore_user@'%';

FLUSH PRIVILEGES;

