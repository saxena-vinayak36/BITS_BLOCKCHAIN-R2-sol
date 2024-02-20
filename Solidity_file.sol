// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ECommerce {
    address public owner;
    uint256 public productIdCounter;
    
    enum ProductStatus { Available, Sold }

    struct Product {
        uint256 id;
        string name;
        string category;
        string description;
        string image;
        uint256 price;  // Price in wei
        ProductStatus status;
        address seller;
    }

    mapping(uint256 => Product) public products;

    event ProductAdded(uint256 id, string name, string category, string description, string image, uint256 price, address seller);
    event ProductPurchased(uint256 id, address buyer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier productExists(uint256 productId) {
        require(products[productId].id != 0, "Product does not exist");
        _;
    }

    modifier productAvailable(uint256 productId) {
        require(products[productId].status == ProductStatus.Available, "Product is not available");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addProduct(string memory name, string memory category, string memory description, string memory image, uint256 price) external onlyOwner {
        productIdCounter++;
        Product storage newProduct = products[productIdCounter];
        newProduct.id = productIdCounter;
        newProduct.name = name;
        newProduct.category = category;
        newProduct.description = description;
        newProduct.image = image;
        newProduct.price = price;
        newProduct.status = ProductStatus.Available;
        newProduct.seller = msg.sender;

        emit ProductAdded(productIdCounter, name, category, description, image, price, msg.sender);
    }

    function purchaseProduct(uint256 productId) external payable productExists(productId) productAvailable(productId) {
        Product storage product = products[productId];

        require(msg.value == product.price, "Incorrect payment amount");

        product.status = ProductStatus.Sold;
        payable(product.seller).transfer(msg.value);

        emit ProductPurchased(productId, msg.sender);
    }

    function withdrawBalance() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
