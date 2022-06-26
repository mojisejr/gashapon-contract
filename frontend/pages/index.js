// import Head from "next/head";

import Link from "next/link";
import Header from "../components/Header";
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
  }, []);

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
    <div
      id="main-section"
      className="h-screen w-screen flex flex-col justify-between"
    >
      <Header>
        <MainMenu />
      </Header>
      <Footer />
    </div>
  );
}

function MainMenu() {
  return (
    <div class="nes-container with-title flex flex-col gap-2">
      <p class="title">Menu</p>
      <button className="nes-btn is-warning">Market</button>
      <Link href="/create">
        <button className="nes-btn is-success hover:is-primary">
          Create Machine
        </button>
      </Link>
      <button className="nes-btn is-primary">Document</button>
    </div>
  );
}

function Footer() {
  return (
    <div className="flex justify-between p-2 items-center">
      <div>Punkkub Copyright 2022</div>
      <div id="icon-list" className="flex gap-2">
        <i className="nes-icon twitter is-medium"></i>
        <i className="nes-icon facebook is-medium"></i>
      </div>
    </div>
  );
}
