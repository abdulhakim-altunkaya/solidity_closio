//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

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
    event TokenMintedTreasury(address minter, uint amount);
    event TokenBurned(address burner, uint amount);

    //creating token based on lazy minting capped model
    //cap will be set to 1.000.000.000 (1 billion)
    //10% early investors, 60% exchanges, 5% developers, 1% free giving, 24% Treasury(grants, projects, etc)
    constructor(uint _cap) ERC20("Closio", "CSOL") ERC20Capped(_cap*(10**18)) Ownable(msg.sender) {
    }
    
    uint public cooldown = 1;//random value to initiate cooldown. Actual value will come later once we call important function. 

    //100 millions tokens will be for early investors, 10% of total cap
    //Each minting will be limited to 5 millions for extra security
    uint public investorTokens = 0;
    function mintInvestors(uint _amount, address _receiver) external onlyOwner returns(bool) {
        uint capWithoutDecimals = uint(cap() / (10**18));
        require(investorTokens + _amount < capWithoutDecimals*10/100);
        require(_amount > 0 && _amount < 5000001, "mint between 0 and 5000001");
        require(block.timestamp > cooldown + 1 days, "Important functions cannot be called frequently, wait 1 day at least");
        cooldown = block.timestamp;
        investorTokens += _amount;
        _mint(_receiver, _amount*(10**18));
        emit TokenMintedInvestors(_receiver, _amount);
        return true;
    }

    //******EXCHANGE TOKENS*******
    //600 million tokens will be for exchanges. 60% of total cap.
    //And each minting is limited to 5.000.000 tokens for extra security.
    //By limiting to 5 million, the team will slowly distrubute tokens to exchanges
    uint public exchangeTokens = 0;
    function mintExchanges(uint _amount, address _receiver) external onlyOwner returns(bool) {
        uint capWithoutDecimals = uint(cap() / (10**18));
        require(exchangeTokens + _amount < capWithoutDecimals*60/100);
        require(_amount > 0 && _amount < 5000001, "mint between 0 and 5000001");
        require(block.timestamp > cooldown + 1 days, "Important functions cannot be called frequently, wait 1 day at least");
        cooldown = block.timestamp;
        exchangeTokens += _amount;
        _mint(_receiver, _amount*(10**18));
        emit TokenMintedExchanges(_receiver, _amount);
        return true;
    }
    
    //*****TEAM TOKENS******
    //50 millions tokens for developers. 5% of total cap. 
    //And each minting is limited to 500.000 tokens for extra security.
    //Also, cooldown check is added for extra security
    uint public teamTokens = 0;
    function mintTeam(uint _amount, address _receiver) external onlyOwner returns(bool) {
        uint capWithoutDecimals = uint(cap() / (10**18));
        require(teamTokens + _amount < capWithoutDecimals*5/100);
        require(_amount > 0 && _amount < 5000001, "mint between 0 and 500001");
        require(block.timestamp > cooldown + 1 days, "Important functions cannot be called frequently, wait 1 day at least");
        cooldown = block.timestamp;
        teamTokens += _amount;
        _mint(_receiver, _amount*(10**18));
        emit TokenMintedTeam(_receiver, _amount);
        return true;
    }
 
    //*****FREE TOKENS*****
    uint private cooldownFree = 1;
    bool public freeMinting = true;
    function toggleFree() external onlyOwner returns(bool) {
        freeMinting = !freeMinting;
        return true;
    }
    //People who want to test the platform can get 2 tokens here.
    uint public freeTokens = 0;
    function mintFree() external returns(bool) {
        uint capWithoutDecimals = uint(cap() / (10**18));
        require(freeTokens < capWithoutDecimals*1/100);
        require(freeMinting == true, "free minting disabled by owner");
        require(block.timestamp > cooldownFree + 5 minutes, "Free minting is after 5 minutes");
        cooldownFree = block.timestamp;
        freeTokens += 2;
        _mint(msg.sender, 2*(10**18));
        emit TokenMintedFree(msg.sender, 2);
        return true;
    }

    // treasury tokens are limited to 24% of total cap.
    uint public treasuryTokens = 0;
    function mintTreasury(uint _amount, address _receiver) external onlyOwner returns(bool) {
        uint capWithoutDecimals = uint(cap() / (10**18));
        require(treasuryTokens < capWithoutDecimals*24/100);
        require(_amount > 0 && _amount < 1000001, "mint between 0 and 1000001");
        require(block.timestamp > cooldown + 1 days, "Important functions cannot be called frequently, wait 1 day at least");
        treasuryTokens += _amount;
        _mint(_receiver, _amount*(10**18));
        emit TokenMintedTreasury(_receiver, _amount);
        return true;
    }

    //*******SIDE FUNCTIONS*******
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

//Maybe event display on the frontend