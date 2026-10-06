
======================================================

======================================================

SELECT status,
       COUNT(*) AS transactions,
       ROUND(COUNT(*)*100.0/
       (SELECT COUNT(*) FROM transactions),2)
       AS percentage
FROM transactions
GROUP BY status;



======================================================

======================================================

SELECT 
    failure_reason,
    COUNT(*) AS failed_transactions,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) 
    FROM transactions 
    WHERE status = "failed"), 2) AS percentage
FROM  transactions
WHERE status = "failed"
GROUP BY failure_reason
ORDER BY failed_transactions DESC;

======================================================

======================================================


SELECT
    CASE
        WHEN failure_reason IN ('incorrect_pin', 'account_blocked')
            THEN 'Customer-related'
        WHEN failure_reason IN ('network_error', 'bank_down')
            THEN 'Technical/System-related'
    END AS failure_owner,

    COUNT(*) AS failed_transactions,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM transactions
         WHERE status = 'failed'),
        2
    ) AS percentage

FROM transactions

WHERE status = 'failed'

GROUP BY failure_owner;

======================================================

======================================================

SELECT
    channel,
    COUNT(*) AS total_transactions,

    ROUND(
        SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS success_rate,

    ROUND(
        SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS failure_rate,

    ROUND(
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS pending_rate

FROM transactions

GROUP BY channel

ORDER BY success_rate;

======================================================

======================================================


SELECT
    HOUR(timestamp) AS hour,
    COUNT(*) AS total_transactions,

    ROUND(
        SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS success_rate,

    ROUND(
        SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS failure_rate,

    ROUND(
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS pending_rate

FROM transactions

GROUP BY HOUR(timestamp)

ORDER BY hour;



======================================================

======================================================



SELECT
    a.bank_name,
    COUNT(*) AS total_transactions,

    ROUND(
        SUM(CASE WHEN t.status = 'success' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS success_rate,

    ROUND(
        SUM(CASE WHEN t.status = 'failed' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS failure_rate,

    ROUND(
        SUM(CASE WHEN t.status = 'pending' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS pending_rate

FROM transactions t

JOIN accounts a
    ON t.upi_id = a.upi_id

GROUP BY a.bank_name

ORDER BY failure_rate DESC;



======================================================

======================================================



SELECT
    fraud_flag,
    COUNT(*) AS transactions,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM transactions),
        2
    ) AS percentage

FROM transactions

GROUP BY fraud_flag;


======================================================

======================================================

SELECT
    d.is_rooted,
    COUNT(*) AS total_transactions,

    SUM(CASE WHEN t.fraud_flag = 1 THEN 1 ELSE 0 END)
        AS fraud_transactions,

    ROUND(
        SUM(CASE WHEN t.fraud_flag = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS fraud_rate

FROM transactions t

JOIN devices d
    ON t.device_id = d.device_id

GROUP BY d.is_rooted;


======================================================

======================================================


SELECT
    CASE
        WHEN c.risk_score < 0.2 THEN '0.0 - 0.2'
        WHEN c.risk_score < 0.4 THEN '0.2 - 0.4'
        WHEN c.risk_score < 0.6 THEN '0.4 - 0.6'
        WHEN c.risk_score < 0.8 THEN '0.6 - 0.8'
        ELSE '0.8 - 1.0'
    END AS risk_group,

    COUNT(*) AS total_transactions,

    SUM(CASE WHEN t.fraud_flag = 1 THEN 1 ELSE 0 END)
        AS fraud_transactions,

    ROUND(
        SUM(CASE WHEN t.fraud_flag = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS fraud_rate

FROM transactions t

JOIN customers c
    ON t.customer_id = c.customer_id

GROUP BY risk_group

ORDER BY risk_group;

======================================================

======================================================

SELECT
    MIN(amount) AS minimum_amount,
    MAX(amount) AS maximum_amount,
    ROUND(AVG(amount), 2) AS average_amount
FROM transactions;

======================================================

======================================================


SELECT
    CASE
        WHEN amount < 25 THEN '1. Below 25'
        WHEN amount < 50 THEN '2. 25 - 50'
        WHEN amount < 100 THEN '3. 50 - 100'
        WHEN amount < 250 THEN '4. 100 - 250'
        ELSE '5. 250+'
    END AS amount_group,

    COUNT(*) AS total_transactions,

    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END)
        AS fraud_transactions,

    ROUND(
        SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS fraud_rate

FROM transactions

GROUP BY amount_group

ORDER BY amount_group;

======================================================

======================================================

sELECT
    CASE
        WHEN m.risk_score < 0.2 THEN '0.0 - 0.2'
        WHEN m.risk_score < 0.4 THEN '0.2 - 0.4'
        WHEN m.risk_score < 0.6 THEN '0.4 - 0.6'
        WHEN m.risk_score < 0.8 THEN '0.6 - 0.8'
        ELSE '0.8 - 1.0'
    END AS merchant_risk_group,

    COUNT(*) AS total_transactions,

    SUM(
        CASE WHEN t.fraud_flag = 1 THEN 1 ELSE 0 END
    ) AS fraud_transactions,

    ROUND(
        SUM(CASE WHEN t.fraud_flag = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS fraud_rate

FROM transactions t

JOIN merchants m
    ON t.merchant_id = m.merchant_id

WHERE t.transaction_type = 'merchant_payment'

GROUP BY merchant_risk_group

ORDER BY merchant_risk_group;

======================================================

======================================================

SELECT
    d.device_type,
    d.is_rooted,

    COUNT(*) AS total_transactions,

    SUM(
        CASE WHEN t.fraud_flag = 1 THEN 1 ELSE 0 END
    ) AS fraud_transactions,

    ROUND(
        SUM(CASE WHEN t.fraud_flag = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS fraud_rate

FROM transactions t

JOIN devices d
    ON t.device_id = d.device_id

GROUP BY
    d.device_type,
    d.is_rooted

ORDER BY
    d.device_type,
    d.is_rooted;

======================================================

======================================================

SELECT
    d.is_rooted,
    t.fraud_flag,
    COUNT(*) AS transactions

FROM transactions t

JOIN devices d
    ON t.device_id = d.device_id

GROUP BY
    d.is_rooted,
    t.fraud_flag

ORDER BY
    d.is_rooted,
    t.fraud_flag;