import { ConnectButton } from "../components/ConnectButton";
import { NFTMintButton } from "../components/NFTMintButton";
import { CreateNewBoxForm } from "../components/CreateNewBoxForm";

import { useEffect, useState } from "react";
import { useWallet, WalletState } from "../hooks/walletConnect";
import { ethers, Wallet } from "ethers";
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
  const [list, setList] = useState([]);

  useEffect(() => {
    wallet.checkProvider();
    if (nft.state == WalletState.READY) {
      nft.getCurrentTokenId().then((ids) => setCurrentTokenId(ids));
      factory.getAllBoxes().then((boxes) => {
        console.log(boxes);
        setBoxList(boxes);
      });
    }
  }, [nft.state]);

  async function handleConnection(event) {
    event.preventDefault();
    await wallet.connect();
    await factory.init(wallet.eth);
    await nft.init(wallet.eth);
    await box.init(wallet.eth);
  }

  async function handleFormSubmit(event) {
    event.preventDefault();
    const [name, symbol, contract, price] = event.target;
    const inputs = {
      name: name.value,
      symbol: symbol.value,
      contract: contract.value,
      price: price.value,
    };

    await factory.createBox(
      inputs.name,
      inputs.symbol,
      ethers.utils.parseEther(`${inputs.price}`)
    );
  }

  async function handleMintNFT() {
    if (nft.state == ContractState.READY) {
      await nft.mint();
    }
  }

  async function handleDepositNFT(event) {
    event.preventDefault();
    const [slotId, address, tokenId] = event.target;
    if (slotId.value > 8) {
      return;
    }
    console.log(slotId.value, address.value, tokenId.value);
    let mock = {
      slotId: slotId.value,
      nftAddress: String(address.value),
      tokenId: tokenId.value,
    };

    await nft.setApprovalForAll(box, wallet.account);
    await box.depositNFT(mock.slotId, mock.nftAddress, mock.tokenId);
  }

  async function handleOnCheck(event) {
    event.preventDefault();
    const list = await box.getList();
    setList(list);
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
              <GashaBox
                box={item}
                onDraw={handleDraw}
                onCheck={handleOnCheck}
                list={list}
              />
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

function GashaBox({ box, onDraw, onCheck, list = [] }) {
  return (
    <div>
      <div
        id="gasha-box"
        className="p-3 bg-slate-200 border-2 border-black  w-[500px] h-full"
      >
        <div>gasha name: {box.name}</div>
        <div>gasha symbol: {box.symbol}</div>
        <div>gasha owner: {box.owner}</div>
        <div>gasha address: {box.contractAddress}</div>
        <div>
          {/* nft-list{" "}
          <div>
            {list.map((item, index) => (
              <li key={index}>
                <div>{item}</div>
              </li>
            ))}
          </div> */}
        </div>
        <button
          onClick={onCheck}
          className="bg-amber-500 hover:text-white pl-2 pr-2 pt-1 pb-1 border-2 border-black hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]"
        >
          check
        </button>
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
