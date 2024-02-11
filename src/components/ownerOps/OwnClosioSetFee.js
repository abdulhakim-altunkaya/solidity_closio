import React, {useState} from 'react';
//Contract is fetched from Zustand store
import { useAccount } from '../../Store';

//fetch user account from redux storage. User account will be saved to Redux storage if user 
//login with metamask on homepage (RConnectMet component in tokenOps).
import { useSelector } from "react-redux";
import { AddressOwner } from "../addressABI/AddressOwner";

function OwnClosioSetFee() {

  //fetching user account from redux storage. We will use this to check if person calling this is owner.
  //We have already done a check on parent Owner component. This check is a like an extra check.
  const userAccount2 = useSelector( (state) => state.userAccount)

  //fetching contract from Zustand
  const contractClosio = useAccount(state => state.contractClosio2);

  let [amount, setAmount] = useState("");
  let [message, setMessage] = useState("");

  const setServiceFee = async () => {
    //Security check 1: checking if owner and caller matches
    if (userAccount2.toLowerCase() !== AddressOwner.toLowerCase()) {
      alert("you are not owner");
      return; 
    }
    //Security check 2: checking validity of amount input
    let amount1 = parseInt(amount);
    if (amount1 < 1 || amount1 === "" || amount1 > 10000) {
      alert("Please enter a valid amount");
      return;
    }

    //Execution
    let setFeeResult = await contractClosio.setFee(amount1);
    let newFee = await contractClosio.fee();
    if (setFeeResult === true) {
      setMessage(`Fee changed. New fee: ${newFee} CSOL`);
    } else {
      alert("Fee change failed. Error code: Closio contract setFee function did not return true");
    }
  }

  return (
    <div>
      <button className='button4' onClick={setServiceFee}>Set Fee</button>
      <input type='number' className='inputFields' placeholder='new fee' 
        value={amount} onChange={ e => setAmount(e.target.value)} /> {message}
    </div>
  )
}

export default OwnClosioSetFee;