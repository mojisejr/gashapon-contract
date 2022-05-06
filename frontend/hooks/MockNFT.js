import { useState } from "react";
import { ethers } from "ethers";
// import { abi, address } from "../abi/abi";

const ContractState = {
  LOADING: "loading",
  SUCCESS: "success",
  ERROR: "error",
  IDLE: "idle",
  READY: "ready",
};

const abi = [
  "function mint()",
  "function getCurrentTokenId() view returns(uint256)",
  "function setApprovalForAll(address to, bool approved)",
  "function isApprovedForAll(address owner, address operator) view returns(bool)",
];

const address = "0x5bd65f029309bB9ae0d16De97D218CA517D0E563";

export function useNFT() {
  const [contract, setContract] = useState(null);
  const [contractState, setContractState] = useState(ContractState.IDLE);

  async function init(provider) {
    const signer = provider?.getSigner();
    const contract = new ethers.Contract(address, abi, signer);
    setContract(contract);
    setContractState(ContractState.READY);
  }

  async function mint() {
    if (contractState == ContractState.READY) {
      await contract.mint();
      // await contract.getCurrentBoxId();
    } else {
      alert("contract is not ready");
    }
  }

  async function getCurrentTokenId() {
    if (contractState == ContractState.READY) {
      const tokenId = await contract.getCurrentTokenId();
      return tokenId.toString();
    }
  }

  async function setApprovalForAll(box, owner) {
    const isApproved = await contract.isApprovedForAll(owner, box.address);
    console.log(isApproved);
    if (isApproved) {
      return;
    }
    await contract.setApprovalForAll(box.address, true);
  }

  return {
    init,
    mint,
    getCurrentTokenId,
    setApprovalForAll,
    state: contractState,
  };
}
