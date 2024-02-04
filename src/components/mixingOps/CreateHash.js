import React, {useState} from 'react';
//getting user account info from redux storage
import { useSelector } from "react-redux";
//getting contract from zustand store
import { useAccount } from '../../Store';

function CreateHash() {

  //fetching user account from redux storage. 
  const userAccount2 = useSelector( (state) => state.userAccount);

  //fetching closio and csol contracts from zustand storage
  const contractClosio = useAccount(state => state.contractClosio2);
  const contractCSOL = useAccount(state => state.contractCsol2);

  let [privateWord, setPrivateWord] = useState("");
  let [hashOutput, setHashOutput] = useState("");
  let [message, setMessage] = useState("");

  const makeHash = async () => {
    if(privateWord.length < 1 || privateWord.length > 1000) {
      alert("Private word length must be: 1-1000 characters (security check 1)");
      return;
    }

    if(privateWord === "") {
      alert("Enter something into the input field (security check 2)");
      return;
    }

    let newHash = await contractClosio.createHashSalty(privateWord);
    setMessage("The keccak256 hash of your private word is: ");
    setHashOutput(newHash);

  }

  return (
    <div>
      <br/>
      <button className='button10' onClick={makeHash}>Create a Hash</button>
      <input type='text' className='inputFields' placeholder='private keyword'
        value={privateWord} onChange={e => setPrivateWord(e.target.value)} /> <br/>
      {message} <br/>
      {hashOutput}
    </div>
  )
}

export default CreateHash;
