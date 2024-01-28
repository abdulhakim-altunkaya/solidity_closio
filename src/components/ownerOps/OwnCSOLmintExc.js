import React, {useState} from 'react';
//Contract is fetched from Zustand store
import { useAccount } from '../../Store';

//fetch user account from redux storage. User account will be saved to Redux storage if user 
//login with metamask on homepage (RConnectMet component in tokenOps).
import { useSelector } from "react-redux";
import { AddressOwner } from "../addressABI/AddressOwner";


function OwnCSOLmintExc() {

  //fetching user account from redux storage. We will use this to check if person calling this is owner.
  //We have already done a check on parent Owner component. This check is a like an extra check.
  const userAccount2 = useSelector( (state) => state.userAccount)

  //fetching contract from Zustand and initiating other state variables
  const contractCSOL = useAccount(state => state.contractCsol2);
  let [amount, setAmount] = useState("");
  let [receiver, setReceiver] = useState("");
  let [message, setMessage] = useState("");

  const mintExc = async () => {
    //Security check 1: checking if owner and caller matches
    if (userAccount2.toLowerCase() !== AddressOwner.toLowerCase()) {
      alert("you are not owner");
      return;
    }
    //Security check 2: checking validity of amount input
    let amount1 = parseInt(amount);
    if (amount1 < 1 || amount1 === "") {
      alert("Please enter a valid amount");
      return;
    }
    //Security check 3: checking validity of address input
    if(receiver.length < 20 || receiver === "") {
      alert("Address is not correct");
      return;
    }
    //Security check 4: checking validity of address input
    if(receiver.slice(0,2) !== "0x") {
      alert("Invalid address type");
      return;
    }
    //Security check 5: checking if limit of exchange tokens reached (600 million)
    let excTokens1 = await contractCSOL.exchangeTokens();
    let excTokens2 = excTokens1.toString();
    let excTokens3 = parseInt(excTokens2);
    if(excTokens3 + amount1 > 600000000) {
      alert("Limit of exchange tokens reached. You cannot mint more");
      return;
    }

    //Execution
    let mintResult = await contractCSOL.mintExchanges(amount1, receiver);
    if (mintResult === true) {
      setMessage("Minting successful");
    } else {
      alert("Exchange minting failed failed. Error code: CSOL contract mintExchanges function returned false.")
    }

  }
  return (
    <div>
      <button className='button4' id='buttonLength' onClick={mintExc}>Csol Mint Exchange</button>
      <input type='number' className='inputFields' placeholder='amount' 
        value={amount} onChange={ e => setAmount(e.target.value)} />
      <input type='text' className='inputFields' placeholder='receiver address'
        value={receiver} onChange={ e => setReceiver(e.target.value)} /><br />
      {message}
    </div>
  )
}

export default OwnCSOLmintExc;