pragma solidity ^0.8.0;

contract TokenA is ERC20Capped {




    //general view functions, you can understand what they do from names
    function getTotalSupply() external view returns(uint) {
        return totalSupply() / (10**18);
    }

    function getContractAddress() external view returns(address) {
        return address(this);
    } 

    function getYourBalance() external view returns(uint) {
        return balanceOf(msg.sender) / (10**18);
    }

    function getContractBalance() external view returns(uint) {
        return balanceOf(address(this)) / (10**18);
    }

}