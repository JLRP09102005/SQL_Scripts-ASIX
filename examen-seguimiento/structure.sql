CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

#====== BASIC TABLES ======
CREATE TABLE IF NOT EXISTS products (
    id_product INT AUTO_INCREMENT PRIMARY KEY,
    price DECIMAL(5,2) NOT NULL,
    stock INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(100) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    origin VARCHAR(50) NOT NULL,
    img_url VARCHAR(150) NOT NULL,
    available BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS order (
    id_order INT AUTO_INCREMENT PRIMARY KEY,
    send_address VARCHAR(100) NOT NULL,
    billing_address VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS clients (
    id_client INT PRIMARY KEY,

);

#====== AUDIT ======
