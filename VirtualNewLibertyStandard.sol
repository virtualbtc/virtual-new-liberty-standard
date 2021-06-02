// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./VirtualBitcoinInterface.sol";

contract VirtualNewLibertyStandard {

    event Sell(address indexed seller, uint256 amount, uint256 price);
    event RemoveSale(uint256 indexed saleId);
    event Buy(uint256 indexed saleId, address indexed buyer);
    event CancelSale(uint256 indexed saleId);

    VirtualBitcoinInterface vbtc;

    struct Sale {
        address seller;
        uint256 amount;
        uint256 price;
    }
    Sale[] public sales;

    constructor(address vbtcAddress) {
        vbtc = VirtualBitcoinInterface(vbtcAddress);
    }

    function saleCount() external view returns (uint256) {
        return sales.length;
    }

    function sell(uint256 amount, uint256 price) external {
        vbtc.transferFrom(msg.sender, address(this), amount);
        sales.push(Sale({
            seller: msg.sender,
            amount: amount,
            price: price
        }));
        emit Sell(msg.sender, amount, price);
    }

    function removeSale(uint256 saleId) internal {
        delete sales[saleId];
        emit RemoveSale(saleId);
    }

    function buy(uint256 saleId) payable external {
        Sale storage sale = sales[saleId];
        uint256 amount = sale.amount
        vbtc.transfer(msg.sender, amount);
        removeSale(saleId);
        emit Buy(saleId, msg.sender, amount);
    }

    function cancelSale(uint256 saleId) external {
        Sale memory sale = sales[saleId];
        require(sale.seller == msg.sender);
        vbtc.transfer(msg.sender, sale.amount);
        removeSale(saleId);
        emit CancelSale(saleId);
    }
}
