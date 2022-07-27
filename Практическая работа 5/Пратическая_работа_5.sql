-- 1. Для каждого продавца (job_id=670) вывести разность между его зарплатой и средней зарплатой продавцов в отделе c кодом 23. 

SELECT employee_id, round(salary-(select avg(salary) from employee where department_id=23),2) as difference
       FROM employee
      where job_id=670
      order by difference desc;


-- 2. Выбрать среднюю сумму продаж, которая приходится на одного сотрудника в городе NEW YORK.

SELECT round(sum(Sal.total)/count(employee_id),2) as 'Average sum', regional_group
FROM employee Emp
JOIN department Dep ON Emp.department_id=Dep.department_id
JOIN customer Cus ON Emp.employee_id=Cus.salesperson_id
JOIN sales_order Sal ON Cus.customer_id=Sal.customer_id
JOIN location Loc ON Dep.location_id=Loc.location_id
WHERE regional_group = 'NEW YORK';


-- 3. Определить, какой продукт был наиболее популярен весной 2019г (по количеству проданных экземпляров quantity).

SELECT P.description, sum(I.quantity) as Total
FROM product P
JOIN item I ON I.product_id = P.product_id
JOIN sales_order Sal ON I.order_id=I.order_id
WHERE order_date between str_to_date('01-03-2019','%d-%m-%Y') and str_to_date('31-05-2019','%d-%m-%Y')
GROUP BY P.description
ORDER BY Total DESC
LIMIT 1;


-- 4. Выбрать товары, наиболее популярные в каждом городе (по количеству проданных экземпляров quantity).

select *
from (select product.description as product_name, sum(item.quantity) as summa, location.regional_group as place
FROM product, item, sales_order, customer, employee, department, location
WHERE product.product_id=item.product_id
AND item.order_id=sales_order.order_id
AND sales_order.customer_id=customer.customer_id
AND customer.salesperson_id=employee.employee_id
AND employee.department_id=department.department_id
AND department.location_id=location.location_id
Group by product.description, location.location_id
order by location.location_id, sum(item.quantity) desc) t
order by rank() over(partition by place order by summa desc), summa desc
limit 4;




--  5. Выбрать данные для построения графика зависимости суммы продажи от процента представленной покупателю скидки.

select item.total as summa, round((1 - item.actual_price/price.list_price)*100,0) as skidka
FROM product, item, sales_order, price
WHERE product.product_id=item.product_id
AND item.order_id=sales_order.order_id
AND product.product_id=price.product_id
AND sales_order.order_date between price.start_date and price.end_date
order by skidka desc;


-- ------------ Необязательно, не оценивается * -------------------- 
-- (*). Определить, не хранятся ли в базе данных сведения о покупателях, которые не совершили ни одной покупки.

select customer_id as no_orders_customer_id
from customer
where customer_id not in 
(select sales_order.customer_id
FROM product, item, sales_order, customer, price
WHERE product.product_id=item.product_id
AND item.order_id=sales_order.order_id
AND sales_order.customer_id=customer.customer_id
AND product.product_id=price.product_id);



-- (*) Определить, не зафиксированы ли случаи, когда продавались продукты, не выставленные на данный момент в продажу. 
-- Вывести название продукта, дату продажи, покупателя.

select product.description as product_name, sales_order.order_date as sales_date, sales_order.customer_id
FROM product, item, sales_order, customer, price
WHERE product.product_id=item.product_id
AND item.order_id=sales_order.order_id
AND sales_order.customer_id=customer.customer_id
AND product.product_id=price.product_id
AND sales_order.order_date not between price.start_date and price.end_date;

-- (*) Определить, в каких регионах любят покупать дорогие товары, а в каких - дешевые.
