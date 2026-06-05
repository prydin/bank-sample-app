-- Mock accounts and transactions for Northwind Bank
INSERT INTO accounts (name, type, account_number, balance_cents, currency, opened_at) VALUES
    ('Everyday Checking',    'checking', '100000001234',  528734, 'USD', '2021-03-14'),
    ('High-Yield Savings',   'savings',  '200000005678', 1842500, 'USD', '2020-07-02'),
    ('Vacation Fund',        'savings',  '200000009012',  312050, 'USD', '2023-01-18'),
    ('Platinum Credit Card', 'credit',   '400000003456', -127845, 'USD', '2022-11-09');

-- Transactions for Everyday Checking (account_id = 1)
INSERT INTO transactions (account_id, posted_at, description, merchant, category, amount_cents) VALUES
    (1, NOW() - INTERVAL '1 day',  'Direct deposit',        'Acme Corp Payroll',   'Income',     325000),
    (1, NOW() - INTERVAL '2 days', 'Grocery purchase',      'Whole Foods Market',  'Groceries',  -8742),
    (1, NOW() - INTERVAL '3 days', 'Coffee',                'Blue Bottle Coffee',  'Dining',     -625),
    (1, NOW() - INTERVAL '4 days', 'Electric bill',         'ConEd',               'Utilities',  -11240),
    (1, NOW() - INTERVAL '5 days', 'Transfer to Savings',   'Internal Transfer',   'Transfer',   -50000),
    (1, NOW() - INTERVAL '6 days', 'Rideshare',             'Uber',                'Transport',  -1830),
    (1, NOW() - INTERVAL '8 days', 'Restaurant',            'Joe''s Pizza',        'Dining',     -2450),
    (1, NOW() - INTERVAL '10 days','Pharmacy',              'CVS',                 'Health',     -1875),
    (1, NOW() - INTERVAL '12 days','Streaming subscription','Netflix',             'Entertainment', -1599),
    (1, NOW() - INTERVAL '14 days','Rent payment',          'Greystar Properties', 'Housing',    -185000);

-- Transactions for High-Yield Savings (account_id = 2)
INSERT INTO transactions (account_id, posted_at, description, merchant, category, amount_cents) VALUES
    (2, NOW() - INTERVAL '1 day',  'Interest payment',      'Northwind Bank',      'Interest',   3812),
    (2, NOW() - INTERVAL '5 days', 'Transfer from Checking','Internal Transfer',   'Transfer',   50000),
    (2, NOW() - INTERVAL '20 days','Transfer from Checking','Internal Transfer',   'Transfer',   75000),
    (2, NOW() - INTERVAL '32 days','Interest payment',      'Northwind Bank',      'Interest',   3650),
    (2, NOW() - INTERVAL '50 days','Transfer from Checking','Internal Transfer',   'Transfer',  100000);

-- Transactions for Vacation Fund (account_id = 3)
INSERT INTO transactions (account_id, posted_at, description, merchant, category, amount_cents) VALUES
    (3, NOW() - INTERVAL '2 days', 'Monthly contribution',  'Internal Transfer',   'Transfer',   25000),
    (3, NOW() - INTERVAL '33 days','Monthly contribution',  'Internal Transfer',   'Transfer',   25000),
    (3, NOW() - INTERVAL '64 days','Monthly contribution',  'Internal Transfer',   'Transfer',   25000),
    (3, NOW() - INTERVAL '95 days','Initial deposit',       'Internal Transfer',   'Transfer',  100000);

-- Transactions for Platinum Credit Card (account_id = 4)
INSERT INTO transactions (account_id, posted_at, description, merchant, category, amount_cents) VALUES
    (4, NOW() - INTERVAL '1 day',  'Online purchase',       'Amazon',              'Shopping',   -6499),
    (4, NOW() - INTERVAL '2 days', 'Gas station',           'Shell',               'Transport',  -5230),
    (4, NOW() - INTERVAL '3 days', 'Restaurant',            'The Cheesecake Factory','Dining',   -8745),
    (4, NOW() - INTERVAL '5 days', 'Airline ticket',        'Delta Airlines',      'Travel',    -42800),
    (4, NOW() - INTERVAL '9 days', 'Hotel booking',         'Marriott',            'Travel',    -31500),
    (4, NOW() - INTERVAL '12 days','Statement payment',     'Payment - Thank You', 'Payment',    150000),
    (4, NOW() - INTERVAL '15 days','Electronics',           'Best Buy',            'Shopping',   -24999),
    (4, NOW() - INTERVAL '20 days','Subscription',          'Spotify',             'Entertainment', -999);
