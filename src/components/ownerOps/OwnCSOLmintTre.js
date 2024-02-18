import React, {useState} from 'react';
//Contract is fetched from Zustand store
import { useAccount } from '../../Store';

//fetch user account from redux storage. User account will be saved to Redux storage if user 
//login with metamask on homepage (RConnectMet component in tokenOps).
import { useSelector } from "react-redux";
import { AddressOwner } from "../addressABI/AddressOwner";


function OwnCSOLmintTre() {

  //fetching user account from redux storage. We will use this to check if person calling this is owner.
  //We have already done a check on parent Owner component. This check is a like an extra check.
  const userAccount2 = useSelector( (state) => state.userAccount)

  //fetching contract from Zustand and initiating other state variables
  const contractCSOL = useAccount(state => state.contractCsol2);
  let [amount, setAmount] = useState("");
  let [receiver, setReceiver] = useState("");
  let [message, setMessage] = useState("");
  let [displayMessage, setDisplayMessage] = useState(false);

  const mintTre = async () => {
    try {
      //Check 1: if user has metamask installed on browser
      if(window.ethereum === "undefined") {
        alert("Please install Metamask to your Browser");
        return;
      }
      //Check 2: checking if owner and caller matches
      if (userAccount2.toLowerCase() !== AddressOwner.toLowerCase()) {
        alert("you are not owner");
        return;
      }
      //Check 3: checking validity of amount input
      let amount1 = parseInt(amount);
      if (amount1 < 1 || amount1 === "") {
        alert("Please enter a valid amount");
        return;
      }
      //Check 4: checking validity of address input
      if(receiver.length < 20 || receiver === "") {
        alert("Address is not correct");
        return;
      }
      //Check 5: checking validity of address input
      if(receiver.slice(0,2) !== "0x") {
        alert("Invalid address type");
        return;
      }
      //Check 6: checking if limit of treasury tokens reached (240 million)
      let treTokens1 = await contractCSOL.treasuryTokens();
      let treTokens2 = treTokens1.toString();
      let treTokens3 = parseInt(treTokens2);
      if(treTokens3 + amount1 > 240000000) {
        alert("Limit of treasury tokens reached. You cannot mint more");
        return;
      }
      //Execution
      let mintResult = await contractCSOL.mintTreasury(amount1, receiver);
      await mintResult.wait();
      setDisplayMessage(true);
      setMessage("Minting successful");
    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        alert("Minting for Treasury failed");
        setDisplayMessage(true);
        setMessage(error.error.data.message);
      } else {
        // Log all error message
        console.error(error);
      }  
    }

  }
  return (
    <div>
      <button className='button4' id='buttonLength' onClick={mintTre}>Csol Mint Treasury</button>
      <input type='number' className='inputFields' placeholder='amount' 
        value={amount} onChange={ e => setAmount(e.target.value)} />
      <input type='text' className='inputFields' placeholder='receiver address'
        value={receiver} onChange={ e => setReceiver(e.target.value)} />
      {displayMessage ? <div className='messageDiv'><p>{message}</p></div> : ""}
    </div>
  )
}

export default OwnCSOLmintTre;