import React, {useState} from 'react';
//Contract is fetched from Zustand store
import { useAccount } from '../../Store';

//fetch user account from redux storage. User account will be saved to Redux storage if user 
//login with metamask on homepage (RConnectMet component in tokenOps).
import { useSelector } from "react-redux";
import { AddressOwner } from "../addressABI/AddressOwner";


function OwnCSOLchange() {

  //fetching user account from redux storage. We will use this to check if person calling this is owner.
  //We have already done a check on parent Owner component. This check is a like an extra check.
  const userAccount2 = useSelector( (state) => state.userAccount)

  //fetching contract from Zustand and initiating other state variables
  const contractCSOL = useAccount(state => state.contractCsol2);

  let [newOwner, setNewOwner] = useState("");
  let [message, setMessage] = useState("");

  const changeOwner = async () => {
    //Security check 1: checking if owner and caller matches
    if (userAccount2.toLowerCase() !== AddressOwner.toLowerCase()) {
      alert("you are not owner");
      return;
    }
    //Security check 2: checking validity of address input
    if(newOwner.length < 20 || newOwner === "") {
      alert("Address is not correct");
      return;
    }
    //Security check 3: checking validity of address input
    if(newOwner.slice(0,2) !== "0x") {
      alert("Invalid address type");
      return;
    }

    //Execution
    await contractCSOL.transferOwnership(newOwner);
    setMessage("Owner changed");


  }
  return (
    <div>
      <button className='button4' id='buttonLength' onClick={changeOwner}>Csol Change Owner</button>
      <input type='text' className='inputFields' placeholder='new owner address'
        value={newOwner} onChange={ e => setNewOwner(e.target.value)} /><br />
      {message}
    </div>
  )
}

export default OwnCSOLchange;