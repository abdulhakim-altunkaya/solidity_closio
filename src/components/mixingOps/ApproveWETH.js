import React, {useState} from 'react';
//importing ethers package to add 18 zeros to the input amount
import { ethers } from "ethers";
//getting user account info from redux storage
import { useSelector } from "react-redux";
//getting contract from zustand store
import { useAccount } from '../../Store';
//fetching WETH address from project directory
import { AddressClosio } from "../addressABI/addressClosio";

function ApproveWETH() {

  //fetching user account from redux storage. 
  const userAccount2 = useSelector( (state) => state.userAccount);

  //fetching closio and csol contracts from zustand storage
  const contractClosio = useAccount(state => state.contractClosio2);
  const contractWETH = useAccount(state => state.contractWETH2);

  let [amount, setAmount] = useState("");
  let [message, setMessage] = useState("");

  const approveWETH = async () => {
    try {
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
      //check 3: if amount is bigger than 0
      if (amount === "" || amount <= 0 ) {
        alert("Invalid amount");
        return; 
      }
      //check 4: if user has WETH
      let userBalanceWETH1 = await contractClosio.getYourWETHBalance();
      let userBalanceWETH2 = userBalanceWETH1.toString();
      let userBalanceWETH3 = parseInt(userBalanceWETH2);
      if(userBalanceWETH3 <= 0) {
        alert("You dont have WBNB to approve");
        return;
      }
      //execution
      let amount1 = parseInt(amount);
      let amount2 = ethers.utils.parseUnits(amount1.toString(), 18);
      let tx = await contractWETH.approve(AddressClosio, amount2);
      await tx.wait();
      setMessage(`Success, approval amount: ${amount1}`);
    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        alert("Approval Failed");
        setMessage(error.error.data.message);
      } else {
        // Log all error message
        console.error(error);
      }
    }

  }

  return (
    <div>
        <button className='button10' onClick={approveWETH}>Approve WBNB</button> 
        <input type="number" className='inputFields' placeholder='WBNB amount'
          value={amount} onChange={ e => setAmount(e.target.value)} /> {message}
    </div>
  )
}

export default ApproveWETH;