//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//inheriting IERC20 interface to use "CSOL" token in closio functions
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

//No flavor of uint will be used here. Their effect on deployment cost is minimal.
//The platform will allow deposit and withdrawal of round numbers such as "1, 8, 90" etc
//The platform will not allow deposit and withdrawal of decimal numbers such as "1.4 or 1,4"
//As platform is based on WBNB tokens and as each WBNB token is approximately 310 usd as of 28 Feb 2024, decimal
//amounts will be too less in value. So no need.

contract Closio is ReentrancyGuard {

    //OWNER BLOCK
    //Scan website and hardhat compiles the same contract differently. One of them requires
    //the initiation of Ownable contract in constructor area, the other gives error if I do so.
    //To overcome this issue and not lose more time I am creating my own owner logic down.
    address public owner;
    error NotOwner(string message, address caller);
    modifier onlyOwner() {
        if(msg.sender != owner) {
            revert NotOwner("You are not owner", msg.sender);
        }
        _;
    }
    function transferOwnership(address _newOwner) external onlyOwner{
        owner = _newOwner;
    }

    constructor() {
        owner = msg.sender;
    }
    
    //events will emitted when people deposit/withdraw CSOL tokens for anonymous tx
    event Deposit(address depositor, uint amount);
    event WithdrawCSOL(address receiver, uint amount);
    event WithdrawPool(address receiver, uint amount);

    //************SETTING SYSTEM TOKEN: CSOL************
    //We will use CSOL tokens as fee to deposit and withdraw other tokens from the contract.
    //For example, you want to deposit 100 SHIB? Then you first need to pay 1 CSOL token to the contract.
    IERC20 public tokenContractCSOL;
    function setTokenCSOL(address _tokenAddressCSOL) external onlyOwner {
        tokenContractCSOL = IERC20(_tokenAddressCSOL);
    }

    //************SETTING POOL TOKEN: WETH************
    //WETH tokens will be allowed for depositing/withdrawing.
    //If needed owner will be able to change WETH to any other token. However, this
    //does not mean that the website supports multitokens. Only one pool token at a time. 
    //Owner will set token contract at the beginning of website launch.
    //This project is originally created for BSC and I know I should name it "WBNB" but I can 
    //deploy the project to other chains, that's why by convention I think it should be named WETH
    IERC20 public tokenContractWETH;
    function setTokenWETH(address _tokenAddressWETH) external onlyOwner {
        tokenContractWETH = IERC20(_tokenAddressWETH);
    }

    //************STATE VARIABLES*************
    //Each deposit will have a hash and amount information. These data will be saved in a mapping.
    //These hashes will be saved in an array. Hashes will act like deposit ids.
    //"balances" mapping and balanceIds array will be private 
    //for extra security and we will use it only from within the contract.
    //hashes produced by keccak256() are in bytes32 format.
    mapping(bytes32 => uint) private balances;
    bytes32[] private balanceIds;
    uint public fee = 1;
    mapping(address => bool) public feePayers;
    uint private cooldown = 1;//a small random value just to initiate the cooldown
    bool public pauseContract = false;

    //************PAYING AND COLLECTING PLATFORM FEES*************
    //There will be a fee for calling deposit and withdraw function to deter scammers.
    //Fee will be in CSOL token. Current fee is 1 CSOL for each function call.
    //addresses paying fee, will be saved in a mapping and later this mapping will be checked
    //to see if fee is paid.
    function setFee(uint _newFee) external onlyOwner {
        fee = _newFee;
    }

    // account ---> contract (token transfer)
    // As users will transfer ERC20 tokens from account to this contract, they will first need to approve this contract.
    // Approval will be done on the frontend. Frontend will directly call erc20 method approve 
    // frontend implementation: tokenContractCSOL.approve(spender, amount)
    // and it will use ethers parse methods to manage decimals for amount parameter.
    function payFee() public {
        require(tokenContractCSOL.balanceOf(msg.sender) >= uint(fee*(10**18)), "You dont have CSOL");
        require(msg.sender == tx.origin, "Only accounts. Smart contract cannot pay fee");
        require(msg.sender != address(0), "invalid account");
        tokenContractCSOL.transferFrom(msg.sender, address(this), fee*(10**18));
        feePayers[msg.sender] = true;
    }

    // contract --> account
    // owner can collect CSOL tokens in the contract.
    function collectFees() external onlyOwner {
        uint balanceCSOL = tokenContractCSOL.balanceOf(address(this));
        require(balanceCSOL > 0, "There is no CSOL");
        tokenContractCSOL.transfer(msg.sender, balanceCSOL);
        emit WithdrawCSOL(msg.sender, uint(balanceCSOL/(10**18)));
    }

    /*
    // owner will be also withdraw the pool token in cases like where the 
    // depositor forgets the private key, or if deposit stucks for some reason.
    // However, owner will not be able to withdraw more then 10 WETH per day. 
    // In future versions, depending on user requests, this function can be enabled
    // This function can also help sending funds back to users if the platform crashes for some reason.  
    // contract --> account
    function collectPoolTokens(address _receiver, uint _amount) external onlyOwner {
        require(block.timestamp > cooldown + 1 days, "Important functions cannot be called frequently, wait 1 day at least");
        cooldown = block.timestamp;
        require(_amount < 11);
        tokenContractWETH.transfer(_receiver, _amount*(10**18));
        emit WithdrawPool(_receiver, uint(_amount*(10**18)));
    }
    */ 

    //************SECURITY CHECKS*************
    //CHECK 1: PAUSE CONTRACT
    error Stopped(string message, address owner);
    modifier isPaused() {
        if (pauseContract == true) {
            revert Stopped("Contract paused, contact owner: ", owner);
        }
        _;
    }
    function togglePause() external onlyOwner {
        pauseContract = !pauseContract;
    }

    //CHECK 2: PREVENT USING REPEATING HASHES
    /*Using a modifier like this might be a little risky, as people might compare hashes to crack private
    words of our hashes. By using checkHash() function, we will be deterring spammers as each 
    function call will not fail if hashes does not match. Therefore they will be charged 1 csol in any case.
    Thats why I am using checkHash function instead of isExistingHash modifier.
    error ExistingHash(string message, bytes32 hashdata);
    modifier isExistingHash(bytes32 _hash) {
        bytes32 _newHash = keccak256(abi.encodePacked(_hash, uint(1 ether)));
        for(uint i=0; i< balanceIds.length; i++) {
            if(balanceIds[i] == _newHash) {
                revert ExistingHash("This hash exists", _hash);
            }
        }
        _;
    }
    */
    function checkHash(bytes32 _hash) private view returns(bool) {
        bytes32 _newHash = keccak256(abi.encodePacked(_hash, uint(1 ether)));
        for(uint i=0; i< balanceIds.length; i++) {
            if(balanceIds[i] == _newHash) {
                return true;
            }
        }
        return false;
    }

    //CHECK 3: CHECK IF FEE IS PAID
    error NotPaid(string message, address caller);
    modifier hasPaid() {
        if(feePayers[msg.sender] == false) {
            revert NotPaid("You need to pay service fee", msg.sender);
        }
        _;
    }
 

    /* HASH CREATION AND COMPARISON FUNCTIONS
    1)Function to create a hash. Users can use createHashSalty function to create a hash. Or they can copy
    //this function and use it by themselves on remix.
    2) As we dont need any specific type information of the private word("_word"), we dont need to use 
    "abi.encode". We solely want the hash of our input and no type information with it. Thats why
    it is "abi.encodePacked".
    */
    //Currently createHash function will not be used. But we will keep, future versions of website might make use of it.
    function createHash(string calldata _privateWord) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(_privateWord));
    }
    function createHashSalty(string calldata _privateWord) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(_privateWord, uint(1 ether)));
    }
    function getHashAmount(string calldata _privateWord) public view returns(uint, bytes32) {
        bytes32 _newHash = keccak256(abi.encodePacked(_privateWord, uint(1 ether)));
        bytes32 idHash = keccak256(abi.encodePacked(_newHash, uint(1 ether)));
        for(uint i=0; i<balanceIds.length; i++) {
            if(balanceIds[i] == idHash) {
                return (balances[idHash], idHash);
            }
        }
        return (0, idHash);
    }


    // ------------------------------------------------------------------------
    //                          DEPOSIT AND WITHDRAWAL FUNCTIONS
    // ------------------------------------------------------------------------

    //Function to deposit tokens into the contract, decimals handled inside the function
    //Depositor will: 1) create hash either by using this website or by using another website, 
    // 2) approve this contract on CSOL contract for 1 CSOL 3) Transfer 1 CSOL to this contract, 
    // 4) approve this contract on WETH contract for the amount he desires to deposit 
    // 5) transfer the WETH amoun to this contract by calling deposit function below.
    //depositor will first need to convert his private word to a keccak256 has either by using this 
    //website or by using another service. In fact, people will be encouraged to use other websites. 
    function deposit(bytes32 _hash, uint _amount) external isPaused hasPaid nonReentrant returns(bool) {
        //VALIDATIONS
        //Validations Input: amount if valid
        require(_amount > 0, "_amount must be bigger than 0");
        //Validations Input: new hash length
        require(_hash.length == 32, "invalid new hash");
        //Validations msg.sender
        require(msg.sender == tx.origin, "contract cannot call this function");
        require(msg.sender != address(0), "real addresses can call withdraw");
        //----RESETTING SERVICE FEE
        //resetting service fee. Each function call will cost
        feePayers[msg.sender] = false;
        //Validations Input: new hash if repeating. The reason why it is under fee resetting is to 
        //deter spammers from checking if they can guess hashes.
        //I know error below is repeating hash but it means spammer found an existing hash.
        //This shouldnt happen unless they crack keccak256 with quantum computers or private word of someone 
        //is something easily guessable. Or may be the user has entered his 
        //his private word a few times. I am throwing this return message to confuse the spammer.
        bool isExisting = checkHash(_hash);
        if(isExisting == true) {
            return false;
        }
        bytes32 _newHash = keccak256(abi.encodePacked(_hash, uint(1 ether)));
        uint amount = _amount * (10**18);
        //main execution (assuming approval is already done)
        tokenContractWETH.transferFrom(msg.sender, address(this), amount);
        balanceIds.push(_newHash);
        balances[_newHash] = amount;
        return true;
    }

    function withdrawAll(string calldata _privateWord, address _receiver) external nonReentrant isPaused hasPaid returns(bool) {
        //----VALIDATIONS
        //Validations Input: private word length
        require(bytes(_privateWord).length > 0, "private word is not long enough");
        //Validations Input: receiver address if valid
        require(_receiver != address(0), "invalid receiver address");
        //Validations Input: receiver address length
        require(bytes20(_receiver) == bytes20(address(_receiver)), "invalid receiver address");
        
        //msg.sender checks
        require(msg.sender == tx.origin, "contracts cannot call this function");
        require(msg.sender != address(0), "real addresses can call withdraw");

        //Resetting service fee. Each function call will cost 
        feePayers[msg.sender] = false;
        //Get the balance and hash of the input private word
        (uint balanceFinal, bytes32 balanceHash) = getHashAmount(_privateWord);

        //Instead of putting a Require to check balanceFinal we will use IF statement. By doing this we will make sure
        //function execution does not fail if private word returns with zero balance. Because spammers will obviously try
        //this if we put Require. Each time Require fails, they will continue keep their service fee and call this function
        //again until they find a matching private key by chance. To prevent it we will use IF instead. 
        if (balanceFinal == 0) {
            return false;
        }
        // Set the balance associated with the hash to 0
        balances[balanceHash] = 0;
        //transfer the tokens to the receiver address
        tokenContractWETH.transfer(_receiver, balanceFinal);
        return true;
    }


    function withdrawPart(string calldata _privateWord, bytes32 _newHash, address _receiver, uint _amount) 
    external nonReentrant isPaused hasPaid returns(bool) {
        //----VALIDATIONS 
        //Validations Input: private word length
        require(bytes(_privateWord).length > 0, "private word is not long enough");
        //Validations Input: receiver address if valid
        require(_receiver != address(0), "invalid receiver address");
        //Validations Input: receiver address length
        require(bytes20(_receiver) == bytes20(address(_receiver)), "invalid receiver address");
        //Validations Input: new hash length
        require(_newHash.length == 32, "invalid new hash");
        //Validations Input: amount if valid
        require(_amount > 0, "_amount must be bigger than 0");
        //Validations msg.sender
        require(msg.sender == tx.origin, "contract cannot call this function");
        require(msg.sender != address(0), "real addresses can call withdraw");

        //----RESETTING SERVICE FEE
        //resetting service fee. Each function call will cost
        feePayers[msg.sender] = false;
        //Validations Input: new hash if repeating. The reason why this line is under fee resetting is to 
        //deter spammers from checking if they can guess hashes.
        bool isExisting = checkHash(_newHash);
        if(isExisting == true) {
            return false;
        }
        //This error means spammer found an existing hash.
        //This shouldnt happen unless they crack keccak256 with quantum computers or private word of someone 
        //is something easily guessable.  

        //-----GETTING BALANCE OF THE HASH
        (uint balanceFinal, bytes32 balanceHash) = getHashAmount(_privateWord);
        uint amount = _amount * (10**18);
        if (balanceFinal == 0) {
            return false;
        }
        if(amount > balanceFinal) {
            return false;
        }
        //amount left should not be less than 1/10000 (1e4) of pool coin such. In WETH case it is sth around 0.24 eur as of Feb 2024.
        uint amountLeft = balanceFinal - amount;
        if(amountLeft < 1e4) {
            return false;
        }
        //******Execution Part 1: Transfer
        // Set the balance associated with the hash to 0
        balances[balanceHash] = 0;
        //transfer the tokens to the receiver address
        tokenContractWETH.transfer(_receiver, amount);
        //******Execution Part 2: Redepositing
        bytes32 newHash = keccak256(abi.encodePacked(_newHash, uint(1 ether)));
        balances[newHash] = amountLeft;
        balanceIds.push(newHash);
        return true;
    }

    function getContractWETHBalance() external view returns(uint) {
        return tokenContractWETH.balanceOf(address(this)) / (10**18);
    }
    function getYourWETHBalance() external view returns(uint) {
        return tokenContractWETH.balanceOf(msg.sender) / (10**18);
    }
    function getUserWETHApproval() external view returns(uint) {
        return tokenContractWETH.allowance(msg.sender, address(this)) / (10**18);
    }
    function getUserCSOLApproval() external view returns(uint) {
        return tokenContractCSOL.allowance(msg.sender, address(this)) / (10**18);
    }
    /*
    //approve closio contract before sending WETH tokens to it
    //This function wont work because approval must be done on token contract.
    //This function will try to approve Closio for Closio.
    function approveClosioWeth(uint _amount) external {
        require(_amount > 0, "approve amount must be greater than 0");
        uint amount = _amount*(10**18);
        tokenContractWETH.approve(address(this), amount);
    }
    */
    receive() external payable {}
    fallback() external payable {}
}

    /*    
    
    //OwnClosioSetWETH: After hackathon, if BNB does not fund project
    You can apply the project to other chains. So Change WBNB here to other coins in other chains. 
    4 Places you will need to change.
    //share createsalty hash function and in a video, show people how to use it on remix by themselves

    //In Store.js i have     contractWETH1 and contractTestWBNB1. Before final deployment delete ContractTestWBNB settings inside
    Store.js with its import statements. Also delete ABITestWBNB.js, addressTestWBNB.js and TestWBNBmint.js files. Also remove 
    TestWBNBmint component and also remove TestWBNBmint import statement from CsolToken.js

    When converting from TestWBNB to WBNB, DELETE: 
        addressTestWBNB.js, ABITestWBNB.js --> addressABI folder
        TestWBNB.sol --> contracts
        deployTest.js --> scripts
        let contractTestWBNB1 and its related code ---> Store.js
        TestWBNBmint.js ---> tokenOps
        TestWBNBmint related code ---> CsolToken.js
    
    */
    
