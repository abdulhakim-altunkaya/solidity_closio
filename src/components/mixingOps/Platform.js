import React from 'react';
import GetBalances from "./GetBalances";
import ApproveFee from "./ApproveFee";
import ApproveWETH from "./ApproveWETH";
import PayFee from "./PayFee";
import CreateHash from "./CreateHash";
import Deposit from "./Deposit";
import WithdrawAll from "./WithdrawAll";
import WithdrawPart from "./WithdrawPart";

function Platform() {
  return (
    <div>
      <GetBalances />
      <ApproveFee />
      <ApproveWETH />
      <PayFee />
      <CreateHash />
      <Deposit />
      <WithdrawAll />
      <WithdrawPart />
      <p id='aboutText'>Closio by Abdulhakim Altunkaya. 2024</p>
    </div>
  )
}

export default Platform;