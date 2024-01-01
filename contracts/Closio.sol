//SPDX-License-Identifier: MIT

pragma solidity >=0.8.7;

//inheriting IERC20 interface to use "CSOL" token in closio functions
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Closio is Ownable {
    
    //events will emitted when people deposit/withdraw CSOL tokens for anonymous tx
    event Deposit(address indexed depositor, uint amount);
    event WithdrawCSOL(address receiver, uint amount);
    event WithdrawPool(address receiver, uint amount);

    //************SETTING SYSTEM TOKEN: CSOL************
    //We will use CSOL tokens as fee to deposit and withdraw other tokens from the contract.
    //For example, you want to deposit 100 SHIB? Then you first need to pay 1 CSOL token to the contract.
    IERC20 public tokenContractCSOL;
    function setTokenCSOL(address _tokenAddressCSOL) external {
        tokenContractCSOL = IERC20(_tokenAddressCSOL);
    }

    //************SETTING POOL TOKEN: WETH************
    //WETH tokens will be allowed for depositing/withdrawing.
    //If needed owner will be able to change WETH to any other token. However, this
    //does not mean that the website supports multitokens. Only one pool token at a time. 
    //Owner will set token contract at the beginning of website launch.
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
    uint cooldown;
    bool public contractStatus = true;

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

    // owner will be also withdraw the pool token in cases like where the 
    // depositor forgets the private key, or if deposit stucks for some reason.
    // However, owner will not be able to withdraw more then 10 pool token per day. 
    // This already makes a very good amount today, 10 WETH = 22k Euros
    // contract --> account
    function collectPoolTokens(address _receiver, uint _amount) external onlyOwner {
        require(block.timestamp > cooldown + 1 days, "Important functions cannot be called frequently, wait 1 day at least");
        cooldown = block.timestamp;
        require(_amount < 25);
        tokenContractWETH.transfer(_receiver, _amount*(10**18));
        emit WithdrawPool(_receiver, uint(_amount*(10**18)));
    }

    //************SECURITY CHECKS*************
    //CHECK 1: PAUSE CONTRACT
    error Stopped(string message, address owner);
    modifier isPaused() {
        if (contractStatus == false) {
            revert Stopped("Contract paused, contact owner: ", owner());
        }
        _;
    }
    function togglePause() external onlyOwner {
        contractStatus != contractStatus;
    }

    //CHECK 2: PREVENT USING REPEATING HASHES
    /*Using a modifier like this might be a little risky, as people might compare hashes they 
    produce to our hashes. By using checkHash() function, we will be deterring spammers as each 
    function call will cost them 1 CSOL token and inconvenience of losing time by calling fee
    payment function. 
    error InvalidHash(string message, bytes32 hashData);
    modifier isUsed(bytes32 _hash) {
        for(uint i=0; i<balanceIds.length; i++) {
            if(balanceIds[i] == _hash){
                revert InvalidHash("Used hash", _hash);
            }
        }
        _;
    }
    */
    function checkHash(bytes32 _hash, address _caller) private view returns(bool) {
        feePayers[_caller] = false;
        for(uint i=0; i<balanceIds.length; i++) {
            if(balanceIds[i] == _hash){
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
    function deposit(bytes32 _hash, uint _amount) external isPaused hasPaid {
        bool isExistingHash = checkHash(_hash, msg.sender);
        if(isExistingHash == true) {
            return;
        }
        //input validations
        require(_hash.length == 32, "invalid hash");
        require(_amount >= 1, "_amount must be bigger than 1");
        //general checks
        require(msg.sender == tx.origin, "contracts cannot deposit/withdraw");
        require(msg.sender != address(0), "real addresses can withdraw");
        require(tokenContractWETH.balanceOf(msg.sender) >= 0, "insufficient WETH balance");
        //main execution (assuming approval is already done)
        tokenContractWETH.transferFrom(msg.sender, address(this), _amount*(10**18));
        balanceIds.push(_hash);
        balances[_hash] = _amount*(10**18);
    }

    /* HASH CREATION AND COMPARISON FUNCTIONS
    1)Function to create a hash. Users will be advised to use other websites to create their keccak256 hashes.
    But if they dont, they can use this function.
    2) As we dont need any specific type information of the private word("_word"), we dont need to use 
    "abi.encode". We solely want the hash of our input and no type information with it. Thats why
    it is "abi.encodePacked".
    */
    function createHash(string calldata _privateWord) external view returns(bytes32) {
        return keccak256(abi.encodePacked(_privateWord));
    }
    function getHashAmount(string calldata _privateWord) private view returns(uint, bytes32) {
        bytes32 idHash = keccak256(abi.encodePacked(_privateWord));
        for(uint i=0; i<balanceIds.length; i++) {
            if(balanceIds[i] == idHash) {
                return (balances[idHash], idHash);
            }
        }
        return (0, idHash);
    }

    //REENTRANCY PROTECTION
    // reentrancy protection only for withdraw functions. For depositing no need.
    bool private reentrantBlock = false;
    modifier isLocked() {
        require(reentrantBlock == false, "Wait for your previous function call");
        reentrantBlock = true;
        _;
        reentrantBlock = false;
    }

    function withdrawAll(string calldata _privateWord, address _receiver) external isLocked isPaused hasPaid returns(bool) {
        //input validations
        require(bytes(_privateWord).length > 0, "private word is not long enough");
        require(_receiver != address(0), "invalid receiver address");
        //ethereum addresses are 20 bytes long
        require(bytes20(_receiver) == bytes20(address(_receiver)), "invalid receiver address");
        
        //general checks
        require(msg.sender == tx.origin, "contracts cannot call this function");
        require(msg.sender != address(0), "real addresses can withdraw");

        //resetting service fee. Each function call will cost 
        feePayers[msg.sender] = false;
        //get the balance by using the hash as balance id
        (uint balanceFinal, bytes32 balanceHash) = getHashAmount(_privateWord);
        if (balanceFinal == 0) {
            return false;
        } else {
            // Set the balance associated with the hash to 0
            balances[balanceHash] = 0;
            //transfer the tokens to the receiver address
            tokenContractWETH.transfer(_receiver, balanceFinal);
            return true;
        }

    }



}


contract JumboMixer is Ownable {
    function withdrawAll(string calldata _privateWord, address receiver) external hasPaid isPaused
    {
        //input validations
        require(bytes(_privateWord).length > 0, "private word is not enough long");
        require(receiver != address(0), "invalid receiver address");
        require(bytes20(receiver) == bytes20(address(receiver)), "invalid receiver address");
        //general checks
        require(msg.sender == tx.origin, "contracts cannot withdraw");
        require(msg.sender != address(0), "real addresses can withdraw");

        // Resetting service fee. Each fee is only for 1 function call
        feePayers[msg.sender] = false;
        // Get the balance and hash associated with the private word
        (uint balanceFinal, bytes32 balanceHash) = getHashAmount(_privateWord);
                // Ensure the withdrawal amount is greater than 0
        require(balanceFinal > 0, "Withdraw amount must be bigger than 0");
        // Set the balance associated with the hash to 0
        balances[balanceHash] = 0;
        // Transfer the tokens to the receiver's address
        tokenAContract.transfer(receiver, balanceFinal);

    }    


        //Function to withdraw part of the deposit. decimals handled. Previous hash will be obsolete.
    function withdrawPart(string calldata _privateWord, bytes32 _newHash, address receiver, uint _amount) 
        external hasPaid isExisting(_newHash) isPaused
    {
        //input validations
        require(bytes(_privateWord).length > 0, "private word is not enough long");
        require(_newHash.length == 32, "invalid new hash");
        require(receiver != address(0), "invalid receiver address");
        require(bytes20(receiver) == bytes20(address(receiver)), "invalid receiver address");
        require(_amount > 0, "_amount must be bigger than 0");

        //general checks
        require(msg.sender == tx.origin, "contracts cannot withdraw");
        require(msg.sender != address(0), "real addresses can withdraw");

        //withdrawing the desired amount
        uint amount = _amount * (10**18);
        (uint balanceFinal, bytes32 balanceHash) = getHashAmount(_privateWord);
        require(balanceFinal != 0, "No value for this hash");
        require(balanceFinal > amount, "If you want to withdraw all choose withdrawAll function");
        //old balance value for old hash will be set to 0.
        balances[balanceHash] = 0;
        tokenAContract.transfer(receiver, amount);

        // Resetting service fee. Each fee is only for 1 function call
        feePayers[msg.sender] = false;
        //redepositing the amount left
        uint amountLeft = balanceFinal - amount;
        require(amountLeft >= 1, "amountLeft must be bigger than 1");
        balanceIds.push(_newHash);
        balances[_newHash] = amountLeft;
    }



}



    //collectPoolTokens(): mappings and arrays must change also to reflect the withdrawal
    //also, 10% fee should be applied on for each withdrawal
    /*
    Dont forget approvals. People first need to approve for both tokens before paying fee and depositing
    You will need ethers parse methods to manage decimals on approval components.
    */
    
