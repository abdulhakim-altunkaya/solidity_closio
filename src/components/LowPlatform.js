import React from 'react';
import Platform from "./mixingOps/Platform";
//User Account wil be fetched from redux storage
import { useSelector } from "react-redux";

function LowPlatform() {
  //fetching user account from redux storage
  const userAccount2 = useSelector( (state) => state.userAccount)


  return (
    <div>
      <Platform />
      {userAccount2}
    </div>
  )
}

export default LowPlatform;