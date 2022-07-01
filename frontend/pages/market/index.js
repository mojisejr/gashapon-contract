import Image from "next/image";
import Link from "next/link";
import Header from "../../components/Header";
import Footer from "../../components/Footer";

import logo from "../../public/images/PunkKub-logo.png";

import { ethers } from "ethers";
import * as factoryAbi from "../../abi/factory";
import * as boxAbi from "../../abi/box";

function MarketPage({ boxes }) {
  return (
    <div className="w-screen">
      <Header />
      {/* <div className="flex flex-col gap-3">
        {boxes.map((box) => (
          <MarketItem key={box.contracAddress} box={box} />
        ))}
      </div> */}

      <Footer />
    </div>
  );
}

function MarketItem({ box }) {
  const [name, symbol, owner, contractAddress] = box;
  return (
    <div id="wrapper" className="flex justify-center">
      <div
        id="gasha-box"
        className="w-[200px] h-full border-2 rounded-md shadow-[4px_4px_0px] bg-slate-300"
      >
        <div
          id="gasha-header"
          className="w-full flex justify-between p-2 items-center border-b-2"
        >
          <div id="price-title">4kub/round</div>
          <div id="logo" className="w-16 align-middle flex">
            <Image src={logo} alt="logo"></Image>
          </div>
        </div>
        <div id="images-preview-box" className="bg-blue-400">
          <div
            id="image-grid"
            className="grid grid-cols-3 gap-0 h-[120px] border-b-2"
          >
            <div>1</div>
            <div>2</div>
            <div>3</div>
            <div>4</div>
            <div>5</div>
            <div>6</div>
            <div>7</div>
            <div>8</div>
            <div>9</div>
          </div>
        </div>
        <div id="content-wrapper" className="p-2">
          <div id="content-title">
            {name}: {symbol}
          </div>
          <div id="content-detail" className="text-sm leading-[15px] mt-1">
            come come come take a chance to win this 9 exclusive NFT from
            punkkub, apekub, whatdakub only 4kub/round
          </div>
        </div>
        <div id="button-wrapper" className="p-2 flex justify-center">
          <Link href={`/market/${contractAddress}`}>
            <button className="nes-btn is-success w-[80px] p-0">go!</button>
          </Link>
        </div>
      </div>
    </div>
  );
}

export async function getServerSideProps() {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://rpc-testnet.bitkubchain.io"
  );

  const factory = new ethers.Contract(
    factoryAbi.address,
    factoryAbi.abi,
    provider
  );

  const list = await factory.getAllBoxes();

  const boxContracts = list.map((box) => {
    const [name, sylbol, owner, contractAddress] = box;
    return new ethers.Contract(contractAddress, boxAbi.abi, provider);
  });

  const items = await Promise.all(
    boxContracts.map(async (contract) => {
      let list = {};
      for (let i = 0; i < 9; i++) {
        const item = await contract.list(i);
        list[i] = item;
      }
      return list;
    })
  );
  console.log(items);

  return {
    props: {},
  };
}

export default MarketPage;
