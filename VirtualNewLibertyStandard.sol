// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./VirtualBitcoinInterface.sol";

contract VirtualNewLibertyStandard {

    VirtualBitcoinInterface vbtc;

    struct Sale {
        address seller;
        uint256 amount;
        uint256 soldAmount;
        uint256 price;
    }
    Sale[] private sales;

    constructor(address vbtcAddress) {
        vbtc = VirtualBitcoinInterface(vbtcAddress);
    }

    function saleCount() external view returns (uint256) {
        return sales.length;
    }

    function sell(address seller, uint256 amount, uint256 price) external {
        vbtc.transferFrom(msg.sender, address(this), amount);
        sales.push(Sale({
            seller: seller,
            amount: amount,
            soldAmount: 0,
            price: price
        }));
    }

    function removeSale(uint256 saleId) internal {
        delete sales[saleId];
    }

    function buy(uint256 saleId) payable external {
        Sale storage sale = sales[saleId];
        uint256 _saleAmount = sale.amount;
        uint256 _soldAmount = sale.soldAmount;

        uint256 amount = _saleAmount * msg.value / sale.price;
        require(amount <= _saleAmount - _soldAmount);
        vbtc.transfer(msg.sender, amount);
        _soldAmount += amount;
        if (_saleAmount == _soldAmount) {
            removeSale(saleId);
        }
        sale.soldAmount = _soldAmount;
    }

    function cancelSale(uint256 saleId) external {
        Sale memory sale = sales[saleId];
        require(sale.seller == msg.sender);
        vbtc.transfer(msg.sender, sale.amount - sale.soldAmount);
        removeSale(saleId);
    }
}