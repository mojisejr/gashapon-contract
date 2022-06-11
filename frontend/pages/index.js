// import Head from "next/head";
// import Image from "next/image";
// import styles from "../styles/Home.module.css";

import { ConnectButton } from "../components/ConnectButton";
import { NFTMintButton } from "../components/NFTMintButton";
import { CreateNewBoxForm } from "../components/CreateNewBoxForm";

import { useEffect, useState } from "react";
import { useWallet, WalletState } from "../hooks/walletConnect";
import { ethers } from "ethers";
import { useFactory, ContractState } from "../hooks/kPunkFactory";
import { useNFT } from "../hooks/MockNFT";
import { useBox } from "../hooks/kPunkBox";

export default function Home() {
  const wallet = useWallet();
  const factory = useFactory();
  const nft = useNFT();
  const box = useBox();
  const [currentTokenId, setCurrentTokenId] = useState(null);
  const [boxList, setBoxList] = useState([]);

  useEffect(() => {
    wallet.checkProvider();
    if (wallet.walletState == WalletState.READY) {
      factory.init(wallet.eth);
      nft.init(wallet.eth);
      box.init(wallet.eth);
    } else {
      console.log("wallet connect error");
    }

    console.log(factory.state);
  }, [wallet.walletState]);

  //for nft.contract
  useEffect(() => {
    nft.getCurrentTokenId().then((tokenId) => {
      setCurrentTokenId(tokenId);
      console.log("currentTokenId", tokenId);
    });
  }, [nft.state]);

  useEffect(() => {
    if (factory.state == ContractState.READY) {
      factory.getAllBoxes().then((boxes) => {
        setBoxList(boxes);
      });
    }
  }, [factory.state]);

  useEffect(() => {
    if ((box.state = ContractState.READY)) {
      box.getList();
    }
  }, [box.state]);

  async function handleConnection(event) {
    event.preventDefault();
    await wallet.connect();
    await factory.init(wallet.eth);
  }

  async function handleFormSubmit(event) {
    event.preventDefault();
    await factory.createBox(
      "mygasha on1",
      "MGH",
      ethers.utils.parseEther("0.01")
    );
  }

  async function handleMintNFT() {
    if (nft.state == ContractState.READY) {
      await nft.mint();
    }
  }

  async function handleDepositNFT(event) {
    event.preventDefault();
    let mock = {
      slotId: 2,
      nftAddress: "0xf2EC952460fAB962c8d8EBBCe11F5a057BDF232e",
      tokenId: 1,
      randomness: 1000,
    };

    await nft.setApprovalForAll(box, wallet.account);
    await box.depositNFT(
      mock.slotId,
      mock.nftAddress,
      mock.tokenId,
      mock.randomness
    );
  }

  async function handleDraw(event) {
    event.preventDefault();
    try {
      await box.drawWithKUB();
    } catch (e) {
      console.log("draw error", e);
    }
  }
  return (
    <div className="h-screen w-screen space-y-3 mt-5 ml-5">
      <div className="text-xl">currentTokenId: {currentTokenId}</div>

      <ConnectButton
        account={wallet.account}
        handleConnection={handleConnection}
      />
      <div id="menu" className="flex gap-2">
        <NFTMintButton handleNftMinting={handleMintNFT} />
      </div>
      <CreateNewBoxForm handleFormSubmit={handleFormSubmit} />
      <DepositNFTForm handleDepositSubmit={handleDepositNFT} />
      <div className="text-xl">
        <ul className="space-y-2">
          {boxList.map((item, index) => (
            <li key={index}>
              <GashaBox box={item} onDraw={handleDraw} />
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}

function DepositNFTForm({ handleDepositSubmit }) {
  return (
    <div className="p-2 bg-slate-300 w-[500px] border-2 border-black shadow-[5px_5px_0px_0px_rgba(0,0,0,1)]">
      <div className="text-xl underline mb-2">deposit nft</div>
      <form className="space-y-2" onSubmit={handleDepositSubmit}>
        <div name="control-box">
          <lable htmlFor="box-name">slot id: </lable>
          <input
            id="box-name"
            className="p-1 border-[2px]"
            type="text"
            placeholder="slot id"
          ></input>
        </div>
        <div name="control-box">
          <lable htmlFor="box-symbol">nft address: </lable>
          <input
            id="box-symbol"
            className="p-1 border-[2px]"
            type="text"
            placeholder="nft address"
          ></input>
        </div>
        <div name="control-box">
          <lable htmlFor="box-contract-address">token id: </lable>
          <input
            id="box-contract-address"
            className="p-1 border-[2px]"
            type="text"
            placeholder="token Id"
          ></input>
        </div>
        <div name="control-box">
          <lable htmlFor="box-price">randomness: </lable>
          <input
            id="box-price"
            className="p-1 border-[2px]"
            type="text"
            placeholder="randomness"
          ></input>
        </div>
        <div id="button-group" className="flex gap-5">
          <button
            id="btn-ok"
            className="bg-blue-500 hover:text-white pl-2 pr-2 pt-1 pb-1 border-2 border-black hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]"
            type="submit"
          >
            deposit
          </button>
          <button
            id="btn-reset"
            className="bg-red-500 hover:text-white pl-2 pr-2 pt-1 pb-1 border-2 border-black hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]"
            type="reset"
          >
            Reset
          </button>
        </div>
      </form>
    </div>
  );
}

function GashaBox({ box, onDraw }) {
  return (
    <div>
      <div
        id="gasha-box"
        className="p-3 bg-slate-200 border-2 border-black  w-[500px] h-full"
      >
        <div>gasha name: {box.name}</div>
        <div>gasha symbol: {box.symbol}</div>
        <div>gasha owner: {box.owner}</div>
        <div>gasha nftAddress: {box.contractAddress}</div>
        <button
          onClick={onDraw}
          className="bg-amber-500 hover:text-white pl-2 pr-2 pt-1 pb-1 border-2 border-black hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]"
        >
          draw
        </button>
      </div>
    </div>
  );
}
