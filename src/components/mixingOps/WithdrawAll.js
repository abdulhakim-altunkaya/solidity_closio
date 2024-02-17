import React, {useState} from 'react';
//getting user account info from redux storage
import { useSelector } from "react-redux";
//getting contract from zustand store
import { useAccount } from '../../Store';
import { AddressClosio } from "../addressABI/addressClosio";

import { useMediaQuery } from 'react-responsive';

function WithdrawAll() {

  const isMobile = useMediaQuery({ maxWidth: 768 });

  //fetching user account from redux storage.  
  const userAccount2 = useSelector( (state) => state.userAccount);

  //fetching closio and csol contracts from zustand storage
  const contractClosio = useAccount(state => state.contractClosio2);

  let [message, setMessage] = useState("");
  let [privateWord, setPrivateWord] = useState("");
  let [receiver, setReceiver] = useState("");

  const withdrawAll = async () => {
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
      //check 3: if private word or receiver input is empty
      if(privateWord === "" || receiver === "") {
        alert("You cannot leave input areas empty");
        return
      }
      //check 4: if receiver address is valid
      if(receiver.length < 39) {
        alert("invalid address length");
        return;
      } else if(receiver.slice(0, 2) !== "0x") {
        alert("invalid hash");
        return;
      }
      //check 5: if user has paid service fee
      let feePaymentStatus = await contractClosio.feePayers(userAccount2);
      if(feePaymentStatus === false) {
        alert("You need to pay fee. Each time you call deposit, withdraw all or withdraw part functions, it will cost you 1 CSOL");
        return;
      }
      //check : if system is paused
      let isSystemPaused = await contractClosio.pauseContract();
      if(isSystemPaused === true) {
        alert("System has been paused by Owner. Contact him to unpause: drysoftware1@gmail.com");
        return;
      }   
      //execution
      let tx = await contractClosio.withdrawAll(privateWord, receiver);
      await tx.wait();
      if(tx === false) {
        alert("Probably old/wrong private word error because there is 0 balance. Check your private word. Then pay fee again. And then call deposit function.");
        return;
      } else {
        setMessage(`You successfully withdraw all balance.`);
      }
    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        alert("Withdraw All balance failed. Check your private word. Check your Metamask and internet connection, refresh the page and try again");
        setMessage(error.error.data.message);
      } else {
        // Log all error message
        console.error(error);
      }
    }
    
  }
  return (
    <div>
      <button className='button10' onClick={withdrawAll}>Withdraw All</button>{isMobile ? <br /> : ""}
      <input type="text" className='inputFields' placeholder='private keyword'
      value={privateWord} onChange={e => setPrivateWord(e.target.value)} />
      <input type="text" className='inputFields' placeholder='receiver address'
      value={receiver} onChange={e => setReceiver(e.target.value)} /> {message}
    </div>
  )
}

export default WithdrawAll