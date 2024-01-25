import { create } from "zustand";
import { ethers } from "ethers";
import { ABICsol } from "./components/addressABI/ABICsol";
import { ABIClosio } from "./components/addressABI/ABIClosio";
import { AddressCsol } from "./components/addressABI/addressCsol";
import { AddressClosio } from "./components/addressABI/addressClosio";


let signer;
let provider;
let contractCsol1;
let contractClosio1;

const connectContract = async () => {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    signer = provider.getSigner();
    contractCsol1 = new ethers.Contract(AddressCsol, ABICsol, signer);
    contractClosio1 = new ethers.Contract(AddressClosio, ABIClosio, signer);
}

connectContract();

export const useAccount = create(() => ({
  contractCsol2: contractCsol1,
  contractClosio2: contractClosio1,
}));





