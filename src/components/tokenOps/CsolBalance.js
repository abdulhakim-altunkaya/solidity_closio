import React, {useState} from 'react';
import { useAccount } from '../../Store';

function CsolBalance() {
  const contractCSOL = useAccount(state => state.contractCsol2);

  let [balance, setBalance] = useState("");

  const getBalanceCSOL = async () => {
    let bal = await contractCSOL.getYourTokenBalance();
    if (bal.toNumber() < 1) {
      setBalance("Balance is 0");
    } else {
      setBalance(bal.toNumber());
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