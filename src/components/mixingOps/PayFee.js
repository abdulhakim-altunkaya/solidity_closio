import React, {useState} from 'react';
//getting user account info from redux storage
import { useSelector } from "react-redux";
//getting contract from zustand store
import { useAccount } from '../../Store';

function PayFee() {  
  //fetching user account from redux storage. 
  const userAccount2 = useSelector( (state) => state.userAccount);
  //fetching closio contract from zustand storage
  const contractClosio = useAccount(state => state.contractClosio2);

  let [message, setMessage] = useState("");

  const payFee = async () => {
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
      //check 3: if user has paid or not
      let paymentStatus = await contractClosio.feePayers(userAccount2);
      if(paymentStatus === true) {
        alert("You already have paid fee. You dont need to pay again");
        return;
      }
      //execution
      const tx = await contractClosio.payFee();
      await tx.wait();
      setMessage("You successfully paid service fee");
    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        alert("Paying fee failed");
        setMessage(error.error.data.message);
      } else {
        // Log all error message
        console.error(error);
      }
    }

  }

  return (
    <div>
        <button className='button10' onClick={payFee}>Pay Fee</button> {message}
    </div>
  )
}

export default PayFee;