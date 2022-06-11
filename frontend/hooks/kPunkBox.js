import { useState } from "react";
import { ethers } from "ethers";
// import { abi, address } from "../abi/abi";

export const ContractState = {
  LOADING: "loading",
  SUCCESS: "success",
  ERROR: "error",
  IDLE: "idle",
  READY: "ready",
};

const abi = [
  "function list(uint8) view returns(tuple(address nftAddress, uint256 tokenId, bool isLocked, bool isWon, uint256 chance, address winner) memory)",
  "function depositNFT(uint8 _slotId, address _nftAddress, uint256 _tokenId, uint256 _randomness)",
  "function getWinningRates() view returns(uint256)",
  "function withdrawNFT(uint8 _slotId)",
  "function drawWithKUB() payable",
  "function getBalance() returns(uint256)",
  "function setTicketPrice(uint256 _price)",
];

const address = "0xcB6635bA42163C0E5f0a17E95a5C6b25044dF463";

export function useBox() {
  const [contract, setContract] = useState(null);
  const [contractState, setContractState] = useState(ContractState.IDLE);

  async function init(provider) {
    const signer = provider?.getSigner();
    const contract = new ethers.Contract(address, abi, signer);
    setContract(contract);
    setContractState(ContractState.READY);
  }

  async function depositNFT(slotId, nftAddress, tokenId, randomness) {
    if (contractState == ContractState.READY) {
      console.log("OK");
      await contract.depositNFT(slotId, nftAddress, tokenId, randomness);
    } else {
      console.log("BOX: contract is not ready");
    }
  }

  async function withdrawNFT(slotId) {
    if (contractState == ContractState.READY) {
      await contract.withdrawNFT(slotId);
    } else {
      console.log("BOX: contract is not ready");
    }
  }

  async function drawWithKUB() {
    if (contractState == ContractState.READY) {
      try {
        await contract.drawWithKUB({
          value: ethers.utils.parseEther("0.01", "ether"),
        });
      } catch (e) {
        console.log(e);
      }
    } else {
      console.log("BOX: contract is not ready");
    }
  }

  async function getWinningRates() {
    if (contractState == ContractState.READY) {
      await contract.getWinningRates();
    } else {
      console.log("BOX: contract is not ready");
    }
  }

  async function getBalance() {
    if (contractState == ContractState.READY) {
      await contract.getBalance();
    } else {
      console.log("BOX: contract is not ready");
    }
  }

  async function setTicketPrice(price) {
    if (contractState == ContractState.READY) {
      await contract.setTicketPrice(price);
    } else {
      console.log("BOX: contract is not ready");
    }
  }

  async function getList() {
    if (contractState == ContractState.READY) {
      let max_slot = 9;
      let list = [];
      for (let i = 0; i < max_slot; i++) {
        const currentList = await contract.list(i);
        list.push(currentList);
      }

      console.log("list", list);
    }
  }

  return {
    init,
    depositNFT,
    withdrawNFT,
    drawWithKUB,
    getWinningRates,
    getBalance,
    setTicketPrice,
    getList,
    state: contractState,
    address,
  };
}
