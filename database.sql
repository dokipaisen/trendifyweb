-- Kịch bản khởi tạo Cơ sở Dữ liệu SQL Server cho Website Bán Quần Áo
-- Bạn có thể chạy trực tiếp kịch bản này trong SQL Server Management Studio (SSMS)

-- 1. Tạo Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'clothingstore_db')
BEGIN
    CREATE DATABASE clothingstore_db;
END
GO

USE clothingstore_db;
GO

-- Xóa các bảng nếu tồn tại để tránh xung đột (xóa theo thứ tự khóa ngoại)
IF OBJECT_ID('chat_messages', 'U') IS NOT NULL DROP TABLE chat_messages;
IF OBJECT_ID('banners', 'U') IS NOT NULL DROP TABLE banners;
IF OBJECT_ID('reviews', 'U') IS NOT NULL DROP TABLE reviews;
IF OBJECT_ID('order_items', 'U') IS NOT NULL DROP TABLE order_items;
IF OBJECT_ID('orders', 'U') IS NOT NULL DROP TABLE orders;
IF OBJECT_ID('promotions', 'U') IS NOT NULL DROP TABLE promotions;
IF OBJECT_ID('cart_items', 'U') IS NOT NULL DROP TABLE cart_items;
IF OBJECT_ID('product_variants', 'U') IS NOT NULL DROP TABLE product_variants;
IF OBJECT_ID('product_images', 'U') IS NOT NULL DROP TABLE product_images;
IF OBJECT_ID('products', 'U') IS NOT NULL DROP TABLE products;
IF OBJECT_ID('categories', 'U') IS NOT NULL DROP TABLE categories;
IF OBJECT_ID('users', 'U') IS NOT NULL DROP TABLE users;
GO

-- 2. Tạo Bảng Users (Người dùng, Nhân viên, Admin)
CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address NVARCHAR(255),
    role VARCHAR(20) DEFAULT 'CUSTOMER', -- 'ADMIN', 'EMPLOYEE', 'CUSTOMER'
    status NVARCHAR(20) DEFAULT 'ACTIVE', -- 'ACTIVE', 'INACTIVE'
    created_at DATETIME DEFAULT GETDATE()
);

-- 2.1. Tạo Bảng Chat_Messages (Lịch sử hội thoại AI & Live Chat)
CREATE TABLE chat_messages (
    id INT IDENTITY(1,1) PRIMARY KEY,
    chat_session_id VARCHAR(100) NOT NULL,
    sender VARCHAR(50) NOT NULL, -- 'USER', 'AI', 'STAFF'
    sender_name NVARCHAR(100),
    message NVARCHAR(MAX) NOT NULL,
    is_read BIT DEFAULT 0,
    mode VARCHAR(20) DEFAULT 'AI', -- 'AI', 'STAFF'
    created_at DATETIME DEFAULT GETDATE()
);

-- 3. Tạo Bảng Categories (Danh mục sản phẩm)
CREATE TABLE categories (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(255),
    image_url VARCHAR(255)
);

-- 4. Tạo Bảng Products (Sản phẩm chính)
CREATE TABLE products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    price DECIMAL(18,2) NOT NULL,
    original_price DECIMAL(18,2),
    rating DECIMAL(3,2) DEFAULT 5.0,
    brand NVARCHAR(100),
    image_url VARCHAR(255) NOT NULL,
    category_id INT FOREIGN KEY REFERENCES categories(id) ON DELETE SET NULL,
    status NVARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT GETDATE()
);

-- 5. Tạo Bảng Product_Images (Ảnh phụ sản phẩm)
CREATE TABLE product_images (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT FOREIGN KEY REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(255) NOT NULL
);

-- 6. Tạo Bảng Product_Variants (Biến thể sản phẩm: Size/Color và số lượng tồn kho)
CREATE TABLE product_variants (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT FOREIGN KEY REFERENCES products(id) ON DELETE CASCADE,
    size VARCHAR(10) NOT NULL, -- S, M, L, XL, XXL
    color NVARCHAR(50) NOT NULL, -- Đen, Trắng, Hồng, Xanh, Xám...
    stock INT DEFAULT 0,
    sku VARCHAR(50) UNIQUE
);

-- 7. Tạo Bảng Cart_Items (Giỏ hàng của Người dùng)
CREATE TABLE cart_items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES users(id) ON DELETE CASCADE,
    product_id INT FOREIGN KEY REFERENCES products(id),
    variant_id INT FOREIGN KEY REFERENCES product_variants(id),
    quantity INT NOT NULL CHECK (quantity > 0)
);

-- 8. Tạo Bảng Promotions (Mã giảm giá/Vouchers)
CREATE TABLE promotions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_type VARCHAR(20) NOT NULL, -- 'PERCENTAGE', 'FIXED_AMOUNT'
    discount_value DECIMAL(18,2) NOT NULL,
    min_order_value DECIMAL(18,2) DEFAULT 0,
    max_discount DECIMAL(18,2),
    start_date DATETIME,
    end_date DATETIME,
    active BIT DEFAULT 1
);

-- 9. Tạo Bảng Orders (Đơn hàng)
CREATE TABLE orders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_code VARCHAR(50) UNIQUE NOT NULL,
    user_id INT FOREIGN KEY REFERENCES users(id) ON DELETE SET NULL,
    full_name NVARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    address NVARCHAR(255) NOT NULL,
    notes NVARCHAR(255),
    payment_method VARCHAR(50) DEFAULT 'COD', -- 'COD', 'BANK_TRANSFER'
    payment_status VARCHAR(50) DEFAULT 'UNPAID', -- 'UNPAID', 'PAID'
    shipping_fee DECIMAL(18,2) DEFAULT 0,
    discount_amount DECIMAL(18,2) DEFAULT 0,
    total_amount DECIMAL(18,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING', -- 'PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPING', 'DELIVERED', 'CANCELLED'
    employee_id INT FOREIGN KEY REFERENCES users(id) ON DELETE NO ACTION,
    created_at DATETIME DEFAULT GETDATE()
);

-- 10. Tạo Bảng Order_Items (Chi tiết sản phẩm trong đơn hàng)
CREATE TABLE order_items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT FOREIGN KEY REFERENCES orders(id) ON DELETE CASCADE,
    product_id INT FOREIGN KEY REFERENCES products(id) ON DELETE NO ACTION,
    variant_id INT FOREIGN KEY REFERENCES product_variants(id) ON DELETE NO ACTION,
    product_name NVARCHAR(200) NOT NULL,
    size VARCHAR(10),
    color NVARCHAR(50),
    price DECIMAL(18,2) NOT NULL,
    quantity INT NOT NULL,
    total_price DECIMAL(18,2) NOT NULL
);

-- 11. Tạo Bảng Reviews (Đánh giá & Bình luận)
CREATE TABLE reviews (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES users(id),
    product_id INT FOREIGN KEY REFERENCES products(id) ON DELETE CASCADE,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);

-- 12. Tạo Bảng Banners (Banners chạy quảng cáo slideshow)
CREATE TABLE banners (
    id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(100),
    image_url VARCHAR(255) NOT NULL,
    link_url VARCHAR(255),
    active BIT DEFAULT 1,
    display_order INT DEFAULT 0
);
GO

-- 13. CHÈN DỮ LIỆU MẪU (SEED DATA)
-- Chèn Users (Mật khẩu mặc định là '123456' đã được băm BCrypt: $2a$10$UqS9l9m6VlGkFk6wFfN3x.hD/b40J1a1/uQ6j8T2E2FqK8E.jD7N.)
-- Lưu ý: Thực tế Spring Security sẽ băm mật khẩu, ở đây chèn sẵn bản băm của 'admin123' ($2a$10$e0mygLyzH2yfZ2KspFf.e.9R22.O4uHUpH4p4PZ1f.oW8x6oH2bJy) và 'user123' ($2a$10$e0mygLyzH2yfZ2KspFf.e.9R22.O4uHUpH4p4PZ1f.oW8x6oH2bJy)
INSERT INTO users (username, password, full_name, email, phone, address, role, status)
VALUES 
('admin', '$2a$10$e0mygLyzH2yfZ2KspFf.e.9R22.O4uHUpH4p4PZ1f.oW8x6oH2bJy', N'Quản Trị Viên', 'admin@clothingstore.com', '0987654321', N'Hà Nội, Việt Nam', 'ADMIN', 'ACTIVE'),
('employee', '$2a$10$e0mygLyzH2yfZ2KspFf.e.9R22.O4uHUpH4p4PZ1f.oW8x6oH2bJy', N'Nguyễn Nhân Viên', 'staff@clothingstore.com', '0912345678', N'Đà Nẵng, Việt Nam', 'EMPLOYEE', 'ACTIVE'),
('customer', '$2a$10$e0mygLyzH2yfZ2KspFf.e.9R22.O4uHUpH4p4PZ1f.oW8x6oH2bJy', N'Trần Khách Hàng', 'customer@gmail.com', '0901122334', N'TP. Hồ Chí Minh, Việt Nam', 'CUSTOMER', 'ACTIVE');

-- Chèn Danh mục
INSERT INTO categories (name, description, image_url)
VALUES 
(N'Áo Thun', N'Các loại áo thun thời trang nam nữ cổ tròn, cổ bẻ', '/images/categories/t-shirts.jpg'),
(N'Áo Sơ Mi', N'Áo sơ mi công sở, sơ mi đi chơi thanh lịch', '/images/categories/shirts.jpg'),
(N'Quần Jean', N'Quần jean denim bền đẹp, cá tính', '/images/categories/jeans.jpg'),
(N'Áo Khoác', N'Áo khoác gió, khoác dù, khoác dạ ấm áp', '/images/categories/jackets.jpg'),
(N'Váy Đầm', N'Váy đầm thời trang nữ tính quý phái', '/images/categories/dresses.jpg');

-- Chèn Sản phẩm
INSERT INTO products (name, description, price, original_price, rating, brand, image_url, category_id)
VALUES 
(N'Áo Thun Cotton Basic Trendify', N'Chất liệu 100% cotton co giãn 4 chiều, thấm hút mồ hôi tốt. Kiểu dáng trẻ trung năng động.', 150000.00, 199000.00, 4.8, 'Trendify', 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500&auto=format&fit=crop', 1),
(N'Áo Sơ Mi Oxford Dài Tay', N'Vải Oxford cao cấp chống nhăn, thích hợp cho cả công sở và đi tiệc.', 299000.00, 399000.00, 4.7, 'Oxford Men', 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=500&auto=format&fit=crop', 2),
(N'Quần Jean Slim Fit Denim', N'Kiểu dáng ôm nhẹ trẻ trung, màu xanh chàm cổ điển cực dễ phối đồ.', 350000.00, 450000.00, 4.9, 'Denim Lab', 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=500&auto=format&fit=crop', 3),
(N'Áo Khoác Gió Thể Thao Waterproof', N'Cản gió và chống nước nhẹ, thích hợp chạy bộ và đi phượt.', 420000.00, 550000.00, 4.6, 'WindShield', 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=500&auto=format&fit=crop', 4),
(N'Váy Đầm Hoa Nhí Dáng Xoè Nữ', N'Thiết kế xoè nhẹ nhàng nữ tính, chất vải voan lụa mềm mại bay bổng.', 380000.00, 480000.00, 4.8, 'Graceful', 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500&auto=format&fit=crop', 5),
(N'Áo Thun Nam Cổ Tròn Basic Cotton', N'Chất liệu cotton mềm mại, thoáng mát, thích hợp mặc hàng ngày.', 160000.00, 220000.00, 4.7, 'Trendify', 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=500&auto=format&fit=crop', 1),
(N'Áo Thun Polo Premium Trẻ Trung', N'Kiểu dáng polo thanh lịch, cổ bẻ đứng phom, chất vải cá sấu co giãn.', 220000.00, 300000.00, 4.8, 'Trendify', 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=500&auto=format&fit=crop', 1),
(N'Áo Sơ Mi Linen Cổ Tàu Thoáng Mát', N'Chất liệu linen tự nhiên bay bổng, thấm hút tốt, phom dáng rộng thoải mái.', 280000.00, 380000.00, 4.6, 'Linen Space', 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=500&auto=format&fit=crop', 2),
(N'Áo Sơ Mi Flannel Kẻ Caro Unisex', N'Họa tiết caro cá tính, chất vải flannel dày dặn ấm áp, có thể mặc khoác ngoài.', 320000.00, 450000.00, 4.7, 'UrbanStyle', 'https://images.unsplash.com/photo-1617137968427-85924c800a22?w=500&auto=format&fit=crop', 2),
(N'Quần Jean Nam Regular Fit Cao Cấp', N'Dáng quần đứng thẳng rộng rãi hơn slim fit, mang lại sự thoải mái tối đa.', 370000.00, 490000.00, 4.8, 'Denim Lab', 'https://images.unsplash.com/photo-1584273143981-41c073dfe8f8?w=500&auto=format&fit=crop', 3),
(N'Quần Jean Rách Gối Streetwear', N'Thiết kế rách gối bụi bặm, phong cách năng động cho giới trẻ.', 390000.00, 520000.00, 4.9, 'Denim Lab', 'https://images.unsplash.com/photo-1511105612662-2dc3c0f65998?w=500&auto=format&fit=crop', 3),
(N'Áo Khoác Bomber Da Lộn Sang Trọng', N'Chất da lộn cao cấp, lớp lót dù bên trong ấm áp, thiết kế lịch lãm.', 590000.00, 850000.00, 4.9, 'UrbanStyle', 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500&auto=format&fit=crop', 4),
(N'Áo Khoác Hoodie Nỉ Bông Hàn Quốc', N'Áo nỉ bông ấm áp có mũ trùm đầu, phom rộng phong cách Hàn Quốc.', 270000.00, 390000.00, 4.7, 'Trendify', 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500&auto=format&fit=crop', 4),
(N'Váy Đầm Maxi Đi Biển Voan Tơ', N'Vải voan tơ mềm mịn bay bổng, họa tiết nhã nhặn, tôn dáng người mặc.', 450000.00, 600000.00, 4.8, 'Graceful', 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=500&auto=format&fit=crop', 5),
(N'Váy Đầm Body Cổ Vuông Thanh Lịch', N'Chất vải thun gân dày dặn ôm sát cơ thể, tôn đường cong quyến rũ.', 390000.00, 550000.00, 4.7, 'Graceful', 'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=500&auto=format&fit=crop', 5);

-- Chèn Biến thể (Variants - Cần thiết cho thời trang)
-- Áo thun (id: 1)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(1, 'S', N'Trắng', 50, 'AT-COTTON-WHITE-S'),
(1, 'M', N'Trắng', 75, 'AT-COTTON-WHITE-M'),
(1, 'L', N'Trắng', 60, 'AT-COTTON-WHITE-L'),
(1, 'M', N'Đen', 80, 'AT-COTTON-BLACK-M'),
(1, 'L', N'Đen', 45, 'AT-COTTON-BLACK-L');

-- Sơ mi (id: 2)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(2, 'M', N'Xanh Nhạt', 30, 'SM-OXFORD-BLUE-M'),
(2, 'L', N'Xanh Nhạt', 25, 'SM-OXFORD-BLUE-L'),
(2, 'XL', N'Xanh Nhạt', 15, 'SM-OXFORD-BLUE-XL'),
(2, 'M', N'Trắng', 40, 'SM-OXFORD-WHITE-M'),
(2, 'L', N'Trắng', 35, 'SM-OXFORD-WHITE-L');

-- Quần jean (id: 3)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(3, 'S', N'Xanh Đậm', 20, 'QJ-DENIM-DBLUE-S'),
(3, 'M', N'Xanh Đậm', 30, 'QJ-DENIM-DBLUE-M'),
(3, 'L', N'Xanh Đậm', 25, 'QJ-DENIM-DBLUE-L'),
(3, 'XL', N'Xanh Đậm', 20, 'QJ-DENIM-DBLUE-XL');

-- Áo khoác (id: 4)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(4, 'M', N'Đen', 40, 'AK-SPORT-BLACK-M'),
(4, 'L', N'Đen', 35, 'AK-SPORT-BLACK-L'),
(4, 'XL', N'Đen', 20, 'AK-SPORT-BLACK-XL');

-- Váy đầm (id: 5)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(5, 'S', N'Vàng', 20, 'VD-HOANHI-YELLOW-S'),
(5, 'M', N'Vàng', 25, 'VD-HOANHI-YELLOW-M'),
(5, 'L', N'Vàng', 15, 'VD-HOANHI-YELLOW-L');

-- Áo thun nam basic (id: 6)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(6, 'S', N'Xám', 30, 'AT-BASIC-GRAY-S'),
(6, 'M', N'Xám', 40, 'AT-BASIC-GRAY-M'),
(6, 'L', N'Xám', 35, 'AT-BASIC-GRAY-L'),
(6, 'XL', N'Xám', 20, 'AT-BASIC-GRAY-XL');

-- Áo thun Polo (id: 7)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(7, 'M', N'Xanh Navy', 50, 'AT-POLO-NAVY-M'),
(7, 'L', N'Xanh Navy', 45, 'AT-POLO-NAVY-L'),
(7, 'XL', N'Xanh Navy', 30, 'AT-POLO-NAVY-XL');

-- Áo sơ mi Linen (id: 8)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(8, 'M', N'Be', 30, 'SM-LINEN-BEIGE-M'),
(8, 'L', N'Be', 30, 'SM-LINEN-BEIGE-L'),
(8, 'XL', N'Be', 20, 'SM-LINEN-BEIGE-XL');

-- Áo sơ mi Flannel (id: 9)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(9, 'M', N'Đỏ Đen', 35, 'SM-FLANNEL-REDBLACK-M'),
(9, 'L', N'Đỏ Đen', 35, 'SM-FLANNEL-REDBLACK-L'),
(9, 'XL', N'Đỏ Đen', 25, 'SM-FLANNEL-REDBLACK-XL');

-- Quần jean regular (id: 10)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(10, 'S', N'Xanh Nhạt', 25, 'QJ-REGULAR-LBLUE-S'),
(10, 'M', N'Xanh Nhạt', 35, 'QJ-REGULAR-LBLUE-M'),
(10, 'L', N'Xanh Nhạt', 30, 'QJ-REGULAR-LBLUE-L'),
(10, 'XL', N'Xanh Nhạt', 15, 'QJ-REGULAR-LBLUE-XL');

-- Quần jean rách gối (id: 11)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(11, 'S', N'Đen Rách', 20, 'QJ-RIP-BLACK-S'),
(11, 'M', N'Đen Rách', 30, 'QJ-RIP-BLACK-M'),
(11, 'L', N'Đen Rách', 25, 'QJ-RIP-BLACK-L'),
(11, 'XL', N'Đen Rách', 15, 'QJ-RIP-BLACK-XL');

-- Áo khoác bomber (id: 12)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(12, 'M', N'Nâu', 25, 'AK-BOMBER-BROWN-M'),
(12, 'L', N'Nâu', 25, 'AK-BOMBER-BROWN-L'),
(12, 'XL', N'Nâu', 15, 'AK-BOMBER-BROWN-XL');

-- Áo khoác Hoodie (id: 13)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(13, 'M', N'Xám Tiêu', 40, 'AK-HOODIE-GRAY-M'),
(13, 'L', N'Xám Tiêu', 45, 'AK-HOODIE-GRAY-L'),
(13, 'XL', N'Xám Tiêu', 30, 'AK-HOODIE-GRAY-XL');

-- Váy đầm maxi (id: 14)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(14, 'S', N'Trắng Hoa', 15, 'VD-MAXI-WHITE-S'),
(14, 'M', N'Trắng Hoa', 20, 'VD-MAXI-WHITE-M'),
(14, 'L', N'Trắng Hoa', 15, 'VD-MAXI-WHITE-L');

-- Váy body (id: 15)
INSERT INTO product_variants (product_id, size, color, stock, sku) VALUES 
(15, 'S', N'Đen', 25, 'VD-BODY-BLACK-S'),
(15, 'M', N'Đen', 30, 'VD-BODY-BLACK-M'),
(15, 'L', N'Đen', 20, 'VD-BODY-BLACK-L');


-- Banners
INSERT INTO banners (title, image_url, link_url, active, display_order)
VALUES 
(N'Bộ Sưu Tập Mùa Hè 2026', 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=1600&auto=format&fit=crop', '/shop', 1, 1),
(N'Giảm Giá Đến 50% Lễ Hội Mua Sắm', 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1600&auto=format&fit=crop', '/shop?sale=true', 1, 2);

-- Promotions
INSERT INTO promotions (code, discount_type, discount_value, min_order_value, max_discount, start_date, end_date, active)
VALUES 
('SUMMER26', 'PERCENTAGE', 10.00, 200000.00, 50000.00, '2026-06-01', '2026-08-31', 1),
('TRENDIFY50', 'FIXED_AMOUNT', 50000.00, 300000.00, 50000.00, '2026-06-01', '2026-12-31', 1);
GO
