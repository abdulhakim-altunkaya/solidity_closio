import React, { useState } from 'react';
import { useAccount } from '../../Store';

function CsolBurn() {
  const contractCSOL = useAccount(state => state.contractCsol2);
  let [amount, setAmount] = useState("");
  let [message, setMessage] = useState("");

  const burnToken = async () => {
    try {
      //check: if user has metamask installed on browser
      if(window.ethereum === "undefined") {
        alert("Please install Metamask to your Browser");
        return;
      }
      let amount1 = parseInt(amount);
      if (amount1 < 1 || amount1 === "") {
        alert("please enter a valid amount");
        return;
      }
      let userBalance = await contractCSOL.getYourTokenBalance();
      let userBalance2 = userBalance.toString();
      let userBalance3 = parseInt(userBalance2);
      if(userBalance3 < 1) {
        alert("you dont have CSOL to burn");
        return;
      }
      let burningTx = await contractCSOL.burnToken(amount1);
      await burningTx.wait();
      setMessage(`success, ${amount1} csol burned`);
    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        //alert("Burning CSOL tokens failed. Make sure you logged in to the website with Metamask and have CSOL tokens to burn.");
        setMessage(error.error.data.message);
      } else {
        // Log all error message
        console.error(error);
      }
    }


  }

  return (
    <div>
      <button className='button4' onClick={burnToken}>Burn CSOL</button>
      <input type='number' className='inputFields' placeholder='amount'
        value={amount} onChange={ e => setAmount(e.target.value)} /> {message}
    </div>
  )
}

export default CsolBurn;

