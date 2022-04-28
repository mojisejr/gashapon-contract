import { useState } from "react";
import detectEthereumProvider from "@metamask/detect-provider";
import { ethers } from "ethers";

export const WalletState = {
  IDLE: "idle",
  OK: "ok",
  READY: "ready",
  ERROR: "error",
};

export function useWallet() {
  const [walletState, setWalletState] = useState(WalletState.IDLE);
  const [eth, setEther] = useState(null);
  const [account, setAccount] = useState(null);

  async function checkProvider() {
    const provider = await detectEthereumProvider();
    if (provider) {
      if (walletState == WalletState.IDLE) {
        const ethereum = window.ethereum;
        const eth = new ethers.providers.Web3Provider(ethereum);
        setEther(eth);
        setWalletState(WalletState.READY);
      } else if (walletState.OK) {
        return;
      }
    } else {
      alert("No Metamask install.");
      setWalletState(WalletState.ERROR);
    }
  }

  async function connect() {
    if (walletState == WalletState.READY) {
      try {
        await eth.send("eth_requestAccounts", []);
        const account = await eth.getSigner();
        const address = await account.getAddress();

        setAccount(address);
        setWalletState(WalletState.OK);
      } catch (error) {
        setWalletState(WalletState.ERROR);
      }
    }
  }

  return {
    eth,
    account,
    connect,
    checkProvider,
    walletState,
  };
}
