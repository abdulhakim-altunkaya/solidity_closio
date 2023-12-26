//SPDX-License-Identifier: MIT

pragma solidity >=0.8.7;

//inheriting IERC20 interface to use "CSOL" token in closio functions
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Closio is Ownable {
    
    //events will emitted when people deposit/withdraw CSOL tokens for anonymous tx
    event Deposit(address indexed depositor, uint amount);
    event Withdraw(address indexed receiver, uint amount);

    //************SETTING SYSTEM TOKEN: CSOL************
    //We will use CSOL tokens as fee to deposit and withdraw other tokens from the contract.
    //For example, you want to deposit 100 SHIB? Then you first need to pay 1 CSOL token to the contract.
    IERC20 public tokenContractCSOL;
    function setTokenCSOL(address _tokenAddressCSOL) external {
        tokenContractCSOL = IERC20(_tokenAddressCSOL);
    }

    //Any ERC29 token will be allowed for depositing/withdrawing operations. However, owner will limit the number of 
    //tokens to the most used tokens on Ethereum blockchain to keep the system clean from useless tokens.Therefore, you
    //see the token
    address[]



}





contract JumboMixer is Ownable {

    //Will be called when people deposit TokenA for anonymous tx
    event Deposit(address indexed depositor, uint amount);
    event Withdraw(address indexed receiver, uint amount);

    //************SETTING POOL TOKEN: TokenA************
    IERC20 public tokenAContract;
    function setTokenA(address _tokenAddress) external {
        tokenAContract = IERC20(_tokenAddress);
    }
    //************SETTING PLATFORM TOKEN: JUMBO************
    IERC20 public tokenMixerContract;
    function setToken(address _tokenAddress) external {
        tokenMixerContract = IERC20(_tokenAddress);
    }

    //************STATE VARIABLES*************
    //each deposit will have a hash and an amount information
    mapping(bytes32 => uint) private balances;
    //these hashes will be saved in an array
    bytes32[] private balanceIds;
    //there will be a fee for calling deposit and withdraw functions to deter scammers
    mapping(address => bool) public feePayers;


    //----------------SECURITY 1: pause contract
    bool public status;
    error Stopped(string message, address owner);
    modifier isPaused() {
        if(status == true) {
            revert Stopped("contract has been paused, contact owner", owner());
        }
        _;
    }
    function togglePause() external onlyOwner {
        status = !status;
    }

    //--------------SECURITY 2: checking if new hash already exists
    error Existing(string message, bytes32 hashdata);
    modifier isExisting(bytes32 _hash) {
        for (uint256 i = 0; i < balanceIds.length; i++) {
            if(balanceIds[i] == _hash){
                revert Existing("This hash exists: ", _hash);
            }
        }
        _;
    }

    //---------------SECURITY 3: checking if msg.sender has paid function call fee
    error NotPaid(string message, address caller);
    modifier hasPaid() {
        if (feePayers[msg.sender] == false) {
            revert NotPaid("You need to pay service fee", msg.sender);
        }
        _;
    }

    //**************SETTING FEE********************** 
    //1 is an arbitrary value. Fee is in Foggy
    uint public fee = 1;
    function setFee(uint _fee) external onlyOwner {
        fee = _fee;
    }
    // account --> contract
    // people must pay service fee for each withdrawal and deposit operation
    // they must approve this contract on token contract before calling function. Frontend will handle this approval.
    function payFee() public {
        require(tokenFoggyContract.balanceOf(msg.sender) >= fee*(10**18), "you don't have FOGGY");
        require(msg.sender == tx.origin, "contracts cannot withdraw");
        require(msg.sender != address(0), "real addresses can withdraw");
        tokenFoggyContract.transferFrom(msg.sender, address(this), fee*(10**18));
        feePayers[msg.sender] = true;
    }
    // contract --> account
    // owner can collect FOGGY tokens inside the contract
    function collectFees() external onlyOwner {
        uint balanceFoggy = tokenFoggyContract.balanceOf(address(this));
        if (balanceFoggy > 0) {
           tokenFoggyContract.transfer(msg.sender, balanceFoggy);
        }
    }


    // ------------------------------------------------------------------------
    //                          DEPOSIT AND WITHDRAWAL FUNCTIONS
    // ------------------------------------------------------------------------

    //Function to deposit tokens into the contract, decimals handled inside the function
    //approval musst be handled on the token contract. This will be done on the fronend.
    function deposit(bytes32 _hash, uint _amount) external hasPaid isExisting(_hash) isPaused {
        //input validations
        require(_hash.length == 32, "invalid hash");
        require(_amount >= 1, "_amount must be bigger than 1");
        //general checks
        require(msg.sender == tx.origin, "contracts cannot withdraw");
        require(msg.sender != address(0), "real addresses can withdraw");
        require(tokenAContract.balanceOf(msg.sender) >= 0, "you don't have TokenA");
        //operations
        tokenAContract.transferFrom(msg.sender, address(this), _amount*(10**18));
        feePayers[msg.sender] = false;
        balanceIds.push(_hash);
        balances[_hash] = _amount*(10**18);
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

    function withdrawAll(string calldata _privateWord, address receiver) 
        external hasPaid isPaused
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
        tokenContract.transfer(receiver, balanceFinal);
    }

    // HASH CREATION AND COMPARISON FUNCTIONs
    // Function to create a hash. Users will be advised to use other websites to create their keccak256 hashes.
    // But if they dont, they can use this function.
    function createHash(string calldata _word) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(_word));
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
}
