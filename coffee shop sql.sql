select * from coffee_data.coffee_shop_data


#updating the format of the table of date 
update coffee_data.coffee_shop_data
set transaction_date = str_to_date(transaction_date,'%d-%m-%Y')

-- describe coffee_data.coffee_shop_data

# changing the format of data

alter table coffee_data.coffee_shop_data
modify column  transaction_date date;

-- #updating the format of the table of time
update coffee_data.coffee_shop_data
set transaction_time = str_to_date(transaction_time,'%H:%i:%s')

alter table coffee_data.coffee_shop_data
modify column  transaction_time time;

#changing the name of thecolumn
alter table coffee_data.coffee_shop_data
change column ï»¿transaction_id transaction_id int


# Total sales  month wise
select sum(transaction_qty*unit_price) as 'total_sales'
from coffee_data.coffee_shop_data
where
month (transaction_date) = 5 -- may month
# Month-on-Month (MoM) growth measures the percentage change in a value  from one month to the next.
select  
	month(transaction_date) as 'month',  round(sum(transaction_qty*unit_price)) AS 'total_sales',
    (sum(transaction_qty*unit_price)-lag(sum(transaction_qty*unit_price),1)
    over(order by month(transaction_date))) /lag(sum(transaction_qty*unit_price),1)
    over (order by month(transaction_date)) *100  as 'mom_increase_percentage'
    
    from coffee_data.coffee_shop_data
    where month(transaction_date) in(4,5)
    group by month(transaction_date)
    order by month(transaction_date)

# total orders per  month
select sum(transaction_id) as total_orders from coffee_data.coffee_shop_data
where  month(transaction_date) = 5
# total quantity soled that month
select sum(transaction_qty)  as total_quant_sold from  coffee_data.coffee_shop_data
where month(transaction_date) = 5
#mom for total transaction quantity per month 
select  
	month(transaction_date) as 'month',  round(sum(transaction_qty)) AS 'total_quantity',
		(sum(transaction_qty)-lag(sum(transaction_qty),1)
		over(order by month(transaction_date))) /lag(sum(transaction_qty),1)
		over (order by month(transaction_date)) *100  as 'mom_increase_percentage'
		
		from coffee_data.coffee_shop_data
		where month(transaction_date) in(4,5)
		group by month(transaction_date)
		order by month(transaction_date)
        
        # total order, total sales and total amount sold  on a particular day 
        select 
			concat(round(sum(unit_price)/1000,1),'K') as total_amount ,
			concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales,
			concat(round(count(transaction_id)/1000,1),'K')as total_order
        from coffee_data.coffee_shop_data
        where 
			transaction_date = '2023-3-27'

# weekend -- sat and sun
# Weekday -- Mon to Fri

# total sales in a particular month based on weekday and weekends
select
	case 
		when dayofweek(transaction_date) in (1,7) then 'weekend'
        else 'weekday'
        end as day_type,
	concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales
from coffee_data.coffee_shop_data
	where 
		month(transaction_date) = 2
	group by
		case
			when dayofweek(transaction_date) in (1,7) then 'weekend'
			else 'weekday'
			end
			
# calculate total sales based on  the store location

select 
	store_location,
	concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales  
from coffee_data.coffee_shop_data
where 
	month(transaction_date)  = 2
group by store_location 
order by concat(round(sum(transaction_qty*unit_price)/1000,1),'K') desc


# finding the trend between sales per day over avg sales over month

select 	
	avg(total_sales) AS avg_sales
	from(select sum(transaction_qty*unit_price) as total_sales 
		from coffee_data.coffee_shop_data
        where month(transaction_date)  = 5
        group by transaction_date) as internal_query

select
	day(transaction_date) as day_of_month,
	concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales
from 
	coffee_data.coffee_shop_data
where 
	month(transaction_date) = 5
group by  day(transaction_date) 

# categorizing if the daily sales are below or above avgerage for the monthly sales

select 
	day_of_month,
    case
		when total_sales > avg_sales then 'Above average'
        when total_sales < avg_sales  then 'Below average'
	else
		'Equal to average'
	end as sales_status,total_sales
from(
	select
		day(transaction_date) as day_of_month,
		sum(transaction_qty*unit_price) as total_sales,
        avg(sum(transaction_qty*unit_price)) over () as avg_sales
	from
		coffee_data.coffee_shop_data
	where
    month(transaction_date)  = 5
    group by 
		 day(transaction_date)
         ) as sales_data 
	order by 
		day_of_month;

# analize sales performance across different  catagories

select 
	product_category ,
	concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales
from 
	coffee_data.coffee_shop_data
where 
	month(transaction_date) = 5
group by 
	product_category
    
order by 
	concat(round(sum(transaction_qty*unit_price)/1000,1),'K') desc
    
# top 10 products 


select 
	product_type ,
	sum(transaction_qty*unit_price) as total_sales
from 
	coffee_data.coffee_shop_data
where 
	month(transaction_date) = 5 and product_category = 'Coffee'
group by 
	product_type
order by sum(transaction_qty*unit_price) desc limit 10 


select 
	sum(transaction_qty*unit_price) as total_sales,
    sum(transaction_qty) as total_qty,
    count(*)
from coffee_data.coffee_shop_data
where month(transaction_date) = 5
and dayofweek(transaction_date) = 1
and hour(transaction_time) = 11