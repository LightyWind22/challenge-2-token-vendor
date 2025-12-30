pragma solidity ^0.8.0; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    // declare token
    YourToken public yourToken;

    // set price: 1 ETH / 100 tokens
    uint256 public constant tokensPerEth = 100;

    // declare event
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address buyer, uint256 amountOfTokens, uint256 amountOfETH);

    constructor(address tokenAddress) Ownable(msg.sender){
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:
    function buyTokens() public payable {
        // calculate amount of tokens: 100 tokens/ETH * ETH
        uint256 amountOfTokens = tokensPerEth * msg.value;

        // make sure vendor has enough tokens
        require(yourToken.balanceOf(address(this)) >= amountOfTokens, "Vendor: Insufficient token reserve");

        // tranfer to sender
        bool success = yourToken.transfer(msg.sender, amountOfTokens);
        require(success, "Vendor: Token transfer failed");

        // emit events for frontend
        emit BuyTokens(msg.sender, msg.value, amountOfTokens);

    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner {
        // Transfer all ETH in contract back to owner() address
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 _amount) public payable {
        // calculate total amount of ETH
        uint256 amountOfETH = _amount / tokensPerEth;

        // require vendor has enough ETH to buyback tokens
        require(address(this).balance >= amountOfETH , "Vendor: Insufficient ETH liquidity for buyback");

        // pull tokens from seller and check if the seller has approved
        bool success = yourToken.transferFrom(msg.sender, address(this), _amount);
        require(success, "Vendor: Token transferFrom failed. Did you approve the Vendor contract");

        // transfer equivalent ETH to seller 
        payable(msg.sender).transfer(amountOfETH);

        // emit events for frontend
        emit SellTokens(msg.sender, _amount, amountOfETH);
    }
}
