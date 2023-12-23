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
        //targetIndex set to an arbitrary high number so that we can add a security check before the second ForLoop
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




    bool public isMintingOpen = false;
    function unlockMinting() external onlyManagers {

    }

    mapping(address => bool) public managersPermit;
    function unlockMinting()
        function vote(bool approve) public {
        require(!votes[msg.sender], "You have already voted");

        votes[msg.sender] = approve;
        voteCount++;

        if (voteCount >= 3 && !isApproved) {
            isApproved = true;
        }
    }



    modifier onlyWhitelistedManagers() {
        require(msg.sender)
    }

    //minting function for the owner, I can use _mint function in ERC20Capped but this one helps
    //with managing decimals and easier to integrate with frontend
    function mintOwner(uint _amount) external onlyOwner {
        require(_amount > 0 && _amount < 1000, "mint between 0 and 1000");
        require(totalSupply + _amount <= tokenCap, "Maximum minting limit exceeded");
        _mint(msg.sender, _amount*(10**18));
        emit TokenMinted(msg.sender, _amount);
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