// Sources flattened with hardhat v2.19.3 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.0.1

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.0.1

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.0.1

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File @openzeppelin/contracts/utils/ReentrancyGuard.sol@v5.0.1

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}


// File contracts/Closio.sol

// Original license: SPDX_License_Identifier: MIT

pragma solidity ^0.8.20;

//inheriting IERC20 interface to use "CSOL" token in closio functions
contract Closio is Ownable, ReentrancyGuard {

    constructor() Ownable(msg.sender) {
        //This constructor is only to overcome setting initial owner error while compiling.
        //I think it is related to BNB Blockchain. Other chains work fine as far as I know.
    }
    
    //events will emitted when people deposit/withdraw CSOL tokens for anonymous tx
    event Deposit(address depositor, uint amount);
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
    uint private cooldown = 1;//a small random value just to initiate the cooldown
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
    // However, owner will not be able to withdraw more then 10 WETH per day. 
    // This already makes a very good amount today, 10 WETH = 22k Euros
    // contract --> account
    function collectPoolTokens(address _receiver, uint _amount) external onlyOwner {
        require(block.timestamp > cooldown + 1 days, "Important functions cannot be called frequently, wait 1 day at least");
        cooldown = block.timestamp;
        require(_amount < 11);
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
        contractStatus = !contractStatus;
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
    1)Function to create a hash. Users will be advised to use other websites to create their keccak256 hashes.
    But if they dont, they can use this function.
    2) As we dont need any specific type information of the private word("_word"), we dont need to use 
    "abi.encode". We solely want the hash of our input and no type information with it. Thats why
    it is "abi.encodePacked".
    */
    function createHash(string calldata _privateWord) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(_privateWord));
    }
    function createHashSalty(string calldata _privateWord) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(_privateWord, uint(1 ether)));
    }
    function getHashAmount(string calldata _privateWord) private view returns(uint, bytes32) {
        bytes32 idHash_1 = keccak256(abi.encodePacked(_privateWord));
        bytes32 idHash = keccak256(abi.encodePacked(idHash_1, uint(1 ether)));
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
    function deposit(bytes32 _hash, uint _amount) external isPaused hasPaid nonReentrant returns(string memory) {
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
        //Validations Input: new hash if repeating. The reason why this line is under fee resetting is to 
        //deter spammers from checking if they can guess hashes.
        bool isExisting = checkHash(_hash);
        if(isExisting == true) {
            return "insufficient WETH Balance";
        }
        //I know error is repeating hash above but it means spammer found an existing hash.
        //This shouldnt happen unless they crack keccak256 with quantum computers or private word of someone 
        //is something easily guessable. I am throwing same return message to confuse the spammer.
        bytes32 _newHash = keccak256(abi.encodePacked(_hash, uint(1 ether)));
        uint amount = _amount * (10**18);

        //main execution (assuming approval is already done)
        tokenContractWETH.transferFrom(msg.sender, address(this), amount);
        balanceIds.push(_newHash);
        balances[_newHash] = amount;
        return "success";
    }

    function withdrawAll(string calldata _privateWord, address _receiver) external nonReentrant isPaused hasPaid returns(string memory) {
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
            return "balance is 0";
        }
        // Set the balance associated with the hash to 0
        balances[balanceHash] = 0;
        //transfer the tokens to the receiver address
        tokenContractWETH.transfer(_receiver, balanceFinal);
        return "success";
    }

    function withdrawPart(string calldata _privateWord, bytes32 _newHash, address _receiver, uint _amount) 
    external nonReentrant isPaused hasPaid returns(string memory) 
    {
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
            return "balance is zero";
        }
        //I know error is repeating hash above but it means spammer found an existing hash.
        //This shouldnt happen unless they crack keccak256 with quantum computers or private word of someone 
        //is something easily guessable.  
        //So, to confuse the spammer, I am returning the same string as below so that he will not know.

        //-----GETTING BALANCE OF THE HASH
        (uint balanceFinal, bytes32 balanceHash) = getHashAmount(_privateWord);
        uint amount = _amount * (10**18);
        if (balanceFinal == 0) {
            return "balance is zero";
        }
        if(amount > balanceFinal) {
            return "withdrawal amount is bigger than balance";
        }
        // Set the balance associated with the hash to 0
        balances[balanceHash] = 0;
        //transfer the tokens to the receiver address
        tokenContractWETH.transfer(_receiver, amount);

        //redepositing the amount left
        uint amountLeft = balanceFinal - amount;
        if(amountLeft < 1) {
            return "amount left must be bigger than 1";
        }
        bytes32 newHash = keccak256(abi.encodePacked(_newHash, uint(1 ether)));
        balances[newHash] = amountLeft;
        balanceIds.push(newHash);
        return "success";
    }

    receive() external payable {}
    fallback() external payable {}

}


    //collectPoolTokens(): mappings and arrays must change also to reflect the withdrawals
    /*
    Dont forget approvals. People first need to approve for both tokens before paying fee and depositing
    You will need ethers parse methods to manage decimals on approval components.

    Add balance checks on the frontend: "        uint WETHBalance = tokenContractWETH.balanceOf(msg.sender);
        if (WETHBalance == 0) {
            return "insufficient WETH Balance";
        }"
        
    */
