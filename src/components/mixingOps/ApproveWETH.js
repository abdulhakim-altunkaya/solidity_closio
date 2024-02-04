import React, {useState} from 'react';
//getting user account info from redux storage
import { useSelector } from "react-redux";
//getting contract from zustand store
import { useAccount } from '../../Store';

function ApproveWETH() {

  //fetching user account from redux storage. 
  const userAccount2 = useSelector( (state) => state.userAccount);

  //fetching closio and csol contracts from zustand storage
  const contractClosio = useAccount(state => state.contractClosio2);
  const contractCSOL = useAccount(state => state.contractCsol2);

  let [amount, setAmount] = useState("");
  let [message, setMessage] = useState("");

  const approveWETH = async () => {
    
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
      alert("Invalid WBNB amount");
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
    await contractClosio.approveClosioWeth(amount1);
    setMessage(`Success, approval amount: ${amount1} WETH`);
    
  }

  return (
    <div>
        <button className='button10' onClick={approveWETH}>Approve WETH</button> 
        <input type="number" className='inputFields' placeholder='WBNB amount'
          value={amount} onChange={ e => setAmount(e.target.value)} /> {message}
    </div>
  )
}

export default ApproveWETH;