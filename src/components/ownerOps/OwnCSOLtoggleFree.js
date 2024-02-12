import React, {useState} from 'react';
//Contract is fetched from Zustand store
import { useAccount } from '../../Store';

//fetch user account from redux storage. User account will be saved to Redux storage if user 
//login with metamask on homepage (RConnectMet component in tokenOps).
import { useSelector } from "react-redux";
import { AddressOwner } from "../addressABI/AddressOwner";


function OwnCSOLtoggleFree() {

  //fetching user account from redux storage. We will use this to check if person calling this is owner.
  //We have already done a check on parent Owner component. This check is a like an extra check.
  const userAccount2 = useSelector( (state) => state.userAccount)

  //fetching contract from Zustand and initiating other state variables
  const contractCSOL = useAccount(state => state.contractCsol2);
  let [message, setMessage] = useState("");

  const toggleFreeMinting = async () => {
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
      let freeStatus = await contractCSOL.freeMinting();
      //Execution
      let toggleResult = await contractCSOL.toggleFree();
      await toggleResult.wait();
      if (freeStatus === true) {
        setMessage("Free Minting Enabled");
      } else if(freeStatus === false) {
        setMessage("Free Minting Disabled");
      } else {
        alert("Toggle failed. Probably connection to Platform Contract failed")
      }
    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        alert("Toggling CSOL free mint failed");
        setMessage(error.error.data.message);
      } else {
        // Log all error message
        console.error(error);
      }
    }
  }
  return (
    <div>
      <button className='button4' id='buttonLength' onClick={toggleFreeMinting}>Csol Toggle Free</button> {message}
    </div>
  )
}

export default OwnCSOLtoggleFree;