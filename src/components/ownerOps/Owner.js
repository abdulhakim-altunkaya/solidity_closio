import React, {useState} from 'react';
import OwnCSOLmintExc from "./OwnerCSOLmintExc";
import OwnCSOLmintInv from "./OwnerCSOLmintInv";
import OwnCSOLmintTeam from "./OwnerCSOLmintTeam";
import OwnCSOLmintTre from "./OwnCSOLmintTre";
import OwnCSOLtoggleFree from "./OwnerCSOLtoggleFree";
import OwnCSOLchange from "./OwnerCSOLchange";
import { AddressOwner } from "../addressABI/AddressOwner";
//fetch user account from redux storage. User account will be saved to Redux storage if user 
//login with metamask on homepage (RConnectMet component in tokenOps).
import { useSelector } from "react-redux";

function Owner() {
  //fetching user account from redux storage
  const userAccount2 = useSelector( (state) => state.userAccount)


  let [displayStatus, setDisplayStatus] = useState(false);

  const toggleDisplay = async () => {
    if (userAccount2.toLowerCase() !== AddressOwner.toLowerCase()) {
      alert("you are not owner");
      return;
    } else {
      setDisplayStatus(!displayStatus);
    }
    
  }
  return (
    <div>
      <button className='button9' id='btnRed' onClick={toggleDisplay}>Owner Operations</button>
      {displayStatus === true ?
        <>
          <OwnCSOLmintExc />
          <OwnCSOLmintInv />
          <OwnCSOLmintTeam />
          <OwnCSOLmintTre />
          <OwnCSOLtoggleFree />
          <OwnCSOLchange />
        </>
        :
        <></>
      }
    </div>
  )
}

export default Owner;
