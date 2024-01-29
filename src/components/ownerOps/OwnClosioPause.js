import React, {useState} from 'react';
//Contract is fetched from Zustand store
import { useAccount } from '../../Store';

//fetch user account from redux storage. User account will be saved to Redux storage if user 
//login with metamask on homepage (RConnectMet component in tokenOps).
import { useSelector } from "react-redux";
import { AddressOwner } from "../addressABI/AddressOwner";


function OwnClosioPause() {

  //fetching user account from redux storage. We will use this to check if person calling this is owner.
  //We have already done a check on parent Owner component. This check is a like an extra check.
  const userAccount2 = useSelector( (state) => state.userAccount)

  //fetching contract from Zustand
  const contractClosio = useAccount(state => state.contractClosio2);

  let [message, setMessage] = useState("");

  const toggleContractStatus = async () => {
    //Security check 1: checking if owner and caller matches
    if (userAccount2.toLowerCase() !== AddressOwner.toLowerCase()) {
      alert("you are not owner");
      return;
    }

    //Execution
    let toggleResult = await contractClosio.togglePause();
    let contractStatus = await contractClosio.pauseContract();
    if (toggleResult === true && contractStatus === true) { 
      setMessage("Contract paused");
    } else if(toggleResult === true && contractStatus === false) {
      setMessage("Contract unpaused");
    } else { 
      alert("Status change failed. Error code: Closio contract togglePause function did not return true");
    }

  }
  return (
    <div>
      <button className='button4' onClick={toggleContractStatus}>Pause</button> {message}
    </div>
  )
}

export default OwnClosioPause;