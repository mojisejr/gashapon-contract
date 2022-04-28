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
];

const address = "0xb212d3E437B9E2341516aE31fCE23E124f15aB8b";

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

  return {
    init,
    mint,
    getCurrentTokenId,
    state: contractState,
  };
}
