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

  let [privateWord, setPrivateWord] = useState("");
  let [hashOutput, setHashOutput] = useState("");
  let [message, setMessage] = useState("");
  let [displayMessage, setDisplayMessage] = useState(false);

  const makeHash = async () => {
    try {
        //check 1: if user has metamask installed on browser
        if(window.ethereum === "undefined") {
        alert("Please install Metamask to your Browser");
        return;
      }
      //check 2: if user has signed in or not
      if (userAccount2 === "undefined" || userAccount2 === "") {
        alert("Please sign in to website. Go to Token Operations section and click on Connect Metamask button.");
        return;
      }
      //check 3 and 4: private word input validations
      if(privateWord.length < 3 || privateWord.length > 1000) {
        alert("Private word length must be: 3-1000 characters");
        return;
      }
      if(privateWord === "") {
        alert("Enter something into the input field");
        return;
      }
      let newHash = await contractClosio.createHashSalty(privateWord);
      setDisplayMessage(true);
      setMessage("The keccak256 hash of your private word is: ");
      setHashOutput(newHash);

    } catch (error) {
      // Check if the error contains the "transaction" field
      if (error.transaction && error.transaction.from) {
        // Log the error.message field
        console.error('Error Message:', error.error.data.message);
        alert("Hash creation failed");
        setDisplayMessage(true);
        setMessage(error.error.data.message);
      } else {
        // Log all error message
        console.error(error);
      }
    }
    
  }

  return (
    <div>
      <br/>
      <button className='button10' onClick={makeHash}>Create a Hash</button>
      <input type='text' className='inputFields' placeholder='private keyword'
        value={privateWord} onChange={e => setPrivateWord(e.target.value)} /> 
      {displayMessage ? <p className='messageDiv'>{message} <br/> {hashOutput}</p> : ""}
    </div>
  )
}

export default CreateHash;
