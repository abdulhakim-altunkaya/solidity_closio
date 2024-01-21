import React from 'react';
import RConnectMet from "./RConnectMet";

function TokenRead() {
  return (
    <div className='tokenReadDiv'>
      <p>To use this website: <br/>
      1. Make sure you have Metamask installed on your browser, <br/>
      2. Make sure you are on Binance BSC Mainnet <br/>
      3. Make sure you have WBNB tokens for transfers and CSOL tokens for paying platform fees.
      </p>
      <RConnectMet />
    </div>
  )
}

export default TokenRead;