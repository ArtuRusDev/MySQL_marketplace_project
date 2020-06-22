use marketplace;

/* Процедура совершения покупки товаров*/
DROP PROCEDURE IF EXISTS sp_execute_purchase;
DELIMITER $$
$$
CREATE PROCEDURE sp_execute_purchase(in user_id bigint, out tran_result varchar(255))
BEGIN
	DECLARE `_rollback_` bit default 0;
	DECLARE code varchar(200);
	DECLARE error_string varchar(200);
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	begin
		set `_rollback_` = 1;
		get stacked diagnostics condition 1
			code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
		set tran_result = concat('Error: ', code, ', Text: ', error_string);
	end;
	
	start transaction;
		INSERT 
		into purchase (buyer_id, status) 
		values (user_id, 'processed');
		
		-- проверка что в корзине есть товары 
		if ! (select bs.product_id from basket_storage bs where bs.basket_id = (SELECT id from basket b where b.user_id = user_id)) then
			select 1;
			set `_rollback_` = 1;
			set tran_result = concat('Error: ', '0', ', Text: ', 'basket is empty');			
		end if;
		
		UPDATE products
			SET count = (count - 1)
		WHERE id in 
			(select bs.product_id from basket_storage bs where bs.basket_id = 
				(SELECT id from basket b where b.user_id = user_id));
		
		-- необходимо создать представление 'price_with_discount' для корректной работы
		set @total = (select sum(price) from price_with_discount p where p.id in (select bs.product_id from basket_storage bs where bs.basket_id = (SELECT id from basket b where b.user_id = 12)));
		
		set @purse_count = (select p.count FROM purse p where p.user_id = user_id);
		set @bonus_count = (select p.bonus_count FROM purse p where p.user_id = user_id);
		
		if (@total > (@purse_count + @bonus_count)) then
			set `_rollback_` = 1;
			set tran_result = concat('Error: ', '0', ', Text: ', 'insufficient funds');
		else
			set @total = @total - @bonus_count;
			update purse p set p.bonus_count = 0 where p.user_id = user_id;
			update purse p set p.count  = p.count - @total where p.user_id = user_id;
		end if;
	
	if `_rollback_` then
		UPDATE purchase
		set status = 'canceled'
		where buyer_id = user_id;
	else
		set tran_result = 'ok';

		UPDATE purchase
		set status = 'completed'
		where buyer_id = user_id;
	end if;
	commit;
END $$
DELIMITER ;

-- CALL sp_execute_purchase(15, @tran_result);
-- SELECT @tran_result;

/* Создание нового пользователя */
DROP PROCEDURE IF EXISTS add_new_user;
DELIMITER $$
$$
CREATE PROCEDURE add_new_user(
	firstname varchar(200), lastname varchar(200), 
	email varchar(100), password_hash varchar(100),
	birthday date, out tran_result varchar(200)
)
BEGIN
	DECLARE `_rollback_` bit default 0;
	DECLARE code varchar(200);
	DECLARE error_string varchar(200);
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	begin
		set `_rollback_` = 1;
		get stacked diagnostics condition 1
			code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
		set tran_result = concat('Error: ', code, ', Text: ', error_string);
	end;
	
	start transaction;
		insert into users (firstname, lastname, email, password_hash, birthday) values (firstname, lastname, email, password_hash, birthday);
		
		if ! `_rollback_` then
			set @user_id = LAST_INSERT_ID();
			/* создание корзины для пользователя */
			INSERT into basket(user_id) values (@user_id);
			/* создание счета для пользователя */
			INSERT into purse (user_id) values (@user_id);
		end if;
	
		
	if `_rollback_` then
		rollback;
	else
		set tran_result = 'ok';
	end if;
	commit;
END $$
DELIMITER ;

-- CALL add_new_user('firstname', 'lastname', 'email', 'password_hash', '2004-02-27', @tran_result);
-- SELECT @tran_result;

/* Топ 3 товара которые могут понравиться пользлователю */
/*
	Критерии выборки:
	- топ покупаемых товаров
	- топ товаров из категории товаров кторые лежат в корзине пользователя
*/

DROP PROCEDURE IF EXISTS top_3_products_for_user;
DELIMITER $$
$$
CREATE PROCEDURE top_3_products_for_user(in user_id bigint)
BEGIN
	
	SELECT
		bs.product_id
	from
		basket_storage bs
	inner join products_rubric pr 
	on pr.product_id = bs.product_id
	where rubric_id in 
		(select 
			pr.rubric_id 
		from 
			basket_storage bs
		inner join basket b 
			on b.id = bs.basket_id
		inner join products_rubric pr 
			on pr.product_id = bs.product_id
		where b.user_id = @user_id)
	group by bs.product_id
	order by count(*) desc
	limit 3;
		
END $$
DELIMITER ;
-- call top_3_products_for_user(17);