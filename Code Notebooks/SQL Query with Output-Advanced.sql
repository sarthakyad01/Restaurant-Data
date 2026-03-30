-- Orders per customer, including customers with 0 orders
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(o.OrderID) AS total_orders
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY total_orders DESC, c.LastName, c.FirstName;

-- Reservations per customer, including customers with 0 reservations
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(r.ReservationID) AS total_reservations
FROM Customers c
LEFT JOIN Reservations r
    ON c.CustomerID = r.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY total_reservations DESC, c.LastName, c.FirstName;

-- Rank dishes by number of times ordered
SELECT
    d.DishID,
    d.Name,
    COUNT(od.OrdersDishesID) AS times_ordered
FROM Dishes d
LEFT JOIN OrdersDishes od
    ON d.DishID = od.DishID
GROUP BY d.DishID, d.Name
ORDER BY times_ordered DESC, d.Name;

-- Total revenue per dish
SELECT
    d.DishID,
    d.Name,
    COUNT(od.OrdersDishesID) AS times_ordered,
    d.Price,
    ROUND(COUNT(od.OrdersDishesID) * d.Price, 2) AS total_revenue
FROM Dishes d
LEFT JOIN OrdersDishes od
    ON d.DishID = od.DishID
GROUP BY d.DishID, d.Name, d.Price
ORDER BY total_revenue DESC, d.Name;

-- Top 5 customers by spend
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    ROUND(COALESCE(SUM(d.Price), 0), 2) AS total_spent
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
LEFT JOIN OrdersDishes od
    ON o.OrderID = od.OrderID
LEFT JOIN Dishes d
    ON od.DishID = d.DishID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY total_spent DESC, c.LastName, c.FirstName
LIMIT 5;

-- Average order value (AOV)
WITH order_totals AS (
    SELECT
        o.OrderID,
        SUM(d.Price) AS order_value
    FROM Orders o
    JOIN OrdersDishes od
        ON o.OrderID = od.OrderID
    JOIN Dishes d
        ON od.DishID = d.DishID
    GROUP BY o.OrderID
)
SELECT
    ROUND(AVG(order_value), 2) AS average_order_value
FROM order_totals;

-- Average number of dishes per order
SELECT
    ROUND(AVG(dish_count), 2) AS avg_dishes_per_order
FROM (
    SELECT
        OrderID,
        COUNT(*) AS dish_count
    FROM OrdersDishes
    GROUP BY OrderID
) x;

-- City-level performance: customers, orders, revenue
WITH city_orders AS (
    SELECT
        c.City,
        o.OrderID,
        d.Price
    FROM Customers c
    LEFT JOIN Orders o
        ON c.CustomerID = o.CustomerID
    LEFT JOIN OrdersDishes od
        ON o.OrderID = od.OrderID
    LEFT JOIN Dishes d
        ON od.DishID = d.DishID
)
SELECT
    c.City,
    COUNT(DISTINCT c.CustomerID) AS total_customers,
    COUNT(DISTINCT o.OrderID) AS total_orders,
    ROUND(COALESCE(SUM(d.Price), 0), 2) AS total_revenue
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
LEFT JOIN OrdersDishes od
    ON o.OrderID = od.OrderID
LEFT JOIN Dishes d
    ON od.DishID = d.DishID
GROUP BY c.City
ORDER BY total_revenue DESC, total_orders DESC, c.City;

-- Event attendance count per event
SELECT
    e.EventID,
    e.Name,
    date(e.Date) AS event_date,
    e.Location,
    COUNT(ce.CustomerID) AS attendance_count
FROM Events e
LEFT JOIN CustomersEvents ce
    ON e.EventID = ce.EventID
GROUP BY e.EventID, e.Name, date(e.Date), e.Location
ORDER BY attendance_count DESC, e.Date;

-- List customers who attended events
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    e.EventID,
    e.Name AS event_name,
    datetime(e.Date) AS event_datetime,
    e.Location
FROM CustomersEvents ce
JOIN Customers c
    ON ce.CustomerID = c.CustomerID
JOIN Events e
    ON ce.EventID = e.EventID
ORDER BY e.Date, c.LastName, c.FirstName;

-- Compare stated favorite dish vs true most-ordered dish
WITH ranked_dishes AS (
    SELECT
        o.CustomerID,
        od.DishID,
        COUNT(*) AS times_ordered,
        RANK() OVER (
            PARTITION BY o.CustomerID
            ORDER BY COUNT(*) DESC, od.DishID
        ) AS dish_rank
    FROM Orders o
    JOIN OrdersDishes od
        ON o.OrderID = od.OrderID
    GROUP BY o.CustomerID, od.DishID
)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    fd.Name AS stated_favorite_dish,
    td.Name AS true_favorite_dish,
    rd.times_ordered,
    CASE
        WHEN c.FavoriteDish = rd.DishID THEN 'Match'
        ELSE 'No Match'
    END AS favorite_match_flag
FROM Customers c
LEFT JOIN Dishes fd
    ON c.FavoriteDish = fd.DishID
LEFT JOIN ranked_dishes rd
    ON c.CustomerID = rd.CustomerID
   AND rd.dish_rank = 1
LEFT JOIN Dishes td
    ON rd.DishID = td.DishID
ORDER BY c.CustomerID;

-- Most popular dish per customer
WITH customer_dish_counts AS (
    SELECT
        o.CustomerID,
        d.DishID,
        d.Name AS dish_name,
        COUNT(*) AS times_ordered,
        RANK() OVER (
            PARTITION BY o.CustomerID
            ORDER BY COUNT(*) DESC, d.Name
        ) AS rnk
    FROM Orders o
    JOIN OrdersDishes od
        ON o.OrderID = od.OrderID
    JOIN Dishes d
        ON od.DishID = d.DishID
    GROUP BY o.CustomerID, d.DishID, d.Name
)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    cdc.dish_name,
    cdc.times_ordered
FROM customer_dish_counts cdc
JOIN Customers c
    ON cdc.CustomerID = c.CustomerID
WHERE cdc.rnk = 1
ORDER BY c.CustomerID, cdc.dish_name;

-- New vs returning customers by month
WITH first_order AS (
    SELECT
        CustomerID,
        MIN(date(OrderDate)) AS first_order_date
    FROM Orders
    GROUP BY CustomerID
),
monthly_activity AS (
    SELECT DISTINCT
        CustomerID,
        strftime('%Y-%m', OrderDate) AS order_month
    FROM Orders
),
classified AS (
    SELECT
        ma.order_month,
        ma.CustomerID,
        CASE
            WHEN strftime('%Y-%m', fo.first_order_date) = ma.order_month THEN 'New'
            ELSE 'Returning'
        END AS customer_type
    FROM monthly_activity ma
    JOIN first_order fo
        ON ma.CustomerID = fo.CustomerID
)
SELECT
    order_month,
    SUM(CASE WHEN customer_type = 'New' THEN 1 ELSE 0 END) AS new_customers,
    SUM(CASE WHEN customer_type = 'Returning' THEN 1 ELSE 0 END) AS returning_customers
FROM classified
GROUP BY order_month
ORDER BY order_month;

-- Cohort retention by first order month
WITH first_order AS (
    SELECT
        CustomerID,
        date(MIN(OrderDate)) AS first_order_date
    FROM Orders
    GROUP BY CustomerID
),
customer_months AS (
    SELECT DISTINCT
        o.CustomerID,
        strftime('%Y-%m', o.OrderDate) AS activity_month
    FROM Orders o
),
cohort_data AS (
    SELECT
        fo.CustomerID,
        strftime('%Y-%m', fo.first_order_date) AS cohort_month,
        cm.activity_month,
        (
            (CAST(strftime('%Y', cm.activity_month || '-01') AS INTEGER) - CAST(strftime('%Y', fo.first_order_date) AS INTEGER)) * 12
            +
            (CAST(strftime('%m', cm.activity_month || '-01') AS INTEGER) - CAST(strftime('%m', fo.first_order_date) AS INTEGER))
        ) AS month_number
    FROM first_order fo
    JOIN customer_months cm
        ON fo.CustomerID = cm.CustomerID
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT CustomerID) AS cohort_customers
    FROM cohort_data
    WHERE month_number = 0
    GROUP BY cohort_month
)
SELECT
    cd.cohort_month,
    cd.month_number,
    COUNT(DISTINCT cd.CustomerID) AS retained_customers,
    cs.cohort_customers,
    ROUND(100.0 * COUNT(DISTINCT cd.CustomerID) / cs.cohort_customers, 2) AS retention_rate_pct
FROM cohort_data cd
JOIN cohort_size cs
    ON cd.cohort_month = cs.cohort_month
GROUP BY cd.cohort_month, cd.month_number, cs.cohort_customers
ORDER BY cd.cohort_month, cd.month_number;

-- RFM segmentation
WITH customer_metrics AS (
    SELECT
        c.CustomerID,
        c.FirstName,
        c.LastName,
        MAX(date(o.OrderDate)) AS last_order_date,
        COUNT(DISTINCT o.OrderID) AS frequency,
        ROUND(COALESCE(SUM(d.Price), 0), 2) AS monetary
    FROM Customers c
    LEFT JOIN Orders o
        ON c.CustomerID = o.CustomerID
    LEFT JOIN OrdersDishes od
        ON o.OrderID = od.OrderID
    LEFT JOIN Dishes d
        ON od.DishID = d.DishID
    GROUP BY c.CustomerID, c.FirstName, c.LastName
),
anchor_date AS (
    SELECT MAX(date(OrderDate)) AS max_order_date
    FROM Orders
),
rfm AS (
    SELECT
        cm.*,
        CASE
            WHEN cm.last_order_date IS NULL THEN NULL
            ELSE CAST(julianday(ad.max_order_date) - julianday(cm.last_order_date) AS INTEGER)
        END AS recency_days
    FROM customer_metrics cm
    CROSS JOIN anchor_date ad
)
SELECT
    CustomerID,
    FirstName,
    LastName,
    recency_days,
    frequency,
    monetary,
    CASE
        WHEN frequency >= 3 AND monetary >= 60 AND recency_days <= 30 THEN 'Champions'
        WHEN frequency >= 2 AND monetary >= 40 AND recency_days <= 60 THEN 'Loyal'
        WHEN recency_days > 90 THEN 'At Risk'
        ELSE 'Potential Loyalist'
    END AS rfm_segment
FROM rfm
ORDER BY monetary DESC, frequency DESC, recency_days;

-- Pareto analysis: % of revenue from top 20% of customers
WITH customer_revenue AS (
    SELECT
        c.CustomerID,
        ROUND(COALESCE(SUM(d.Price), 0), 2) AS customer_revenue
    FROM Customers c
    LEFT JOIN Orders o
        ON c.CustomerID = o.CustomerID
    LEFT JOIN OrdersDishes od
        ON o.OrderID = od.OrderID
    LEFT JOIN Dishes d
        ON od.DishID = d.DishID
    GROUP BY c.CustomerID
),
ranked AS (
    SELECT
        CustomerID,
        customer_revenue,
        ROW_NUMBER() OVER (ORDER BY customer_revenue DESC, CustomerID) AS rn,
        COUNT(*) OVER () AS total_customers,
        SUM(customer_revenue) OVER () AS total_revenue
    FROM customer_revenue
),
top_group AS (
    SELECT *
    FROM ranked
    WHERE rn <= CEIL(total_customers * 0.20)
)
SELECT
    COUNT(*) AS top_20pct_customer_count,
    ROUND(SUM(customer_revenue), 2) AS top_20pct_revenue,
    ROUND(MAX(total_revenue), 2) AS total_revenue,
    ROUND(100.0 * SUM(customer_revenue) / MAX(total_revenue), 2) AS pct_revenue_from_top_20pct
FROM top_group;

-- Menu engineering: popularity + revenue contribution
WITH dish_metrics AS (
    SELECT
        d.DishID,
        d.Name,
        COUNT(od.OrdersDishesID) AS times_ordered,
        ROUND(COUNT(od.OrdersDishesID) * d.Price, 2) AS revenue
    FROM Dishes d
    LEFT JOIN OrdersDishes od
        ON d.DishID = od.DishID
    GROUP BY d.DishID, d.Name, d.Price
),
totals AS (
    SELECT
        SUM(times_ordered) AS total_orders,
        SUM(revenue) AS total_revenue,
        AVG(times_ordered) AS avg_popularity,
        AVG(revenue) AS avg_revenue
    FROM dish_metrics
)
SELECT
    dm.DishID,
    dm.Name,
    dm.times_ordered,
    dm.revenue,
    ROUND(100.0 * dm.times_ordered / t.total_orders, 2) AS popularity_share_pct,
    ROUND(100.0 * dm.revenue / t.total_revenue, 2) AS revenue_share_pct,
    CASE
        WHEN dm.times_ordered >= t.avg_popularity AND dm.revenue >= t.avg_revenue THEN 'Star'
        WHEN dm.times_ordered >= t.avg_popularity AND dm.revenue < t.avg_revenue THEN 'Plowhorse'
        WHEN dm.times_ordered < t.avg_popularity AND dm.revenue >= t.avg_revenue THEN 'Puzzle'
        ELSE 'Dog'
    END AS menu_category
FROM dish_metrics dm
CROSS JOIN totals t
ORDER BY dm.revenue DESC, dm.times_ordered DESC;

-- Reservation to order conversion within 7 days
WITH reservation_orders AS (
    SELECT DISTINCT
        r.ReservationID,
        r.CustomerID
    FROM Reservations r
    JOIN Orders o
        ON r.CustomerID = o.CustomerID
       AND date(o.OrderDate) BETWEEN date(r.Date) AND date(r.Date, '+7 day')
)
SELECT
    COUNT(DISTINCT r.CustomerID) AS customers_with_reservations,
    COUNT(DISTINCT ro.CustomerID) AS customers_who_ordered_within_7_days,
    ROUND(
        100.0 * COUNT(DISTINCT ro.CustomerID) / COUNT(DISTINCT r.CustomerID),
        2
    ) AS conversion_rate_pct
FROM Reservations r
LEFT JOIN reservation_orders ro
    ON r.ReservationID = ro.ReservationID;
	
-- Event uplift: avg orders 30 days before vs 30 days after event attendance
WITH attendee_event_orders AS (
    SELECT
        ce.CustomerID,
        ce.EventID,
        e.Date AS event_date,
        SUM(CASE
            WHEN date(o.OrderDate) >= date(e.Date, '-30 day')
             AND date(o.OrderDate) < date(e.Date)
            THEN 1 ELSE 0
        END) AS orders_before_30d,
        SUM(CASE
            WHEN date(o.OrderDate) > date(e.Date)
             AND date(o.OrderDate) <= date(e.Date, '+30 day')
            THEN 1 ELSE 0
        END) AS orders_after_30d
    FROM CustomersEvents ce
    JOIN Events e
        ON ce.EventID = e.EventID
    LEFT JOIN Orders o
        ON ce.CustomerID = o.CustomerID
    GROUP BY ce.CustomerID, ce.EventID, e.Date
)
SELECT
    ROUND(AVG(orders_before_30d), 2) AS avg_orders_before_30d,
    ROUND(AVG(orders_after_30d), 2) AS avg_orders_after_30d,
    ROUND(AVG(orders_after_30d) - AVG(orders_before_30d), 2) AS avg_uplift
FROM attendee_event_orders;

-- Cumulative customer lifetime value over time
WITH order_values AS (
    SELECT
        o.CustomerID,
        date(o.OrderDate) AS order_date,
        o.OrderID,
        ROUND(SUM(d.Price), 2) AS order_value
    FROM Orders o
    JOIN OrdersDishes od
        ON o.OrderID = od.OrderID
    JOIN Dishes d
        ON od.DishID = d.DishID
    GROUP BY o.CustomerID, date(o.OrderDate), o.OrderID
)
SELECT
    ov.CustomerID,
    c.FirstName,
    c.LastName,
    ov.order_date,
    ov.OrderID,
    ov.order_value,
    ROUND(
        SUM(ov.order_value) OVER (
            PARTITION BY ov.CustomerID
            ORDER BY ov.order_date, ov.OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_customer_ltv
FROM order_values ov
JOIN Customers c
    ON ov.CustomerID = c.CustomerID
ORDER BY ov.CustomerID, ov.order_date, ov.OrderID;