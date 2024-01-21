import React from 'react';
import TokenRead from "./tokenOps/TokenRead";
import TokenWrite from "./tokenOps/TokenWrite";

function LowToken() {
  return (
    <div className='mainTokenDiv'>
      <TokenRead />
      <TokenWrite/>
    </div>
  )
}

export default LowToken;