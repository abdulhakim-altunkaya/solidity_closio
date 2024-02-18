import React, {useState} from 'react';
import { useAccount } from "../../Store";

function CsolMint() {

  const contractCSOL = useAccount(state => state.contractCsol2);

  let [message, setMessage] = useState("");
 
  const mintToken = async () => {

    try {
      //check 1: if user has metamask installed on browser
      if(window.ethereum === "undefined") {
        alert("Please install Metamask to your Browser");
        return;
      }
      let tx = await contractCSOL.mintFree();
      await tx.wait();
      setMessage("Success, you minted 2 tokens");

    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        alert("Free minting failed");
        setMessage(error.error.data.message);
      } else {
        // Log all error message
        console.error(error);
      }
    }

  }

  return (
    <div>
      <button className='button4' onClick={mintToken}>Mint CSOL</button>&nbsp;&nbsp; {message}
    </div>
  )
}

export default CsolMint;
