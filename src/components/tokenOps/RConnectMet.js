import React, {useState} from 'react';

import { useDispatch } from 'react-redux';
import { setUserAccount } from "../../state/sliceAccount"; 

function RConnectMet() {

  //Redux toolkit variable to store user account to be used across components
  const dispatch = useDispatch();

  const {ethereum} = window;
  let [displayStatus, setDisplayStatus] = useState(false);

  let [account, setAccount] = useState("");

  const connectMetamask = async () => {
    if(window.ethereum !== "undefined") {
      const accounts = await ethereum.request({ method: "eth_requestAccounts" });
      setAccount(accounts[0]);
      setDisplayStatus(true);
      //user account is saved to redux storage to be used by all components. 
      dispatch(setUserAccount(accounts[0]));
    } else {
      alert("Install Metamask please");
      return;
    }
  }

  const hideDetails = () => {
    setDisplayStatus(false);
  }

  return (
    <>
      <button onClick={connectMetamask} className='button9'>CONNECT METAMASK</button>
      { displayStatus === true ?
        <>
          <div className='contractDetailsDiv'>
              <span>Your Metamask Account:</span>  <br />{account} <br /> 
              <span>Closio Platform address:</span> 0xC65f8b1C0F135d42fwefwefwefwefwefwefwF247 <br />
              <span>Closio Token address:</span> 0xC65f8b1C0F135d422ea5850aEC33A2222cFCF247 <br />
              <span>Closio Token symbol:</span> CSOL<br />
              <span>CSOL cap: </span>  1000000000 (1 billion) <br />
              <span>CSOL Standard & Decimals:</span>  BEP20 & 18 <br />
              <span>Network:</span> Binance BSC Mainnet <br />
              <span>Owner address:</span> 0x0FFeAf1dd1B54606CdD816B97BaCF51936E3d35a <br />   
          </div>
          <button className='hidingButton' onClick={hideDetails}>Hide Details</button>
        </>
      :
        <></>
      }
    </>

  )
}

export default RConnectMet;