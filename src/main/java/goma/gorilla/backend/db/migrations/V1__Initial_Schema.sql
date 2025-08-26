-- V1__Initial_Schema.sql
-- Initial database schema for GOMA Backend

-- Tenants table
CREATE TABLE tenants (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(50) UNIQUE,
    description VARCHAR(500),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0
);

-- Tenant settings table
CREATE TABLE tenant_settings (
    tenant_id BIGINT NOT NULL,
    setting_key VARCHAR(255) NOT NULL,
    setting_value VARCHAR(1000),
    PRIMARY KEY (tenant_id, setting_key),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

-- Permissions table
CREATE TABLE permissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    `key` VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    module VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0
);

-- Roles table
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    tenant_id BIGINT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    UNIQUE KEY uk_role_code_tenant (code, tenant_id)
);

-- Role permissions junction table
CREATE TABLE role_permissions (
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);

-- Users table
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING') NOT NULL DEFAULT 'ACTIVE',
    tenant_id BIGINT NOT NULL,
    last_login_at TIMESTAMP NULL,
    password_changed_at TIMESTAMP NULL,
    failed_login_attempts INT DEFAULT 0,
    account_locked_until TIMESTAMP NULL,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    UNIQUE KEY idx_user_username_tenant (username, tenant_id),
    UNIQUE KEY idx_user_email_tenant (email, tenant_id)
);

-- User roles junction table
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- Products table
CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(100) NOT NULL,
    name VARCHAR(200) NOT NULL,
    description VARCHAR(1000),
    unit VARCHAR(50),
    size VARCHAR(100),
    code VARCHAR(50),
    category VARCHAR(100),
    attributes JSON,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    tenant_id BIGINT NOT NULL,
    barcode VARCHAR(255),
    weight DECIMAL(10,3),
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    UNIQUE KEY idx_product_sku_tenant (sku, tenant_id),
    UNIQUE KEY idx_product_code_tenant (code, tenant_id)
);

-- Price lists table
CREATE TABLE price_lists (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    level ENUM('FACTORY', 'DISTRIBUTOR') NOT NULL,
    currency VARCHAR(3) NOT NULL,
    valid_from DATE,
    valid_to DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    tenant_id BIGINT NOT NULL,
    description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

-- Price list items table
CREATE TABLE price_list_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    price_list_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    base_price DECIMAL(15,2) NOT NULL,
    min_price DECIMAL(15,2),
    taxes JSON,
    discounts JSON,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (price_list_id) REFERENCES price_lists(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    UNIQUE KEY idx_price_list_product (price_list_id, product_id)
);

-- Warehouses table (L1)
CREATE TABLE warehouses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) NOT NULL,
    address VARCHAR(500),
    city VARCHAR(100),
    region VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(100),
    manager_id BIGINT,
    tenant_id BIGINT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    attributes JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (manager_id) REFERENCES users(id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    UNIQUE KEY idx_warehouse_code_tenant (code, tenant_id)
);

-- Distributors table
CREATE TABLE distributors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(200) NOT NULL,
    contact_name VARCHAR(100),
    mobile VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(500),
    city VARCHAR(100),
    region VARCHAR(100),
    postal_code VARCHAR(20),
    bank_accounts JSON,
    momo_accounts JSON,
    credit_limit DECIMAL(15,2) DEFAULT 0.00,
    credit_balance DECIMAL(15,2) DEFAULT 0.00,
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING_APPROVAL', 'CREDIT_HOLD') NOT NULL DEFAULT 'ACTIVE',
    tenant_id BIGINT NOT NULL,
    tax_number VARCHAR(50),
    business_license VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    UNIQUE KEY idx_distributor_email_tenant (email, tenant_id)
);

-- Stores table (L2)
CREATE TABLE stores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    distributor_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) NOT NULL,
    address VARCHAR(500),
    city VARCHAR(100),
    region VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(100),
    manager_id BIGINT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    attributes JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (distributor_id) REFERENCES distributors(id) ON DELETE CASCADE,
    FOREIGN KEY (manager_id) REFERENCES users(id),
    UNIQUE KEY idx_store_code_distributor (code, distributor_id)
);

-- Inventory table
CREATE TABLE inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    location_type ENUM('L1', 'L2') NOT NULL,
    location_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    qty_on_hand INT NOT NULL DEFAULT 0,
    qty_reserved INT NOT NULL DEFAULT 0,
    reorder_level INT,
    max_level INT,
    avg_unit_cost DECIMAL(15,2) DEFAULT 0.00,
    last_stock_in TIMESTAMP NULL,
    last_stock_out TIMESTAMP NULL,
    tenant_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    UNIQUE KEY idx_inventory_location_product (location_type, location_id, product_id),
    KEY idx_inventory_product (product_id),
    KEY idx_inventory_location (location_type, location_id)
);

-- Stock transactions table
CREATE TABLE stock_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('STOCK_IN', 'STOCK_OUT', 'TRANSFER', 'ADJUSTMENT') NOT NULL,
    level ENUM('L1', 'L2') NOT NULL,
    from_location_id BIGINT,
    to_location_id BIGINT,
    product_id BIGINT NOT NULL,
    qty INT NOT NULL,
    unit_cost DECIMAL(15,2),
    ref_type VARCHAR(50),
    ref_id BIGINT,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NOT NULL,
    notes VARCHAR(500),
    tenant_id BIGINT NOT NULL,
    batch_number VARCHAR(255),
    expiry_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    KEY idx_stock_txn_product (product_id),
    KEY idx_stock_txn_type_level (type, level),
    KEY idx_stock_txn_timestamp (timestamp),
    KEY idx_stock_txn_ref (ref_type, ref_id)
);

-- Orders table
CREATE TABLE orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    number VARCHAR(50) NOT NULL UNIQUE,
    level ENUM('L1', 'L2') NOT NULL,
    channel ENUM('WEB', 'MOBILE', 'PHONE', 'MANUAL') NOT NULL DEFAULT 'WEB',
    distributor_id BIGINT,
    store_id BIGINT,
    status ENUM('DRAFT', 'SUBMITTED', 'APPROVED', 'FULFILLING', 'FULFILLED', 'CANCELLED', 'REJECTED') NOT NULL DEFAULT 'DRAFT',
    currency VARCHAR(3) NOT NULL,
    totals JSON,
    created_by BIGINT NOT NULL,
    approved_by BIGINT,
    approved_at TIMESTAMP NULL,
    submitted_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    notes VARCHAR(500),
    cancellation_reason VARCHAR(500),
    tenant_id BIGINT NOT NULL,
    delivery_date TIMESTAMP NULL,
    delivery_address VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (distributor_id) REFERENCES distributors(id),
    FOREIGN KEY (store_id) REFERENCES stores(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    KEY idx_order_number (number),
    KEY idx_order_status (status),
    KEY idx_order_distributor (distributor_id),
    KEY idx_order_store (store_id),
    KEY idx_order_created_at (created_at)
);

-- Order lines table
CREATE TABLE order_lines (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    qty INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount DECIMAL(15,2) DEFAULT 0.00,
    tax DECIMAL(15,2) DEFAULT 0.00,
    line_total DECIMAL(15,2),
    notes VARCHAR(500),
    fulfilled_qty INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    KEY idx_order_line_order (order_id),
    KEY idx_order_line_product (product_id)
);

-- Invoices table
CREATE TABLE invoices (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    number VARCHAR(50) NOT NULL UNIQUE,
    order_id BIGINT NOT NULL,
    distributor_id BIGINT,
    store_id BIGINT,
    status ENUM('DRAFT', 'ISSUED', 'PAID', 'PARTIAL', 'VOID', 'OVERDUE') NOT NULL DEFAULT 'DRAFT',
    amounts JSON,
    issued_at TIMESTAMP NULL,
    due_date DATE,
    issued_by BIGINT,
    tenant_id BIGINT NOT NULL,
    notes VARCHAR(500),
    currency VARCHAR(3),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (distributor_id) REFERENCES distributors(id),
    FOREIGN KEY (store_id) REFERENCES stores(id),
    FOREIGN KEY (issued_by) REFERENCES users(id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    KEY idx_invoice_number (number),
    KEY idx_invoice_order (order_id),
    KEY idx_invoice_distributor (distributor_id),
    KEY idx_invoice_store (store_id),
    KEY idx_invoice_status (status)
);

-- Payments table
CREATE TABLE payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_id BIGINT NOT NULL,
    method ENUM('BANK', 'MOMO', 'CASH', 'CREDIT') NOT NULL,
    txn_ref VARCHAR(100),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    paid_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    posted_by BIGINT NOT NULL,
    notes VARCHAR(500),
    tenant_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id),
    FOREIGN KEY (posted_by) REFERENCES users(id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    KEY idx_payment_invoice (invoice_id),
    KEY idx_payment_method (method),
    KEY idx_payment_paid_at (paid_at)
);

-- Transfers table
CREATE TABLE transfers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    from_level ENUM('L1', 'L2') NOT NULL,
    from_location_id BIGINT NOT NULL,
    to_level ENUM('L1', 'L2') NOT NULL,
    to_location_id BIGINT NOT NULL,
    status ENUM('DRAFT', 'APPROVED', 'IN_TRANSIT', 'RECEIVED', 'CANCELLED', 'REJECTED') NOT NULL DEFAULT 'DRAFT',
    created_by BIGINT NOT NULL,
    approved_by BIGINT,
    approved_at TIMESTAMP NULL,
    shipped_at TIMESTAMP NULL,
    received_at TIMESTAMP NULL,
    notes VARCHAR(500),
    tenant_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    KEY idx_transfer_from_location (from_level, from_location_id),
    KEY idx_transfer_to_location (to_level, to_location_id),
    KEY idx_transfer_status (status)
);

-- Adjustments table
CREATE TABLE adjustments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    level ENUM('L1', 'L2') NOT NULL,
    location_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    qty_delta INT NOT NULL,
    reason ENUM('LOSS', 'DAMAGE', 'COUNT', 'EXPIRY', 'THEFT', 'OTHER') NOT NULL,
    note VARCHAR(500),
    created_by BIGINT NOT NULL,
    approved_by BIGINT,
    approved_at TIMESTAMP NULL,
    tenant_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    KEY idx_adjustment_location (level, location_id),
    KEY idx_adjustment_product (product_id)
);

-- Daily closes table
CREATE TABLE daily_closes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    level ENUM('L1', 'L2') NOT NULL,
    location_id BIGINT NOT NULL,
    date DATE NOT NULL,
    reported_sales DECIMAL(15,2) DEFAULT 0.00,
    cash_total DECIMAL(15,2) DEFAULT 0.00,
    discrepancies VARCHAR(1000),
    closed_by BIGINT NOT NULL,
    approved_by BIGINT,
    approved_at TIMESTAMP NULL,
    status ENUM('SUBMITTED', 'APPROVED', 'REJECTED') NOT NULL DEFAULT 'SUBMITTED',
    notes VARCHAR(500),
    tenant_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (closed_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    UNIQUE KEY idx_daily_close_location_date (level, location_id, date),
    KEY idx_daily_close_status (status),
    KEY idx_daily_close_date (date)
);

-- Audit logs table
CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    actor_id BIGINT NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity VARCHAR(100) NOT NULL,
    entity_id BIGINT,
    before_data JSON,
    after_data JSON,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    tenant_id BIGINT NOT NULL,
    description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (actor_id) REFERENCES users(id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    KEY idx_audit_actor (actor_id),
    KEY idx_audit_entity (entity, entity_id),
    KEY idx_audit_action (action),
    KEY idx_audit_timestamp (timestamp)
);

-- Notifications table
CREATE TABLE notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('ORDER_APPROVED', 'ORDER_CANCELLED', 'STOCK_LOW', 'PAYMENT_RECEIVED', 'DAILY_CLOSE_DUE', 'TRANSFER_SHIPPED', 'TRANSFER_RECEIVED') NOT NULL,
    channel ENUM('EMAIL', 'SMS', 'WEBHOOK', 'IN_APP') NOT NULL,
    recipient_id BIGINT,
    recipient_address VARCHAR(200),
    subject VARCHAR(200) NOT NULL,
    message VARCHAR(1000),
    payload JSON,
    status ENUM('PENDING', 'SENT', 'FAILED', 'DELIVERED') NOT NULL DEFAULT 'PENDING',
    sent_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    failed_at TIMESTAMP NULL,
    error_message VARCHAR(500),
    retry_count INT DEFAULT 0,
    next_retry_at TIMESTAMP NULL,
    tenant_id BIGINT NOT NULL,
    reference_type VARCHAR(100),
    reference_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (recipient_id) REFERENCES users(id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    KEY idx_notification_type (type),
    KEY idx_notification_channel (channel),
    KEY idx_notification_status (status),
    KEY idx_notification_recipient (recipient_id),
    KEY idx_notification_created (created_at)
);

-- Insert default permissions
INSERT INTO permissions (`key`, name, description, module) VALUES
-- User Management
('users.create', 'Create Users', 'Create new users in the system', 'USER_MANAGEMENT'),
('users.read', 'View Users', 'View user information', 'USER_MANAGEMENT'),
('users.update', 'Update Users', 'Update user information', 'USER_MANAGEMENT'),
('users.delete', 'Delete Users', 'Delete users from the system', 'USER_MANAGEMENT'),

-- Role Management
('roles.create', 'Create Roles', 'Create new roles', 'ROLE_MANAGEMENT'),
('roles.read', 'View Roles', 'View role information', 'ROLE_MANAGEMENT'),
('roles.update', 'Update Roles', 'Update role information', 'ROLE_MANAGEMENT'),
('roles.delete', 'Delete Roles', 'Delete roles', 'ROLE_MANAGEMENT'),

-- Product Management
('products.create', 'Create Products', 'Create new products', 'INVENTORY'),
('products.read', 'View Products', 'View product information', 'INVENTORY'),
('products.update', 'Update Products', 'Update product information', 'INVENTORY'),
('products.delete', 'Delete Products', 'Delete products', 'INVENTORY'),

-- Pricing
('pricing.create', 'Create Price Lists', 'Create and manage price lists', 'PRICING'),
('pricing.read', 'View Pricing', 'View price information', 'PRICING'),
('pricing.update', 'Update Pricing', 'Update price lists and prices', 'PRICING'),
('pricing.delete', 'Delete Price Lists', 'Delete price lists', 'PRICING'),

-- Inventory L1
('inventory.l1.create', 'L1 Stock In', 'Perform stock-in operations at L1', 'INVENTORY'),
('inventory.l1.read', 'View L1 Inventory', 'View L1 inventory levels', 'INVENTORY'),
('inventory.l1.update', 'L1 Stock Operations', 'Perform L1 stock operations', 'INVENTORY'),

-- Inventory L2
('inventory.l2.create', 'L2 Stock In', 'Perform stock-in operations at L2', 'INVENTORY'),
('inventory.l2.read', 'View L2 Inventory', 'View L2 inventory levels', 'INVENTORY'),
('inventory.l2.update', 'L2 Stock Operations', 'Perform L2 stock operations', 'INVENTORY'),

-- Orders
('orders.create', 'Create Orders', 'Create new orders', 'ORDERS'),
('orders.read', 'View Orders', 'View order information', 'ORDERS'),
('orders.update', 'Update Orders', 'Update order information', 'ORDERS'),
('orders.approve', 'Approve Orders', 'Approve orders for fulfillment', 'ORDERS'),
('orders.cancel', 'Cancel Orders', 'Cancel orders', 'ORDERS'),

-- Invoices and Payments
('invoices.create', 'Create Invoices', 'Create invoices from orders', 'FINANCE'),
('invoices.read', 'View Invoices', 'View invoice information', 'FINANCE'),
('invoices.update', 'Update Invoices', 'Update invoice information', 'FINANCE'),
('payments.create', 'Record Payments', 'Record payments against invoices', 'FINANCE'),
('payments.read', 'View Payments', 'View payment information', 'FINANCE'),

-- Daily Close
('daily_close.create', 'Submit Daily Close', 'Submit daily close reports', 'OPERATIONS'),
('daily_close.read', 'View Daily Close', 'View daily close reports', 'OPERATIONS'),
('daily_close.approve', 'Approve Daily Close', 'Approve daily close reports', 'OPERATIONS'),

-- Reports
('reports.sales', 'Sales Reports', 'Access sales reports and KPIs', 'REPORTS'),
('reports.inventory', 'Inventory Reports', 'Access inventory reports', 'REPORTS'),
('reports.financial', 'Financial Reports', 'Access financial reports', 'REPORTS'),
('reports.audit', 'Audit Reports', 'Access audit logs and reports', 'REPORTS');

-- Insert default tenant
INSERT INTO tenants (name, code, description, active) VALUES
('Default Tenant', 'DEFAULT', 'Default tenant for the system', TRUE);