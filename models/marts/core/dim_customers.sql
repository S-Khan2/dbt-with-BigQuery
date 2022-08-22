/*
    This is my first dimension model using CTEs from staging models
*/

WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

customer_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS most_recent_order_date,
        COUNT(order_id) AS number_of_orders
    FROM orders
    GROUP BY 1
),

customer_values AS (
    SELECT 
        customer_id,
        SUM(amount) AS lifetime_value
    FROM {{ ref('fct_orders') }}
    GROUP BY 1
),

final AS (
    SELECT
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        COALESCE(customer_orders.number_of_orders, 0) AS number_of_orders,
        COALESCE(customer_values.lifetime_value, 0) AS lifetime_value
    FROM customers
    LEFT JOIN customer_orders USING (customer_id)
    LEFT JOIN customer_values USING (customer_id)
)

SELECT * FROM final