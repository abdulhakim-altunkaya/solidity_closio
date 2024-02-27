//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

//No flavor of uint will be used. The deployment cost and function call cost of using different uints are minimal for this project.

contract TestWBNB is ERC20Capped {


    //OWNER BLOCK
    //Scan website and hardhat compiles the same contract differently. One of them requires
    //the initiation of Ownable contract in constructor area, and hardhat gives error if I do so.
    //To overcome this issue and not lose more time I am creating my own owner logic down.
    address public owner;
    modifier onlyOwner() {
        if(msg.sender != owner) {
            revert("You are not owner");
        }
        _;
    }
    function transferOwnership(address _newOwner) external onlyOwner{
        owner = _newOwner;
    }


    //creating token based on lazy minting capped model
    //cap will be set to 1.000.000.000 (1 billion)
    //10% early investors, 60% exchanges, 5% developers, 1% free giving, 24% Treasury(grants, projects, etc)
    constructor(uint _cap) ERC20("TestWBNB", "TWBNB") ERC20Capped(_cap*(10**18)) {
        owner = msg.sender;
    }

    //*****FREE TOKENS*****
    bool public freeMinting = true;
    function toggleFree() external onlyOwner {
        freeMinting = !freeMinting;
    }

    uint public cooldown = 1;//random value to initiate cooldown.
    function mintPublic() external {
        require(freeMinting == true, "Free minting disabled by Owner");
        require(block.timestamp > cooldown + 20 minutes, "wait 20 mins to mint again");
        cooldown = block.timestamp;
        _mint(msg.sender, 50*(10**18));
    }
 

    //*******SIDE FUNCTIONS*******
    //burn token function, open to anybody, decimals handled for easy frontend integration
    function burnToken(uint _amount) external {
        require(_amount > 0, "Enter an amount to burn");
        require(uint(balanceOf(msg.sender)) > 0, "You dont have tokens to burn");
        _burn(msg.sender, _amount*(10**18));
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

