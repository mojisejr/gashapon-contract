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
  "function getAllBoxes() view returns(tuple(string name, string symbol, address owner, address contractAddress, bool isBanned, bool isApproved)[] memory)",
  "function boxesCount() view returns(uint256)",
  "function setBan(uint256 _boxId, bool _value)",
  "function setApprove(uint256 _boxId, bool _value)",
  "function setFee(uint256 _feeAmount)",
  "function setDevAddress(address _newAddress)",
  "function getBoxOwner(uint256 _boxId) view returns(address)",
  "function getBoxContractAddress(uint256 _boxId) view returns(address)",
  "function getBoxName(uint256 _boxId) view returns(string memory)",
  "function getBoxSymbol(uint256 _boxId) view returns(string memory)",
  "function isBanned(uint256 _boxId) view returns(bool)",
  "function isApproved(uint256 _boxId) view returns(bool)",
  "function createNewBox(string memory, string memory, uint256)",
  "function getCurrentBoxId() view returns(uint256)",
];

const address = "0xC76164c120750F7B8dbC73B51e3A23Fe39a83266";

export function useFactory() {
  const [contract, setContract] = useState(null);
  const [contractState, setContractState] = useState(ContractState.IDLE);

  async function init(provider) {
    const signer = provider?.getSigner();
    const contract = new ethers.Contract(address, abi, signer);
    console.log(contract);
    setContract(contract);
    setContractState(ContractState.READY);
  }

  async function getAllBoxes() {
    if (contractState == ContractState.READY) {
      let boxesCount = await contract.boxesCount();
      boxesCount = parseInt(boxesCount.toString());
      console.log("box length", boxesCount);
      if (boxesCount <= 0) {
        console.log("empty");
        return [];
      } else {
        const boxes = await contract.getAllBoxes();
        return transformArrayToObject(boxes);
      }
    } else {
      console.log("contract is not ready");
    }
  }

  function transformArrayToObject(boxes = []) {
    return boxes.map((box) => {
      return {
        name: box[0],
        symbol: box[1],
        owner: box[2],
        contractAddress: box[3],
        isBanned: box[4],
        isApprove: box[5],
      };
    });
  }

  async function createBox(name, symbol, ticketPrice) {
    console.log("price", ticketPrice.toString());
    if (contractState == ContractState.READY) {
      await contract.createNewBox(name, symbol, ticketPrice);
      // await contract.getCurrentBoxId();
    } else {
      alert("contract is not ready");
    }
  }

  return {
    init,
    createBox,
    getAllBoxes,
    state: contractState,
  };
}
