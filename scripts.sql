use marketplace;


/* Выборка информации о продутках */
select 
	p.id,
	p.title,
	p.description,
	p.price,
	p.count,
	r.name,
	u.firstname as owner,
	img.image_name
FROM 
	products p
inner join products_rubric pr
	on pr.product_id = p.id
inner join rubric r
	on r.id = pr.rubric_id
inner join users u
	on u.id = p.owner_id
left join images img 
	on img.product_id = p.id
order by p.count desc;


/* Выборка продуктов из коризны  пользователя */
select
	p.title as `product name`,
	u.firstname,
	u.lastname
from 
	basket b
inner join basket_storage bs
	on bs.basket_id = b.id 
inner join products p
	on p.id = bs.product_id
inner join users u 
	on u.id = b.user_id;


/* Общая сумма товаров в корзине */
select
	u.firstname,
	sum(p.price) as total
from 
	basket b
inner join basket_storage bs
	on bs.basket_id = b.id 
inner join products p
	on p.id = bs.product_id
inner join users u 
	on u.id = b.user_id
group by u.firstname
order by total desc;


/* Расчет скидки товаров */
select 
	p.title,
	p.price as 'old price',
	d.`number` as 'discount (%)',
	p.price - ((p.price / 100) * d.`number`) as 'new_price' 
from 
	products p
inner join discounts_products dp
	on dp.product_id = p.id
inner join discounts d 
	on dp.discount_id = d.id;


/* Выборка продуктов которые были когда-либо куплены */
select 
	DISTINCT p2.title,
	p2.description,
	p2.count,
	p2.price
from
	products p2
inner join basket_storage bs 
	on bs.product_id = p2.id
inner join basket b 
	on b.id = bs.basket_id 
inner join purchase p
	on p.buyer_id = b.user_id 
where p.status = 'completed'
order by p2.title;

