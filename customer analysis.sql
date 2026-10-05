use olist;
USE olist;

-- ============================================================
-- OLIST CUSTOMER PURCHASE ANALYSIS
-- ============================================================


-- 1. TOTAL CUSTOMERS
SELECT 
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers;


-- 2. TOTAL ORDERS
SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;


-- 3. TOTAL PRODUCT PURCHASE
SELECT 
    ROUND(SUM(price), 2) AS total_purchase
FROM order_items;


-- 4. TOTAL FREIGHT
SELECT 
    ROUND(SUM(freight_value), 2) AS total_freight
FROM order_items;


-- 5. TOTAL CUSTOMER SPEND
SELECT 
    ROUND(SUM(price + freight_value), 2) AS total_customer_spend
FROM order_items;


-- 6. ORDERS PER CUSTOMER
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;


-- 7. CUSTOMER TOTAL PURCHASE
SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price), 2) AS total_purchase
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_purchase DESC;


-- 8. CUSTOMER TOTAL SPEND INCLUDING FREIGHT
SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spend
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spend DESC;


-- 9. CUSTOMER AOV
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_purchase,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS AOV
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY AOV DESC;


-- 10. REPEAT VS ONE-TIME CUSTOMERS
SELECT
    customer_unique_id,
    total_orders,
    CASE
        WHEN total_orders > 1 THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS customer_type
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) x;


-- 11. NUMBER OF REPEAT AND ONE-TIME CUSTOMERS
SELECT
    customer_type,
    COUNT(*) AS total_customers
FROM (
    SELECT
        c.customer_unique_id,
        CASE
            WHEN COUNT(DISTINCT o.order_id) > 1
                THEN 'Repeat Customer'
            ELSE 'One-Time Customer'
        END AS customer_type
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) x
GROUP BY customer_type;


-- 12. REPEAT CUSTOMER PERCENTAGE
SELECT
    ROUND(
        SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) x;


-- 13. TOP 10 CUSTOMERS BY PURCHASE
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_purchase
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_purchase DESC
LIMIT 10;


-- 14. TOP 10 CUSTOMERS WITH AOV
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_purchase,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS AOV
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_purchase DESC
LIMIT 10;


-- 15. PURCHASE BY STATE
SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_purchase
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_purchase DESC;


-- 16. AOV BY STATE
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_purchase,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS AOV
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY AOV DESC;


-- 17. MONTHLY PURCHASE ANALYSIS
SELECT
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS purchase_month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT c.customer_unique_id) AS customers,

    ROUND(SUM(oi.price), 2) AS total_purchase

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY DATE_FORMAT(
    o.order_purchase_timestamp,
    '%Y-%m'
)

ORDER BY purchase_month;


-- 18. MONTHLY AOV
SELECT
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS purchase_month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(SUM(oi.price), 2) AS total_purchase,

    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS AOV

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY DATE_FORMAT(
    o.order_purchase_timestamp,
    '%Y-%m'
)

ORDER BY purchase_month;


-- 19. PAYMENT METHOD ANALYSIS
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS payment_amount,
    ROUND(AVG(payment_value), 2) AS average_payment
FROM payments
GROUP BY payment_type
ORDER BY payment_amount DESC;


-- 20. PAYMENT PREFERENCE
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders
FROM payments
GROUP BY payment_type
ORDER BY total_orders DESC;


-- 21. INSTALLMENT ANALYSIS
SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS payment_amount
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;


-- 22. FIRST PURCHASE DATE
SELECT
    c.customer_unique_id,
    MIN(o.order_purchase_timestamp) AS first_purchase_date
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;


-- 23. LAST PURCHASE DATE
SELECT
    c.customer_unique_id,
    MAX(o.order_purchase_timestamp) AS last_purchase_date
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;


-- 24. CUSTOMER LIFESPAN
SELECT
    c.customer_unique_id,

    MIN(o.order_purchase_timestamp) AS first_purchase,

    MAX(o.order_purchase_timestamp) AS last_purchase,

    DATEDIFF(
        MAX(o.order_purchase_timestamp),
        MIN(o.order_purchase_timestamp)
    ) AS customer_lifespan_days

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY c.customer_unique_id;


-- 25. CUSTOMERS WITH MORE THAN 2 ORDERS
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) > 2
ORDER BY total_orders DESC;


-- 26. CUSTOMERS SPENDING MORE THAN 1000
SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price), 2) AS total_purchase
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
HAVING SUM(oi.price) > 1000
ORDER BY total_purchase DESC;


-- 27. CUSTOMER PURCHASE SEGMENT
SELECT
    customer_unique_id,
    ROUND(total_purchase, 2) AS total_purchase,

    CASE
        WHEN total_purchase < 100
            THEN 'Low'

        WHEN total_purchase < 500
            THEN 'Medium'

        WHEN total_purchase < 1000
            THEN 'High'

        WHEN total_purchase < 5000
            THEN 'Very High'

        ELSE 'VIP'
    END AS purchase_segment

FROM (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS total_purchase
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
) x

ORDER BY total_purchase DESC;


-- 28. CUSTOMER SEGMENT SUMMARY
SELECT
    purchase_segment,
    COUNT(*) AS customers,
    ROUND(SUM(total_purchase), 2) AS total_purchase,
    ROUND(AVG(total_purchase), 2) AS average_purchase

FROM (
    SELECT
        c.customer_unique_id,

        SUM(oi.price) AS total_purchase,

        CASE
            WHEN SUM(oi.price) < 100
                THEN 'Low'

            WHEN SUM(oi.price) < 500
                THEN 'Medium'

            WHEN SUM(oi.price) < 1000
                THEN 'High'

            WHEN SUM(oi.price) < 5000
                THEN 'Very High'

            ELSE 'VIP'
        END AS purchase_segment

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY c.customer_unique_id
) x

GROUP BY purchase_segment
ORDER BY total_purchase DESC;


-- ============================================================
-- 29. FINAL CUSTOMER PURCHASE ANALYSIS TABLE
-- ============================================================

SELECT

    c.customer_unique_id,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(oi.order_item_id) AS total_items,

    ROUND(SUM(oi.price), 2) AS total_purchase,

    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS AOV,

    MIN(o.order_purchase_timestamp)
        AS first_purchase_date,

    MAX(o.order_purchase_timestamp)
        AS last_purchase_date,

    DATEDIFF(
        MAX(o.order_purchase_timestamp),
        MIN(o.order_purchase_timestamp)
    ) AS customer_lifespan_days,

    CASE
        WHEN COUNT(DISTINCT o.order_id) > 1
            THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS customer_type

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY c.customer_unique_id

ORDER BY total_purchase DESC;