import React, {useState} from 'react';
import { useAccount } from "../../Store";

function CsolMint() {

  const contractCSOL = useAccount(state => state.contractCsol2);

  let [message, setMessage] = useState("");

  const mintToken = async () => {
    let status = await contractCSOL.mintFree();
    if (status === true) {
      setMessage("success, you minted 2 tokens");
    } else {
      setMessage("free minting failed");
    }
  }

  return (
    <div>
      <button className='button4' onClick={mintToken}>Mint CSOL</button> {message}
    </div>
  )
}

export default CsolMint;
