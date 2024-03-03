import React from 'react';
import RConnectMet from "./RConnectMet";

function TokenRead() {
  return (
    <div className='tokenReadDiv'>
      <p>
        How to use Closio platform: <br />
        1. You must be on Binance BSC Mainnet and have BNB coins. <br />
        2. Click "Connect Metamask" <br />
        3. Click "CSOL Operations" and then click "Mint CSOL" for 2 free CSOL <br />
        4. Click "Mint TestWBNB" for 50 free TestWBNB <br />
        5. Click "Mixer Operations" and then click "Approve CSOL".<br />
        6. Click "Approve WBNB". Logic:<br />
        <span>Deposit amount &lt; Approve amount &lt; Wallet Balance </span><br /> <br/>
        7. Think of a private word and write it in "Create a Hash" area and click "Create a Hash". <br />
        8. Save your private word and its hash. Don't share and don't forget private word. <br />
        9. Click "Pay Fee". <br />
        10. Go to "Deposit" area, enter hash and TestWBNB amount you want to deposit. <br />
        11. If you want to withdraw all, "Pay Fee", then click on "Withdraw All" <br />
        12. If you want to withdraw part, "Pay Fee", then click on "Withdraw Part".
      </p>
      <RConnectMet />
    </div>
  )
}

export default TokenRead;