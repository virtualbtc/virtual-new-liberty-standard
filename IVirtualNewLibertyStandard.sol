// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IVirtualNewLibertyStandard {

    event Sell(uint256 indexed saleId, address indexed seller, uint256 amount, uint256 price);
    event RemoveSale(uint256 indexed saleId);
    event Buy(uint256 indexed saleId, address indexed buyer, uint256 amount);
    event CancelSale(uint256 indexed saleId);

    function saleCount() external view returns (uint256);
    function sell(uint256 amount, uint256 price) external;
    function buy(uint256 saleId) payable external;
    function cancelSale(uint256 saleId) external;
}