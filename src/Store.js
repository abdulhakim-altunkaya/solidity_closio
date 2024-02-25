import { create } from "zustand";
import { ethers } from "ethers";
import { ABICsol } from "./components/addressABI/ABICsol";
import { ABIClosio } from "./components/addressABI/ABIClosio";
import { AddressCsol } from "./components/addressABI/addressCsol";
import { AddressClosio } from "./components/addressABI/addressClosio";
import { AddressWETH } from "./components/addressABI/addressWETH";


let signer;
let provider;
let contractCsol1;
let contractClosio1;
let contractWETH1;

const connectContract = async () => {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    signer = provider.getSigner();
    contractCsol1 = new ethers.Contract(AddressCsol, ABICsol, signer);
    contractClosio1 = new ethers.Contract(AddressClosio, ABIClosio, signer);
    contractWETH1 = new ethers.Contract(AddressWETH, ['function approve(address spender, uint256 amount) public returns (bool)'], signer);
}

connectContract();

export const useAccount = create(() => ({
  contractCsol2: contractCsol1,
  contractClosio2: contractClosio1,
  contractWETH2: contractWETH1,
}));





