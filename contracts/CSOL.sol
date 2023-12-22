//SPDX-License-Identifier: MIT

pragma solidity >= 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//1.No flavor of uint will be used. The deployment cost and function call cost of using different uints are minimal for this project.
//For this reason, it will be only uint (uint256). This will help less better readability and security

//2.Owner settings will be mosty managed by Ownable contract. 

contract CSOL is ERC20Capped, Ownable {

    //events for token minting and burning
    event TokenMinted(address minter, uint amount);
    event TokenBurned(address burner, uint amount);

    //creating token based on lazy minting capped model
    constructor(uint cap) ERC20("Closio", "CSOL") ERC20Capped(cap*(10**18)) {}

    //minting function for the owner, I can use _mint function in ERC20Capped but this one helps
    //with managing decimals and easier to integrate with frontend
    function mintOwner(uint _amount) external onlyOwner {
        require()
    }



}






contract TokenA is ERC20Capped {



    //minting function for owner
    function mintToken(uint _amount) external onlyOwner {
        require(_amount > 0 && _amount < 100000, "mint between 0 and 100000");
        _mint(msg.sender, _amount*(10**18));
        emit TokenMinted(msg.sender, _amount);
    }

    //minting function for generals
    function mintTokenGenerals(uint _amount) external  {
        require(_amount > 0 && _amount < 500, "mint between 0 and 500");
        _mint(msg.sender, _amount*(10**18));
        emit TokenMinted(msg.sender, _amount);
    }

    //burning token function, no need set a higher limit
    function burnToken(uint _amount) external {
        require(_amount > 0, "burn amount must be greater than 0");
        _burn(msg.sender, _amount*(10**18));
        emit TokenBurned(msg.sender, _amount);
    }

    //approve swap contract before sending tokens to it for liquidity
    function approveCoinFog(address _coinFogContract, uint _amount) external {
        require(_amount > 0, "approve amount must be greater than 0");
        uint amount = _amount*(10**18);
        _approve(msg.sender, _coinFogContract, amount);
    }

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