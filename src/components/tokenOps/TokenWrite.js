import React from 'react';
import CsolToken from "./CsolToken";
import Owner from "../ownerOps/Owner";

function TokenWrite() {
  return (
    <div className='tokenWriteDiv'>
      <CsolToken />
      <Owner />
    </div>
  )
}

export default TokenWrite;