import React, {useState} from 'react';
//getting contract from zustand store
import { useAccount } from '../../Store';

function GetBalances() {

  //fetching closio contract from zustand storage
  const contractClosio = useAccount(state => state.contractClosio2);

  let [balanceWBNBplatform, setBalanceWBNBplatform] = useState("");
  let [approvalWBNBuser, setApprovalWBNBuser] = useState("");
  let [approvalCSOLuser, setApprovalCSOLuser] = useState("");
  let [txFee, setTxFee] = useState("");

  const getBalances = async () => {
    try {
      //check 1: if user has metamask installed on browser
      if(window.ethereum === "undefined") {
        alert("Please install Metamask to your Browser");
        return;
      } 
      
      //fetching platform WBNB
      let platformWBNB1 = await contractClosio.getContractWETHBalance();
      let platformWBNB2 = platformWBNB1.toString();
      let platformWBNB3 = parseInt(platformWBNB2);

      //fetching allowance WBNB
      let allowanceWETH1 = await contractClosio.getUserWETHApproval();
      let allowanceWETH2 = allowanceWETH1.toString();
      let allowanceWETH3 = parseInt(allowanceWETH2); 

      //fetching allowance CSOL
      let allowanceCSOL1 = await contractClosio.getUserCSOLApproval();
      let allowanceCSOL2 = allowanceCSOL1.toString();
      let allowanceCSOL3 = parseInt(allowanceCSOL2);

      //fetching platform fee
      let platformFee1 = await contractClosio.fee();
      let platformFee2 = platformFee1.toString();
      let platformFee3 = parseInt(platformFee2);

      
      setBalanceWBNBplatform(platformWBNB3);
      setApprovalWBNBuser(allowanceWETH3);
      setApprovalCSOLuser(allowanceCSOL3);
      setTxFee(platformFee3);

    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        alert("Getting balances failed");
      } else {
        // Log all error message
        console.error(error);
      }
    }

  }


  return (
    <div>

      <button onClick={getBalances} className='button10'>GET BALANCES</button> <br />

      <>
        <strong><span>Closio WBNB Pool Balance:</span></strong> {balanceWBNBplatform} WBNB<br />
        <strong>User WBNB Allowance:</strong> {approvalWBNBuser} WBNB <br />
        <strong>User CSOL Allowance:</strong> {approvalCSOLuser} CSOL <br />
        <strong>Deposit and Withdrawal Fee:</strong> {txFee} CSOL <br /> <br />
      </>

    </div>
  )
}

export default GetBalances;