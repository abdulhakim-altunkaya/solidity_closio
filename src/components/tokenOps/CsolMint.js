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
      let status = await contractCSOL.mintFree();
      status.wait();
      setMessage("success, you minted 2 tokens");

    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the "from" field to the console
        console.error('Error Message:', error.error.data.message);
        alert("Free minting failed");
        setMessage(error.error.data.message);
      } else {
        // Log a message indicating that the "from" field is not available
        console.error('Transaction Sender not available', error);
      }
    }

  }

  return (
    <div>
      <button className='button4' onClick={mintToken}>Mint CSOL</button>&nbsp; {message}
    </div>
  )
}

export default CsolMint;
