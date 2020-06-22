use marketplace;

create or replace view products_info
as
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

-- select * from products_info;

create or replace view price_with_discount
as
select
	ap.id,
	ap.title,
	min(ap.price) as price
from 
	(select 
		p.id,
		p.title,
		p.price - ((p.price / 100) * d.`number`) as 'price'
	from 
		products p
	inner join discounts_products dp
		on dp.product_id = p.id
	inner join discounts d 
		on dp.discount_id = d.id
	UNION
		select id, title, price from products p2) as ap
	group by ap.title, ap.id;

-- select * from price_with_discount;




