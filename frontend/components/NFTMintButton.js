export function NFTMintButton({ handleNftMinting }) {
  return (
    <button
      className="bg-slate-700 text-white hover:text-orange-400 pl-3 pr-3 pt-1 pb-1 text-2xl hover:shadow-[5px_5px_0px_0px_rgba(0,0,0,1)]"
      onClick={handleNftMinting}
    >
      Mint NFT
    </button>
  );
}
