drop database if exists marketplace;
create database marketplace;
use marketplace;

/* Пользователи */
drop table if exists users;
create table users(
	id SERIAL PRIMARY KEY,
	firstname varchar(200),
	lastname varchar(200),
	email varchar(100) unique,
	password_hash varchar(200),
	birthday date,
	created_at datetime default now(),
	
	index(email)
);

/* Все продукты */
drop table if exists products;
create table products(
	id SERIAL PRIMARY KEY,
	title varchar(200) not null,
	description text,
	price decimal(10, 2),
	`count` int unsigned not null,
	owner_id bigint unsigned not null, 
	
	foreign key (owner_id) references users(id),
	
	index product_name(title)
);

/* Корзина */
drop table if exists basket;
create table basket(
	id SERIAL primary key,
	user_id bigint unsigned not null,
	
	foreign key (user_id) references users(id)
);

/* Таблица товаров из корзин */
drop table if exists basket_storage;
create table basket_storage(
	basket_id bigint unsigned not null,
	product_id bigint unsigned not null,
	
	foreign key (basket_id) references basket(id),
	foreign key (product_id) references products(id)
);

/* Баланс */
drop table if exists purse;
create table purse(
	user_id bigint unsigned not null,
	`count` decimal(10, 2) default 0,
	bonus_count decimal(10, 2)  default 0,
	
	foreign key (user_id) references users(id)
);

/* Рубрики */
drop table if exists rubric;
create table rubric(
	id SERIAL PRIMARY KEY,
	`name` varchar(200),
	
	index rubric_name(`name`)
);

/* Рубрики продуктов */
drop table if exists products_rubric;
create table products_rubric(
	rubric_id bigint unsigned not null,
	product_id bigint unsigned not null,
	
	foreign key (rubric_id) references rubric(id),
	foreign key (product_id) references products(id)
);

/* Заказы */
drop table if exists purchase;
create table purchase(
	buyer_id bigint unsigned not null,
	status enum('canceled', 'completed', 'processed'),
	created_at datetime default now(),
	
	foreign key (buyer_id) references users(id)
);


/* Изображения товаров*/
drop table if exists images;
create table images(
	product_id bigint unsigned not null,
	image_name varchar(255),
	
	foreign key (product_id) references products(id)
);

/* Скидки */
drop table if exists discounts;
create table discounts(
	id SERIAL PRIMARY KEY,
	number varchar(200) -- Размер скидки (0 - 100%)
);

/* Товары со скидкий */
drop table if exists discounts_products;
create table discounts_products(
	product_id bigint unsigned not null,
	discount_id bigint unsigned not null,
	
	foreign key (product_id) references products(id),
	foreign key (discount_id) references discounts(id)
);

/* Понравивишиеся товары */
drop table if exists likes;
create table likes(
	product_id bigint unsigned not null,
	users_id bigint unsigned not null,
	
	foreign key (product_id) references products(id),
	foreign key (users_id) references users(id)
);