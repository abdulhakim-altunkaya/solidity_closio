//SPDX-License-Identifier: MIT

pragma solidity >= 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//No flavor of uint will be used. The deployment cost and function call cost of using different uints are minimal for this project.
//For this reason, it will be only uint (uint256). This will help with readability and security

contract CSOL is ERC20Capped, Ownable {

    //events for token minting and burning
    event TokenMintedTeam(address minter, uint amount);
    event TokenMintedInvestors(address minter, uint amount);
    event TokenMintedExchanges(address minter, uint amount);
    event TokenMintedFree(address minter, uint amount);
    event TokenBurned(address burner, uint amount);

    //creating token based on lazy minting capped model
    //cap will be set to 100.000.000 (100 million)
    constructor(uint _cap) ERC20("Closio", "CSOL") ERC20Capped(_cap*(10**18)) {}
    uint public cooldown = 1;//random value to initiate cooldown. Actual value will come later once we call important function. 

    //15 millions tokens will be for investors
    //Each minting will be limited to 5 millions for extra security
    function mintInvestors(uint _amount, address _receiver) external onlyOwner {
        require(_amount > 0 && _amount < 5000001, "mint between 0 and 5000001");
        require(block.timestamp > cooldown + 1 days, "Important functions cannot be called frequently, wait 1 day at least");
        cooldown = block.timestamp;
        _mint(_receiver, _amount*(10**18));
        emit TokenMintedInvestors(_receiver, _amount);
    }

    //The remaining tokens will be for exchanges, which is 75 millions
    //And each minting is limited to 1.000.000 tokens for extra security.
    //By limiting to 1 million, the team will slowly distrubute tokens to exchanges
    function mintExchanges(uint _amount, address _receiver) external onlyOwner {
        require(_amount > 0 && _amount < 1000001, "mint between 0 and 1000001");
        require(block.timestamp > cooldown + 1 days, "Important functions cannot be called frequently, wait 1 day at least");
        cooldown = block.timestamp;
        _mint(_receiver, _amount*(10**18));
        emit TokenMintedExchanges(_receiver, _amount);
    }


    uint teamTokens = 0;
    //Tokens for the team should not exceed 5% of the cap, which is 5 millions. 
    //And each minting is limited to 500.000 tokens for extra security.
    //Also, cooldown check is added for extra security
    function mintTeam(uint _amount, address _receiver) external onlyOwner {
        uint capWithoutDecimals = uint(cap() / (10**18));
        require(teamTokens < capWithoutDecimals*5/100);
        require(_amount > 0 && _amount < 500001, "mint between 0 and 500001");
        require(block.timestamp > cooldown + 1 days, "Important functions cannot be called frequently, wait 1 day at least");
        _mint(_receiver, _amount*(10**18));
        cooldown = block.timestamp;
        teamTokens += _amount;
        emit TokenMintedTeam(_receiver, _amount);
    }
 
    uint private cooldownFree = 1;
    bool public freeMinting = true;
    function toggleFree() external onlyOwner {
        freeMinting = !freeMinting;
    }
    //People who want to test the website will be able to do so by getting 2 tokens here.
    function mintFree() external {
        require(freeMinting == true, "free minting disabled by owner");
        require(block.timestamp > cooldownFree + 1 hours, "Free minting is after 1 hour");
        cooldownFree = block.timestamp;
        _mint(msg.sender, 2*(10**18));
        emit TokenMintedFree(msg.sender, 2);
    }

    //burn token function, open to anybody, decimals handled for easy frontend integration
    function burnToken(uint _amount) external {
        require(_amount > 0, "Enter an amount to burn");
        require(uint(balanceOf(msg.sender)) > 0, "You dont have tokens to burn");
        _burn(msg.sender, _amount*(10**18));
        emit TokenBurned(msg.sender, _amount);
    }

    function getTotalSupply() external view returns(uint) {
        return totalSupply() / (10**18);
    }

    function getYourTokenBalance() external view returns(uint) {
        return balanceOf(msg.sender) / (10**18);
    }

    function getContractTokenBalance() external view returns(uint) {
        return balanceOf(address(this)) / (10**18);
    }

}