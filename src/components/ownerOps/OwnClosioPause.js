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
    try {
      //check 1: if user has metamask installed on browser
      if(window.ethereum === "undefined") {
        alert("Please install Metamask to your Browser");
        return;
      }
      //Check 2: checking if owner and caller matches
      if (userAccount2.toLowerCase() !== AddressOwner.toLowerCase()) {
        alert("you are not owner");
        return;
      }
      //Execution
      let toggleResult = await contractClosio.togglePause();
      await toggleResult.wait();
      let contractStatus = await contractClosio.pauseContract();
      if (contractStatus === true) { 
        setMessage("Contract paused");
      } else if(contractStatus === false) {
        setMessage("Contract unpaused");
      } else { 
        alert("Status change failed. Probably, Platform contract connection failed.");
      }    
    } catch (error) { 
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        alert("Contract pause failed");
        setMessage(error.error.data.message);
      } else {
        // Log all error message
        console.error(error);
      }
    }

  }

  return (
    <div>
      <button className='button4' onClick={toggleContractStatus}>Pause</button>&nbsp;&nbsp;{message}
    </div>
  )
}

export default OwnClosioPause;