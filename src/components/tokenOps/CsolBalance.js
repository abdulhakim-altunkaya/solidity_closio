import React, {useState} from 'react';
import { useAccount } from '../../Store';

function CsolBalance() {
  const contractCSOL = useAccount(state => state.contractCsol2);

  let [balance, setBalance] = useState("");

  const getBalanceCSOL = async () => {
    try {
      //check: if user has metamask installed on browser
      if(window.ethereum === "undefined") {
        alert("Please install Metamask to your Browser");
        return;
      }
      let bal = await contractCSOL.getYourTokenBalance();
      if (bal.toNumber() < 1) {
        setBalance("Balance is 0");
      } else {
        setBalance(bal.toNumber());
      }
    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        alert(`Seeing balance failed for some reasons. Make sure you logged in to the website with Metamask. ${error.error.data.message}`);
      } else {
        // Log all error message
        console.error(error);
      }
    }

    

  }

  return (
    <div>
      <button className='button4' onClick={getBalanceCSOL}>See Balance</button>
      <span className='spanTokens'>CSOL Balance: {balance}</span>
    </div>
  )
}

export default CsolBalance;