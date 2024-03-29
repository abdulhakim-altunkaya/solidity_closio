import React, {useState} from 'react';
import CsolMint from "./CsolMint";
import CsolBurn from "./CsolBurn";
import CsolBalance from "./CsolBalance";
import TestWBNBmint from "./TestWBNBmint";

function CsolToken() {

  let [displayStatus, setDisplayStatus] = useState(false);

  const toggleDisplay = () => {
    setDisplayStatus(!displayStatus);
  }

  return (
    <div>
      <button className='button9' onClick={toggleDisplay}>CSOL Operations</button>
      { displayStatus === true ?
          <>
            <CsolMint />
            <CsolBurn />
            <CsolBalance />
            <TestWBNBmint />
          </>
        :
          <></>
      }
    </div>
  )
}

export default CsolToken;