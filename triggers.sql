/* Триггеры */

USE marketplace;
drop trigger if exists check_birthday_date;
DELIMITER $$
$$
CREATE TRIGGER check_birthday_date
before UPDATE 
ON users FOR EACH ROW
begin
	if 	NEW.birthday >= CURRENT_DATE() THEN
		signal SQLSTATE '45000' set MESSAGE_TEXT = "Update canceled. Date of birth cannot be greater than today's date";
	end if;
end;
$$
DELIMITER ;

drop trigger if exists check_birthday_date_2;
DELIMITER $$
$$
CREATE TRIGGER check_birthday_date_2
before INSERT 
ON users FOR EACH ROW
begin
	if NEW.birthday >= CURRENT_DATE() THEN
		set new.birthday = CURRENT_DATE();
	end if;
end;
$$
DELIMITER ;

--INSERT INTO `users`(firstname, lastname, email, password_hash, birthday) VALUES ('Blandcsa','Schaller','dietrich.cory@examdfple.net','dd4bdc2cecd71ec94da54d161a03de5c2d4975c26','2219-04-27');
