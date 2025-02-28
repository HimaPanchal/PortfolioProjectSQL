---USING TEMP  TABLE
create temp table cust_max_transactions as
(
select customer_id, transaction_id, sum(sales_cost) as max_transaction_sales
from grocery_db.transactions
group by customer_id, transaction_id
);
select customer_id, max(max_transaction_sales) from cust_max_transactions3
group by customer_id
order by customer_id;

--- USING CTE 
With cust_max_transactions_cte as 
(
select customer_id, transaction_id, sum(sales_cost) as max_transaction_sale
from grocery_db.transactions
group by customer_id, transaction_id
)

select customer_id, max(max_transaction_sale) from cust_max_transactions_cte2
group by customer_id
order by customer_id;







