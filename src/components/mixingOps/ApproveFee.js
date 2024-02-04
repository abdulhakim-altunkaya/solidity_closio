import React, {useState} from 'react';
//getting user account info from redux storage
import { useSelector } from "react-redux";
//getting contract from zustand store
import { useAccount } from '../../Store';
import { AddressClosio } from "../addressABI/addressClosio";

function ApproveFee() {

  //fetching user account from redux storage. 
  const userAccount2 = useSelector( (state) => state.userAccount);

  //fetching closio and csol contracts from zustand storage
  const contractClosio = useAccount(state => state.contractClosio2);
  const contractCSOL = useAccount(state => state.contractCsol2);

  let [message, setMessage] = useState("");

  const approveCsol = async () => {
    
    //check 1: if user has metamask installed on browser
    if(window.ethereum === "undefined") {
      alert("Please install Metamask to your Browser");
      return;
    }
    
    //check 2: if user has signed in or not
    if (userAccount2 === "undefined" || userAccount2 === "") {
      alert("Please sign in to website. Go to Token Operations section and click on Connect Metamask button.");
      return;
    }
    
    //check 3: if user has CSOL
    let userBalanceCSOL1 = await contractCSOL.getYourTokenBalance();
    let userBalanceCSOL2 = userBalanceCSOL1.toString();
    let userBalanceCSOL3 = parseInt(userBalanceCSOL2);
    if(userBalanceCSOL3 < 1) {
      alert("You dont have CSOL to approve. You can buy on exchanges or you may mint it for free on Token Operations sections");
      return;
    }

    //execution
    await contractCSOL.approveClosioCsol(AddressClosio, 10);
    setMessage(`Success, approval amount: 10 CSOL`);
    
  }

  return (
    <div>
        <button className='button10' onClick={approveCsol}>Approve CSOL</button> {message}
    </div>
  )
}

export default ApproveFee;