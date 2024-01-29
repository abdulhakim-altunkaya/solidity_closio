import React, {useState} from 'react';
//Contract is fetched from Zustand store
import { useAccount } from '../../Store';

//fetch user account from redux storage. User account will be saved to Redux storage if user 
//login with metamask on homepage (RConnectMet component in tokenOps).
import { useSelector } from "react-redux";
import { AddressOwner } from "../addressABI/AddressOwner";


function OwnClosioGetFees() {

  //fetching user account from redux storage. We will use this to check if person calling this is owner.
  //We have already done a check on parent Owner component. This check is a like an extra check.
  const userAccount2 = useSelector( (state) => state.userAccount)

  //fetching contract from Zustand and initiating other state variables
  const contractClosio = useAccount(state => state.contractClosio2);

  let [message, setMessage] = useState("");

  const collectAllFees = async () => {
    //Security check 1: checking if owner and caller matches
    if (userAccount2.toLowerCase() !== AddressOwner.toLowerCase()) {
      alert("you are not owner");
      return;
    }

    //Execution
    let collectResult = await contractClosio.collectFees();
    if (collectResult === true) {
      setMessage("Fees collected");
    } else { 
      alert("Fee Collection failed. Error code: Closio contract collectFees function did not return true");
    }

  }
  return (
    <div>
      <button className='button4' onClick={collectAllFees}>Collect Fees</button> {message}
    </div>
  )
}

export default OwnClosioGetFees;