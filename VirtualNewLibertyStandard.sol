// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./VirtualBitcoinInterface.sol";

contract VirtualNewLibertyStandard {

    VirtualBitcoinInterface vbtc;

    struct Sale {
        address seller;
        uint256 amount;
        uint256 price;
    }
    Sale[] private sales;

    constructor(address vbtcAddress) {
        vbtc = VirtualBitcoinInterface(vbtcAddress);
    }

    function sell(address seller, uint256 amount, uint256 price) external {
        vbtc.transferFrom(msg.sender, address(this), amount);
        sales.push(Sale({
            seller: seller,
            amount: amount,
            price: price
        }));
    }

    function removeSale(uint256 saleId) internal {
        delete sales[saleId];
    }

    function buy(uint256 saleId) payable external {
        Sale storage sale = sales[saleId];
        uint256 amount = sale.amount * msg.value / sale.price;
        require(amount < sale.amount);
        vbtc.transferFrom(address(this), msg.sender, amount);
        sale.amount -= amount;
        if (sale.amount == 0) {
            removeSale(saleId);
        }
    }

    function cancelSale(uint256 saleId) external {
        Sale memory sale = sales[saleId];
        require(sale.seller == msg.sender);
        vbtc.transferFrom(address(this), msg.sender, sale.amount);
        removeSale(saleId);
    }
}