import React, {useState} from 'react';
//getting user account info from redux storage
import { useSelector } from "react-redux";
//getting contract from zustand store
import { useAccount } from '../../Store';
import { AddressClosio } from "../addressABI/addressClosio";

import { useMediaQuery } from 'react-responsive';

function WithdrawPart() {

  const isMobile = useMediaQuery({ maxWidth: 768 });

  //fetching user account from redux storage.  
  const userAccount2 = useSelector( (state) => state.userAccount);

  //fetching closio and csol contracts from zustand storage
  const contractClosio = useAccount(state => state.contractClosio2);

  //variables
  let [privateWord, setPrivateWord] = useState("");
  let [receiverAddress, setReceiverAddress] = useState("");
  let [amount, setAmount] = useState("");
  let [newHash, setNewHash] = useState("");
  let [message, setMessage] = useState("");

  const withdrawPartly = async () => {

    try {
      //Although input is already type=number, we again type-cast here to make sure
      //operations wont give any error
      let amount1 = parseInt(amount);
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
      if(privateWord === "" || receiverAddress === "") {
        alert("You cannot leave input areas empty");
        return
      }
      //check 4: if receiver address is valid
      if(receiverAddress.length < 39) {
        alert("invalid address length");
        return;
      } else if(receiverAddress.slice(0, 2) !== "0x") {
        alert("invalid hash");
        return;
      }
      //check 5: if hash is valid
      if(newHash.length < 64) {
        alert("invalid hash length");
        return;
      } else if(newHash.slice(0, 2) !== "0x") {
        alert("invalid hash");
        return;
      } else if(newHash === "") {
        alert("new hash area cannot be empty");
        return;
      }
      //check 6: if amount is valid
      if(amount1 === "" || amount === "" ) {
        alert("Amount area cannot be empty");
        return;
      }
      //check 7: if amount is valid
      if(amount1 < 0) {
        alert("Amount cannot be less than 0");
        return;
      }
      //check 8: if user has paid service fee
      let feePaymentStatus = await contractClosio.feePayers(userAccount2);
      if(feePaymentStatus === false) {
        alert("You need to pay fee. Each time you call deposit, withdraw all or withdraw part functions, it will cost you 1 CSOL");
        return;
      }
      //check 9: if system is paused
      let isSystemPaused = await contractClosio.pauseContract();
      if(isSystemPaused === true) {
        alert("System has been paused by Owner. Contact him to unpause: drysoftware1@gmail.com");
        return;
      }
      //execution
      let exeResult = await contractClosio.withdrawPart(privateWord, newHash, receiverAddress, amount);
      await exeResult.wait();
      setMessage("Part Withdrawal is successful and Balance updated");
    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        alert("Part withdrawal failed. Check your new hash and private word of old hash. Refresh the website, check your connection and try again");
        setMessage(error.error.data.message);
      } else {
        // Log all error message
        console.error(error);
      }    
    }
  }

  return (
    <div>
      <button className='button10' onClick={withdrawPartly}>Withdraw Part</button>{isMobile ? <br/> : ""}
      <input type="text" className='inputFields' placeholder='private keyword' 
      value={privateWord} onChange={e => setPrivateWord(e.target.value)} />
      <input type="text" className='inputFields' placeholder='receiver address'
      value={receiverAddress} onChange={e => setReceiverAddress(e.target.value)} />{isMobile ? <br/> : ""}
      <input type="number" className='inputFields' placeholder='amount' 
      value={amount} onChange={e => setAmount(e.target.value)} />
      <input type="text" className='inputFields' placeholder='new hash' 
      value={newHash} onChange={e => setNewHash(e.target.value)} />{message}
    </div>
  )
}

export default WithdrawPart