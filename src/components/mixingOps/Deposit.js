import React, {useState} from 'react';
//getting user account info from redux storage
import { useSelector } from "react-redux";
//getting contract from zustand store
import { useAccount } from '../../Store';
import { AddressClosio } from "../addressABI/addressClosio";

import { useMediaQuery } from 'react-responsive';

function Deposit() {

  const isMobile = useMediaQuery({ maxWidth: 768 });

  //fetching user account from redux storage. 
  const userAccount2 = useSelector( (state) => state.userAccount);

  //fetching closio and csol contracts from zustand storage
  const contractClosio = useAccount(state => state.contractClosio2);
  const contractCSOL = useAccount(state => state.contractCsol2);
  
  let [hashInput, setHashInput] = useState("");
  let [amountInput, setAmountInput] = useState("");
  let [message, setMessage] = useState("");

  const depositAmount = async () => {
    try {
      //check 1: if user has metamask installed on browser
      if(window.ethereum === "undefined") {
        alert("Please install Metamask to your Browser");
        return;
      }
      //check 2: if user has signed in or not
      if (userAccount2 === "undefined" || userAccount2 === "") {
        alert("Please sign in to website. Go to Token Operations section and click on Connect Metamask button.");
        return;
      }
      //Although input is already type=number, we again type-cast here to make sure
      //operations wont give any error
      let amountInput1 = parseInt(amountInput);
      //check 3: if amount is valid
      if(amountInput1 === "" || amountInput === "" ) {
        alert("Amount area cannot be empty");
        return;
      }
      //check 4: if amount is valid
      if(amountInput1 < 0) {
        alert("Amount cannot be less than 0");
        return;
      }
      //check 5: if user has WETH and if deposit is smaller than balance
      let userBalanceWETH1 = await contractClosio.getYourWETHBalance();
      let userBalanceWETH2 = userBalanceWETH1.toString();
      let userBalanceWETH3 = parseInt(userBalanceWETH2);
      if(userBalanceWETH3 <= 0) {
        alert("You dont have WBNB to deposit");
        return;
      } else if(amountInput1 > userBalanceWETH3) {
        alert("Your deposit amount is bigger than your balance");
        return;
      }
      //check 6: if user has approved the deposit amount
      let allowanceAmount1 = await contractClosio.getUserWETHApproval();
      let allowanceAmount2 = allowanceAmount1.toString()
      let allowanceAmount3 = parseInt(allowanceAmount2);
      if(allowanceAmount3 < amountInput1) {
        alert("Your approve amount is less than your deposit amount. Go to Approve button and approve the contract with amount you want to deposit");
        return;
      }
      //check 6: if hash is valid
      if(hashInput.length < 64) {
        alert("invalid hash length");
        return;
      } else if(hashInput.slice(0, 2) !== "0x") {
        alert("invalid hash");
        return;
      } else if(hashInput === "") {
        alert("hash area cannot be empty");
        return;
      }
      //check 7: if user has paid service fee
      let feePaymentStatus = await contractClosio.feePayers(userAccount2);
      if(feePaymentStatus === false) {
        alert("You need to pay fee. Each time you call deposit, withdraw all or withdraw part functions, it will cost you 1 CSOL");
        return;
      }
      //check 8: if system is paused
      let isSystemPaused = await contractClosio.pauseContract();
      if(isSystemPaused === true) {
        alert("System has been paused by Owner. Contact him to unpause: drysoftware1@gmail.com");
        return;
      }
      //execution
      let tx = await contractClosio.deposit(hashInput, amountInput);
      await tx.wait();
      if(tx === false) {
        alert("You probably entered one of your old hash. Create a new hash. Then pay fee again. And then call deposit function.");
        return;
      } else {
        setMessage(`You successfully deposited ${amountInput1} WETH`);
      }
    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        alert("Deposit failed. Check your Metamask and internet connection, refresh the page and try again");
        setMessage(error.error.data.message);
      } else {
        // Log all error message
        console.error(error);
      }
    }
  }
  return (
    <div>
      <button className='button10' onClick={depositAmount}>Deposit</button>{isMobile ? <br /> : ""}
      <input type="text" className='inputFields' placeholder='hash'
      value={hashInput} onChange={e => setHashInput(e.target.value)}/>
      <input type="number" className='inputFields' placeholder='amount'
      value={amountInput} onChange={e => setAmountInput(e.target.value)}/> {message}
    </div>
  )
}

export default Deposit;
