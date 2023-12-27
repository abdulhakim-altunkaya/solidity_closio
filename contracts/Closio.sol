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


    //************PAYING AND COLLECTING PLATFORM FEES*************
    //There will be a fee for calling deposit and withdraw function to deter scammers.
    //Fee will be in CSOL token. Current fee is 1 CSOL for each function call.
    //addresses paying fee, will be saved in a mapping and later this mapping will be checked
    //to see if fee is paid.
    uint public fee = 1;
    mapping(address => bool) public feePayers;

    function setFee(uint _newFee) external onlyOwner {
        fee = _newFee;
    }

    // account ---> contract (token transfer)
    // As users will transfer ERC20 tokens from account to this contract, they will first need to approve this contract.
    // Approval will be done on the frontend. Frontend will directly call erc20 method approve and it will ethers parse methods
    // to manage decimals.
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
    }

    //************SECURITY CHECKS*************
    //CHECK 1: PAUSE CONTRACT
    bool public contractStatus = true;
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


}

