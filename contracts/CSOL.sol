//SPDX-License-Identifier: MIT

pragma solidity >= 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//1.No flavor of uint will be used. The deployment cost and function call cost of using different uints are minimal for this project.
//For this reason, it will be only uint (uint256). This will help with readability and security

//2.Owner settings will be mosty managed by Ownable contract. 

contract CSOL is ERC20Capped, Ownable {

    //events for token minting and burning
    event TokenMintedInvestors(address minter, uint amount);
    event TokenMintedTeam(address minter, uint amount);
    event TokenBurned(address burner, uint amount);

    //creating token based on lazy minting capped model
    //cap will be set to 100.000.000 (100 million)
    constructor(uint _cap) ERC20("Closio", "CSOL") ERC20Capped(_cap*(10**18)) {}

    //Owner will set Managers. Managers will decide on minting for investors and other important tasks
    //Managers will be limited to 3 addresses. Votes of 2 managers will be enough to mint/burn tokens.
    //Currently, owner will be among managers. However, owner can be set to a different address as well.
    mapping(address => bool) public managersMapping;
    address[] public managersArray;
    
    uint public managersNumber = 3;
    function changeManagersNumber(uint _newNumber) external onlyOwner {
        require(_newNumber > 3, "Managers number cannot be less than 3");
        managersNumber = _newNumber;
    }

    function setManagers(address _newManager) public onlyOwner {
        require(managersArray.length < 3, "Managers list is full. No space for a new manager");
        managersMapping[_newManager] = true;
        managersArray.push(_newManager);
    }

    function removeManagers(address _manager) public onlyOwner {
        require(managersArray.length > 1, "Must be at least 2 managers before deleting 1");
        require(managersMapping[_manager] == true, "Target address is not a manager");
        managersMapping[_manager] = false;

        //find the index number of target manager in managersArray
        //targetIndex is set to an arbitrary high number so that we can add a security check before the second ForLoop
        uint targetIndex = 99999; 
        for(uint i = 0; i<managersArray.length; i++) {
            if(managersArray[i] == _manager) {
                targetIndex = i;
                break;
            }
        }
        require(targetIndex <managersArray.length, "target index is not detected");
        for(uint i = targetIndex; i<managersArray.length-1; i++){
            managersArray[targetIndex] = managersArray[targetIndex+1];
        }
        managersArray.pop();
    }

    function displayManagers() external view returns(address[] memory) {
        return managersArray;
    }

    //checking if msg.sender if a manager or not. 
    error NotManager(address caller, string message);
    modifier onlyManagers() {
        if(managersMapping[msg.sender] == false) {
            revert NotManager(msg.sender, "you are not manager");
        }
        _;
    }

    //important functions can be executed if enough positiveVotes by Managers
    //I know below values are also "false" and "0" by default. However, better to emphasize them as they will be important
    uint public positiveVotes = 0;
    mapping(address => bool) public hasVoted;
    uint public cooldown = 0;

    function voteManagers() external onlyManagers {
        require(hasVoted[msg.sender] == false, "you have already voted");
        positiveVotes++;
        hasVoted[msg.sender] = true;
    }

    function resetVotes() private {
        for(uint i=0; i<managersArray.length; i++) {
            hasVoted[managersArray[i]] == false;
        }
        cooldown = block.timestamp;
        positiveVotes = 0;
    }

    //We will look for majority of votes by managers. Then owner can execute important functions, such as the one here
    //15% of token supply will be going to investors, incrementally. Firstly 5 percent, then 4,...
    //First 5 percent is 5000000 millions tokens.
    function mintInvestors(uint _amount, address _receiver) external onlyOwner {
        require(positiveVotes >= managersArray.length/2, "Not enough votes by managers");
        require(_amount > 0 && _amount < 5000001, "mint between 0 and 5000001");
        require(block.timestamp > cooldown + 1 days, "Important functions cannot be called frequently, wait 1 day at least");
        _mint(_receiver, _amount*(10**18));
        resetVotes();
        emit TokenMintedInvestors(_receiver, _amount);
    }

    uint teamTokens = 0;
    //Tokens for the team should not exceed 5% of the cap, which is 5 millions. 
    //And each minting is limited to 500.000 tokens for extra security.
    //Also, cooldown check is added for extra security
    function mintTeam(uint _amount, address _receiver) external onlyOwner {
        uint capWithoutDecimals = cap/(10**18);
        require(teamTokens < capWithoutDecimals*0.05);
        require(_amount > 0 && _amount < 500001, "mint between 0 and 500001");
        require(block.timestamp > cooldown + 1 days, "Important functions cannot be called frequently, wait 1 day at least");
        _mint(_receiver, _amount*(10**18));
        cooldown = block.timestamp;
        teamTokens += _amount;
        emit TokenMintedTeam(_receiver, _amount);
    }



}

//minting for investors and other important function will have a cooldown period.

