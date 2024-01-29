import React, {useState} from 'react';
//Contract is fetched from Zustand store
import { useAccount } from '../../Store';

//fetch user account from redux storage. User account will be saved to Redux storage if user 
//login with metamask on homepage (RConnectMet component in tokenOps).
import { useSelector } from "react-redux";
import { AddressOwner } from "../addressABI/AddressOwner";


function OwnCSOLmintTeam() {

  //fetching user account from redux storage. We will use this to check if person calling this is owner.
  //We have already done a check on parent Owner component. This check is a like an extra check.
  const userAccount2 = useSelector( (state) => state.userAccount)

  //fetching contract from Zustand and initiating other state variables
  const contractCSOL = useAccount(state => state.contractCsol2);
  let [amount, setAmount] = useState("");
  let [receiver, setReceiver] = useState("");
  let [message, setMessage] = useState("");

  const mintDevelopers = async () => {
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
    //Security check 5: checking if limit of team/developers tokens reached (50 million)
    let devTokens1 = await contractCSOL.teamTokens();
    let devTokens2 = devTokens1.toString();
    let devTokens3 = parseInt(devTokens2);
    if(devTokens3 + amount1 > 50000000) {
      alert("Limit of team/developers tokens reached. You cannot mint more");
      return;
    }

    //Execution
    let mintResult = await contractCSOL.mintTeam(amount1, receiver);
    if (mintResult === true) {
      setMessage("Minting successful");
    } else {
      alert("Minting failed. Error code: CSOL contract mintTeam function returned false.")
    }

  }
  return (
    <div>
      <button className='button4' id='buttonLength' onClick={mintDevelopers}>Csol Mint Team</button>
      <input type='number' className='inputFields' placeholder='amount' 
        value={amount} onChange={ e => setAmount(e.target.value)} />
      <input type='text' className='inputFields' placeholder='receiver address'
        value={receiver} onChange={ e => setReceiver(e.target.value)} /><br />
      {message}
    </div>
  )
}

export default OwnCSOLmintTeam;