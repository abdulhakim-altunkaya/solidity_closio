import React from 'react';
import { useNavigate } from 'react-router-dom';

function Upperbar() {
  const navigate = useNavigate();

  return (
    <div className='upperbarDiv'>
      <div className='upperbarLogoDiv'>
        <img src='logo.png' onClick={() => navigate("/")} alt='logo of the website. You can click on it to go to homepage'/>
      </div>
      <div className='upperbarButtonsDiv'>
        <span className='button6' onClick={() => navigate("/")}>CSOL TOKEN OPERATIONS</span>
        <span className='button6' onClick={() => navigate("/platform")}> MIXER & TRANSFERS</span>
      </div>
    </div>
  )
}

export default Upperbar;

