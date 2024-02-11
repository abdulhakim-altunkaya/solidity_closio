import React, {useState} from 'react';
//Contract is fetched from Zustand store
import { useAccount } from '../../Store';

//fetch user account from redux storage. User account will be saved to Redux storage if user 
//login with metamask on homepage (RConnectMet component in tokenOps).
import { useSelector } from "react-redux";
import { AddressOwner } from "../addressABI/AddressOwner";


function OwnClosioSetCSOL() {

  //fetching user account from redux storage. We will use this to check if person calling this is owner.
  //We have already done a check on parent Owner component. This check is a like an extra check.
  const userAccount2 = useSelector( (state) => state.userAccount)

  //fetching contract from Zustand
  const contractClosio = useAccount(state => state.contractClosio2);

  let [csolAddress, setCsolAddress] = useState("");
  let [message, setMessage] = useState("");

  const assignCsol = async () => {
    //Security check 1: checking if owner and caller matches
    if (userAccount2.toLowerCase() !== AddressOwner.toLowerCase()) {
      alert("you are not owner");
      return;
    }
    //Security check 2: checking validity of address input
    if(csolAddress.length < 20 || csolAddress === "") {
      alert("Address is not correct");
      return;
    }
    //Security check 3: checking validity of address input
    if(csolAddress.slice(0,2) !== "0x") {
      alert("Invalid address type");
      return;
    }

    //Execution
    let setCSOLresult = await contractClosio.setTokenCSOL(csolAddress);
    await setCSOLresult.wait();
    if (setCSOLresult === true) {
      setMessage("CSOL address set.");
    } else {
      alert("Setting CSOL address failed. Error code: Closio contract setTokenCSOL function did not return true");
    }


  }
  return (
    <div>
      <button className='button4' onClick={assignCsol}>Set CSOL</button>
      <input type='text' className='inputFields' placeholder='CSOL Address'
        value={csolAddress} onChange={ e => setCsolAddress(e.target.value)} /> {message}
    </div>
  )
}

export default OwnClosioSetCSOL;