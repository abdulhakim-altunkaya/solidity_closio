import React, { useState } from 'react';
import { useAccount } from '../../Store';

function CsolBurn() {
  const contractCSOL = useAccount(state => state.contractCsol2);
  let [amount, setAmount] = useState("");
  let [message, setMessage] = useState("");

  const burnToken = async () => {
    let amount1 = parseInt(amount);
    if (amount1 < 1 || amount1 === "") {
      alert("please enter a valid amount");
      return;
    }

    let userBalance = await contractCSOL.getYourTokenBalance();
    let userBalance2 = userBalance.toString();
    let userBalance3 = parseInt(userBalance);
    if(userBalance3 < 1) {
      alert("you dont have CSOL to burn");
      return;
    }
    await contractCSOL.burnToken(amount1);
    setMessage("success, you burned", amount1, "tokens");
  }

  return (
    <div>
      <button className='button4' onClick={burnToken}>Burn CSOL</button>
      <input type='number' className='inputFields' placeholder='enter amount'
        value={amount} onChange={ e => setAmount(e.target.value)} /> {message}
    </div>
  )
}

export default CsolBurn;

