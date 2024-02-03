import React from 'react';
import GetBalances from "./GetBalances";
import ApproveFee from "./ApproveFee";
import ApproveWETH from "./ApproveWETH";
import PayFee from "./PayFee";
import CreateHash from "./CreateHash";
import Deposit from "./Deposit";
import WithdrawAll from "./WithdrawAll";
import WithdrawPart from "./WithdrawPart";

function Platform() {
  return (
    <div>
      <GetBalances />
      <ApproveFee />
      <ApproveWETH />
      <PayFee />
      <CreateHash />
      <Deposit />
      <WithdrawAll />
      <WithdrawPart />
      <p id='aboutText'>Closio by Abdulhakim Altunkaya. 2024</p>
    </div>
  )
}

export default Platform;

/*
      GET Balances component: 
    function withdrawPart(string calldata _privateWord, bytes32 _newHash, address _receiver, uint _amount) 
    external nonReentrant isPaused hasPaid returns(bool) 
    {
      
      function withdrawAll(string calldata _privateWord, address _receiver) external nonReentrant isPaused hasPaid returns(bool) {
            
      approval fee CSOL
      approval WETH 

      function payFee() public {
      function deposit(bytes32 _hash, uint _amount) external isPaused hasPaid nonReentrant returns(string memory) {
      
      function createHashSalty(string calldata _privateWord) external pure returns(bytes32) {

      
      
      
      
      */