// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IVirtualNewLibertyStandard.sol";
import "./VirtualBitcoinInterface.sol";

contract VirtualNewLibertyStandard is IVirtualNewLibertyStandard {

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

    function saleCount() override external view returns (uint256) {
        return sales.length;
    }

    function sell(uint256 amount, uint256 price) override external {
        vbtc.transferFrom(msg.sender, address(this), amount);
        uint256 saleId = sales.length;
        sales.push(Sale({
            seller: msg.sender,
            amount: amount,
            price: price
        }));
        emit Sell(saleId, msg.sender, amount, price);
    }

    function removeSale(uint256 saleId) internal {
        delete sales[saleId];
        emit RemoveSale(saleId);
    }

    function buy(uint256 saleId) override payable external {
        Sale storage sale = sales[saleId];
        require(sale.price == msg.value);
        address seller = sale.seller;
        uint256 amount = sale.amount;
        vbtc.transfer(msg.sender, amount);
        removeSale(saleId);
        payable(seller).transfer(msg.value);
        emit Buy(saleId, msg.sender, amount);
    }

    function cancelSale(uint256 saleId) override external {
        Sale memory sale = sales[saleId];
        require(sale.seller == msg.sender);
        vbtc.transfer(msg.sender, sale.amount);
        removeSale(saleId);
        emit CancelSale(saleId);
    }
}
