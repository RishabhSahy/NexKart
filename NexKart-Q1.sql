/* =========================================================
   DATABASE
========================================================= */
CREATE DATABASE NexCartDB;
GO
USE NexCartDB;
GO

/* =========================================================
   SCHEMAS
========================================================= */
CREATE SCHEMA auth;
GO
CREATE SCHEMA catalog;
GO
CREATE SCHEMA cart;
GO
CREATE SCHEMA [order];
GO
CREATE SCHEMA payment;
GO

/* =========================================================
   AUTH SCHEMA
========================================================= */
CREATE TABLE auth.Roles (
    RoleId INT IDENTITY PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE,

    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL
);

CREATE TABLE auth.Users (
    UserId INT IDENTITY PRIMARY KEY,
    UserName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(256) NOT NULL,
    RoleId INT NOT NULL,

    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,

    CONSTRAINT FK_Users_Roles 
        FOREIGN KEY (RoleId) REFERENCES auth.Roles(RoleId)
);

/* =========================================================
   CATALOG SCHEMA
========================================================= */
CREATE TABLE catalog.Categories (
    CategoryId INT IDENTITY PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL UNIQUE,

    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL
);

CREATE TABLE catalog.Products (
    ProductId INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Price DECIMAL(18,2) NOT NULL,
    Quantity INT NOT NULL DEFAULT 0,
    CategoryId INT NOT NULL,
    ExpirationDate DATETIME NULL,

    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,

    CONSTRAINT FK_Products_Categories 
        FOREIGN KEY (CategoryId) REFERENCES catalog.Categories(CategoryId)
);

/* =========================================================
   CART SCHEMA
========================================================= */
CREATE TABLE cart.Cart (
    CartId INT IDENTITY PRIMARY KEY,
    UserId INT NOT NULL,

    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,

    CONSTRAINT FK_Cart_Users 
        FOREIGN KEY (UserId) REFERENCES auth.Users(UserId)
);

CREATE TABLE cart.CartItems (
    CartItemId INT IDENTITY PRIMARY KEY,
    CartId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,

    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,

    CONSTRAINT FK_CartItems_Cart 
        FOREIGN KEY (CartId) REFERENCES cart.Cart(CartId),

    CONSTRAINT FK_CartItems_Products 
        FOREIGN KEY (ProductId) REFERENCES catalog.Products(ProductId)
);

/* =========================================================
   ORDER SCHEMA
========================================================= */
CREATE TABLE [order].OrderStatusMaster (
    OrderStatusId INT IDENTITY PRIMARY KEY,
    StatusName NVARCHAR(50) NOT NULL UNIQUE,

    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL
);

INSERT INTO [order].OrderStatusMaster (StatusName)
VALUES 
('Pending'),
('Confirmed'),
('Packed'),
('Shipped'),
('Delivered'),
('Cancelled');

CREATE TABLE [order].Orders (
    OrderId INT IDENTITY PRIMARY KEY,
    UserId INT NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL,
    OrderStatusId INT NOT NULL,

    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,

    CONSTRAINT FK_Orders_Users 
        FOREIGN KEY (UserId) REFERENCES auth.Users(UserId),

    CONSTRAINT FK_Orders_OrderStatus 
        FOREIGN KEY (OrderStatusId) REFERENCES [order].OrderStatusMaster(OrderStatusId)
);

CREATE TABLE [order].OrderItems (
    OrderItemId INT IDENTITY PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(18,2) NOT NULL,

    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,

    CONSTRAINT FK_OrderItems_Orders 
        FOREIGN KEY (OrderId) REFERENCES [order].Orders(OrderId),

    CONSTRAINT FK_OrderItems_Products 
        FOREIGN KEY (ProductId) REFERENCES catalog.Products(ProductId)
);

/* =========================================================
   PAYMENT SCHEMA
========================================================= */
CREATE TABLE payment.PaymentMethods (
    PaymentMethodId INT IDENTITY PRIMARY KEY,
    MethodName NVARCHAR(50) NOT NULL UNIQUE,

    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL
);

INSERT INTO payment.PaymentMethods (MethodName)
VALUES ('COD'),('Card'),('Wallet'),('UPI');

CREATE TABLE payment.Payments (
    PaymentId INT IDENTITY PRIMARY KEY,
    OrderId INT NOT NULL,
    PaymentMethodId INT NOT NULL,
    PaymentStatus NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    PaidDate DATETIME NULL,

    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,

    CONSTRAINT FK_Payments_Orders 
        FOREIGN KEY (OrderId) REFERENCES [order].Orders(OrderId),

    CONSTRAINT FK_Payments_PaymentMethods 
        FOREIGN KEY (PaymentMethodId) REFERENCES payment.PaymentMethods(PaymentMethodId)
);
