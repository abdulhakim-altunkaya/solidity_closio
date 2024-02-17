import React, {useState} from 'react';
//saving user account to Redux storage
import { useDispatch } from 'react-redux';
import { setUserAccount } from "../../state/sliceAccount"; 

//getting contract from zustand store
import { useAccount } from '../../Store';

function RConnectMet() {

  //fetching closio contract from zustand storage
  const contractClosio = useAccount(state => state.contractClosio2);
  const contractCSOL = useAccount(state => state.contractCsol2);

  //Redux toolkit variable to store user account to be used across components
  const dispatch = useDispatch();

  const {ethereum} = window;
  let [displayStatus, setDisplayStatus] = useState(false);

  let [account, setAccount] = useState("");
  let [csolAddress, setCsolAddress] = useState("");
  let [closioAddress, setClosioAddress] = useState("");
  let [ownerAddress, setOwnerAddress] = useState("");

  const connectMetamask = async () => {
    if(window.ethereum !== "undefined") {
      const accounts = await ethereum.request({ method: "eth_requestAccounts" });
      setAccount(accounts[0]);
      setDisplayStatus(true);
      //user account is saved to redux storage to be used by all components. 
      dispatch(setUserAccount(accounts[0]));
      let csolAddr = await contractCSOL.address;
      let closioAddr = await contractClosio.address;
      let ownerAddr = await contractCSOL.owner();
      setCsolAddress(csolAddr);
      setClosioAddress(closioAddr);
      setOwnerAddress(ownerAddr);
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
              <span>Closio Platform address:</span> {closioAddress} <br />
              <span>Closio Token address:</span> {csolAddress} <br />
              <span>Closio Token symbol:</span> CSOL<br />
              <span>CSOL cap: </span>  1000000000 (1 billion) <br />
              <span>CSOL Standard & Decimals:</span>  BEP20 & 18 <br />
              <span>Network:</span> Binance BSC Mainnet <br />
              <span>Owner address:</span> {ownerAddress} <br />   
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