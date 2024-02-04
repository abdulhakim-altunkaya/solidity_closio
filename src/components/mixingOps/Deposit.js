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


    //check 4: if user has WETH
    let userBalanceWETH1 = await contractClosio.getYourWETHBalance();
    let userBalanceWETH2 = userBalanceWETH1.toString();
    let userBalanceWETH3 = parseInt(userBalanceWETH2);
    if(userBalanceWETH3 <= 0) {
      alert("You dont have WBNB to deposit");
      return;
    }

    let allowanceAmount = await contractTokenA.allowance(userAccount, AddressCoinfog);
    let allowanceAmount2 = allowanceAmount / (10**18);
    let allowanceAmount3 = allowanceAmount2.toString()
    if(allowanceAmount3 < amountInput1) {
      alert("You approve amount is less than your deposit amount. Go to Approve button and approve the contract with amount you want to deposit (Security Check 5)");
      return;
    }

    //HASH CHECKS
    if(hashInput.length < 64) {
      alert("invalid hash length (security check 6)");
      return;
    }
    
    if(hashInput.slice(0, 2) !== "0x") {
      alert("invalid hash (security check 7)");
      return;
    }
    
    if(hashInput === "") {
      alert("hash area cannot be empty (security check 8)");
      return;
    }

    let doesHashExist = await contractCoinFog.checkHashExist(hashInput);
    if(doesHashExist === true) {
      alert("this hash already exists, create a new hash from another private keyword (security check 9)");
      return;
    }

    //USER CHECKS
    let feePaidStatus = await contractCoinFog.feePayers(userAccount);
    if(feePaidStatus === false) {
      alert("You need to pay transaction fee (security check 10)");
      return;
    }

    //SYSTEM CHECKS
    let systemPause = await contractCoinFog.status();
    if(systemPause === true) {
      alert("System has been paused by owner. Contact him to unpause it (security check 11)");
      return;
    }

    await contractCoinFog.deposit(hashInput, amountInput1);
    setMessage(`You successfully deposited ${amountInput1} toka`);

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


