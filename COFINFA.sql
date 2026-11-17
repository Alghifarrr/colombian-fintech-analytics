-- =========================================================
-- Colombian Fintech Customer & Transaction Analysis
-- =========================================================

-- Tabel customer
CREATE TABLE customers (
    customer_id BIGINT PRIMARY KEY,
    age BIGINT,
    gender TEXT,
    location TEXT,
    income_bracket TEXT,
    occupation TEXT,
    education_level TEXT,
    marital_status TEXT,
    household_size BIGINT,
    acquisition_channel TEXT,
    customer_segment TEXT,
    savings_account BOOLEAN,
    credit_card BOOLEAN,
    personal_loan BOOLEAN,
    investment_account BOOLEAN,
    insurance_product BOOLEAN,
    active_products BIGINT,
    app_logins_frequency BIGINT,
    feature_usage_diversity BIGINT,
    bill_payment_user BOOLEAN,
    auto_savings_enabled BOOLEAN,
    credit_utilization_ratio DOUBLE PRECISION,
    international_transactions BIGINT,
    failed_transactions BIGINT,
    tx_count BIGINT,
    avg_tx_value DOUBLE PRECISION,
    total_tx_volume BIGINT,
    first_tx DATE,
    last_tx DATE,
    base_satisfaction DOUBLE PRECISION,
    tx_satisfaction DOUBLE PRECISION,
    product_satisfaction DOUBLE PRECISION,
    satisfaction_score BIGINT,
    nps_score BIGINT,
    last_survey_date DATE,
    support_tickets_count BIGINT,
    resolved_tickets_ratio DOUBLE PRECISION,
    app_store_rating DOUBLE PRECISION,
    feedback_sentiment TEXT,
    feature_requests TEXT,
    complaint_topics TEXT,
    clv_segment TEXT,
    monthly_transaction_count DOUBLE PRECISION,
    average_transaction_value DOUBLE PRECISION,
    total_transaction_volume BIGINT,
    transaction_frequency DOUBLE PRECISION,
    last_transaction_date DATE,
    preferred_transaction_type TEXT,
    first_transaction_date DATE,
    weekend_transaction_ratio DOUBLE PRECISION,
    avg_daily_transactions DOUBLE PRECISION,
    customer_tenure DOUBLE PRECISION,
    churn_probability DOUBLE PRECISION,
    customer_lifetime_value DOUBLE PRECISION
);


-- Tabel transaksi
CREATE TABLE transactions (
    transaction_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT,
    "date" DATE,
    amount BIGINT,
    type TEXT
);


-- Apakah aktivitas transaksi tumbuh atau menurun dari bulan ke bulan?

WITH monthly_metrics AS (
    SELECT
        DATE_TRUNC('month', t."date")::date AS transaction_month,
        COUNT(*) AS transaction_count,
        COUNT(DISTINCT t.customer_id) AS active_customers,
        SUM(t.amount) AS total_transaction_amount,
        AVG(t.amount) AS average_transaction_amount
    FROM transactions AS t
    WHERE t."date" IS NOT NULL
    GROUP BY DATE_TRUNC('month', t."date")::date
),
monthly_with_previous AS (
    SELECT
        *,
        LAG(transaction_count) OVER (ORDER BY transaction_month)
            AS previous_month_transactions,
        LAG(total_transaction_amount) OVER (ORDER BY transaction_month)
            AS previous_month_amount
    FROM monthly_metrics
)

SELECT
    transaction_month,
    transaction_count,
    active_customers,
    total_transaction_amount,
    ROUND(average_transaction_amount, 2) AS average_transaction_amount,
    ROUND(
        100.0 * (transaction_count - previous_month_transactions)
        / NULLIF(previous_month_transactions, 0),
        2
    ) AS transaction_count_change_pct,
    ROUND(
        100.0 * (total_transaction_amount - previous_month_amount)
        / NULLIF(previous_month_amount, 0),
        2
    ) AS transaction_amount_change_pct
FROM monthly_with_previous
ORDER BY transaction_month;


-- Segmen customer mana yang paling aktif dan memiliki CLV tertinggi?

SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    ROUND(AVG(c.tx_count), 2) AS average_transaction_count,
    ROUND(AVG(c.total_tx_volume), 2) AS average_customer_transaction_volume,
    ROUND(AVG(c.customer_lifetime_value)::numeric, 2) AS average_customer_lifetime_value,
    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY c.customer_lifetime_value)
        AS median_customer_lifetime_value
FROM customers AS c
GROUP BY c.customer_segment
ORDER BY average_customer_lifetime_value DESC;


-- Produk apa yang paling banyak digunakan, dan berapa tingkat adopsinya?

WITH product_usage AS (
    SELECT
        c.customer_id,
        p.product_name,
        p.is_active
    FROM customers AS c
    CROSS JOIN LATERAL (
        VALUES
            ('savings_account', c.savings_account),
            ('credit_card', c.credit_card),
            ('personal_loan', c.personal_loan),
            ('investment_account', c.investment_account),
            ('insurance_product', c.insurance_product)
    ) AS p(product_name, is_active)
)

SELECT
    product_name,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT customer_id)
        FILTER (WHERE is_active IS TRUE) AS customers_using_product,
    ROUND(
        100.0 * COUNT(DISTINCT customer_id)
            FILTER (WHERE is_active IS TRUE)
        / NULLIF(COUNT(DISTINCT customer_id), 0),
        2
    ) AS adoption_rate_pct
FROM product_usage
GROUP BY product_name
ORDER BY adoption_rate_pct DESC;


-- Bagaimana karakteristik customer dengan skor risiko churn tertinggi?

WITH scored_customers AS (
    SELECT
        c.customer_id,
        c.customer_segment,
        c.churn_probability,
        c.tx_count,
        c.app_logins_frequency,
        c.satisfaction_score,
        c.customer_lifetime_value,
        NTILE(4) OVER (ORDER BY c.churn_probability) AS risk_quartile
    FROM customers AS c
    WHERE c.churn_probability IS NOT NULL
)

SELECT
    risk_quartile,
    customer_segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(AVG(churn_probability)::numeric, 3) AS average_churn_probability,
    ROUND(AVG(tx_count), 2) AS average_transaction_count,
    ROUND(AVG(app_logins_frequency), 2) AS average_app_logins,
    ROUND(AVG(satisfaction_score), 2) AS average_satisfaction_score,
    ROUND(AVG(customer_lifetime_value)::numeric, 2) AS average_customer_lifetime_value
FROM scored_customers
GROUP BY risk_quartile, customer_segment
ORDER BY risk_quartile DESC, customer_count DESC;


-- Apakah pengalaman layanan dan kepuasan berbeda antar-segmen?

SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    COUNT(DISTINCT c.customer_id)
        FILTER (WHERE c.support_tickets_count > 0) AS customers_with_tickets,
    ROUND(
        AVG(c.resolved_tickets_ratio)
            FILTER (WHERE c.support_tickets_count > 0)::numeric,
        3
    ) AS average_resolved_tickets_ratio,
    ROUND(AVG(c.satisfaction_score), 2) AS average_satisfaction_score,
    ROUND(AVG(c.nps_score), 2) AS average_nps_score,
    ROUND(AVG(c.app_store_rating)::numeric, 2) AS average_app_store_rating
FROM customers AS c
GROUP BY c.customer_segment
ORDER BY average_satisfaction_score DESC;


-- Acquisition channel mana yang mendatangkan customer dengan aktivitas dan CLV lebih tinggi?

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    ROUND(AVG(c.tx_count), 2) AS average_transaction_count,
    ROUND(AVG(c.total_tx_volume), 2) AS average_customer_transaction_volume,
    ROUND(AVG(c.customer_lifetime_value)::numeric, 2) AS average_customer_lifetime_value,
    ROUND(AVG(c.churn_probability)::numeric, 3) AS average_churn_probability
FROM customers AS c
GROUP BY c.acquisition_channel
ORDER BY average_customer_lifetime_value DESC;


-- Jenis transaksi apa yang paling sering digunakan dan bernilai besar?

SELECT
    t."type" AS transaction_type,
    COUNT(*) AS transaction_count,
    COUNT(DISTINCT t.customer_id) AS unique_customers,
    SUM(t.amount) AS total_transaction_amount,
    ROUND(AVG(t.amount), 2) AS average_transaction_amount,
    COUNT(*) FILTER (WHERE t.amount < 0) AS negative_amount_rows,
    COUNT(*) FILTER (WHERE t.amount = 0) AS zero_amount_rows
FROM transactions AS t
GROUP BY t."type"
ORDER BY transaction_count DESC;


-- Berapa banyak customer yang tetap bertransaksi setelah pertama kali aktif?

WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', "date")::date AS transaction_month
    FROM transactions
    WHERE "date" IS NOT NULL
),
customer_cohorts AS (
    SELECT
        customer_id,
        MIN(transaction_month) AS cohort_month
    FROM customer_months
    GROUP BY customer_id
),
cohort_activity AS (
    SELECT
        cm.customer_id,
        cc.cohort_month,
        cm.transaction_month,
        (
            EXTRACT(YEAR FROM AGE(cm.transaction_month, cc.cohort_month)) * 12
            + EXTRACT(MONTH FROM AGE(cm.transaction_month, cc.cohort_month))
        )::int AS months_since_first_transaction
    FROM customer_months AS cm
    JOIN customer_cohorts AS cc
        ON cm.customer_id = cc.customer_id
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
)

SELECT
    ca.cohort_month,
    ca.months_since_first_transaction,
    cs.cohort_size,
    COUNT(DISTINCT ca.customer_id) AS active_customers,
    ROUND(
        100.0 * COUNT(DISTINCT ca.customer_id)
        / NULLIF(cs.cohort_size, 0),
        2
    ) AS retention_rate_pct
FROM cohort_activity AS ca
JOIN cohort_sizes AS cs
    ON ca.cohort_month = cs.cohort_month
GROUP BY
    ca.cohort_month,
    ca.months_since_first_transaction,
    cs.cohort_size
ORDER BY
    ca.cohort_month,
    ca.months_since_first_transaction;


-- Customer berisiko churn mana yang memiliki nilai bisnis paling tinggi?

WITH clv_threshold AS (
    SELECT
        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY customer_lifetime_value)
            AS high_clv_threshold
    FROM customers
    WHERE customer_lifetime_value IS NOT NULL
)

SELECT
    c.customer_id,
    c.customer_segment,
    c.location,
    c.churn_probability,
    c.customer_lifetime_value,
    c.tx_count,
    c.last_transaction_date,
    c.satisfaction_score,
    c.nps_score,
    c.support_tickets_count,
    CASE
        WHEN c.churn_probability >= 0.70
            AND c.customer_lifetime_value >= t.high_clv_threshold
            THEN 'Prioritas sangat tinggi'
        WHEN c.churn_probability >= 0.50
            THEN 'Prioritas tinggi'
        ELSE 'Pantau'
    END AS retention_priority
FROM customers AS c
CROSS JOIN clv_threshold AS t
WHERE c.churn_probability IS NOT NULL
ORDER BY
    c.churn_probability DESC,
    c.customer_lifetime_value DESC;


-- Pasangan produk apa yang paling sering dimiliki customer secara bersamaan?

WITH customer_products AS (
    SELECT
        c.customer_id,
        p.product_name
    FROM customers AS c
    CROSS JOIN LATERAL (
        VALUES
            ('Savings account', c.savings_account),
            ('Credit card', c.credit_card),
            ('Personal loan', c.personal_loan),
            ('Investment account', c.investment_account),
            ('Insurance', c.insurance_product)
    ) AS p(product_name, is_active)
    WHERE p.is_active IS TRUE
),
product_pairs AS (
    SELECT
        p1.product_name AS product_1,
        p2.product_name AS product_2,
        COUNT(DISTINCT p1.customer_id) AS customers_with_both
    FROM customer_products AS p1
    JOIN customer_products AS p2
        ON p1.customer_id = p2.customer_id
        AND p1.product_name < p2.product_name
    GROUP BY
        p1.product_name,
        p2.product_name
),
customer_count AS (
    SELECT COUNT(DISTINCT customer_id) AS total_customers
    FROM customers
)

SELECT
    pp.product_1,
    pp.product_2,
    pp.customers_with_both,
    ROUND(
        100.0 * pp.customers_with_both
        / NULLIF(cc.total_customers, 0),
        2
    ) AS share_of_all_customers_pct
FROM product_pairs AS pp
CROSS JOIN customer_count AS cc
ORDER BY pp.customers_with_both DESC;


-- Channel akuisisi mana yang membawa customer berkualitas lebih baik?

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customer_count,

    ROUND(
        AVG(c.customer_lifetime_value)::numeric,
        2
    ) AS average_customer_lifetime_value,

    ROUND(
        AVG(c.churn_probability)::numeric,
        3
    ) AS average_churn_probability,

    ROUND(
        AVG(c.tx_count)::numeric,
        2
    ) AS average_transaction_count,

    ROUND(
        100.0 * COUNT(DISTINCT c.customer_id)
            FILTER (WHERE c.last_transaction_date >= DATE '2023-10-01')
        / NULLIF(COUNT(DISTINCT c.customer_id), 0),
        2
    ) AS active_in_last_quarter_pct,

    ROUND(
        AVG(c.satisfaction_score)::numeric,
        2
    ) AS average_satisfaction_score
FROM customers AS c
GROUP BY c.acquisition_channel
ORDER BY average_customer_lifetime_value DESC;


