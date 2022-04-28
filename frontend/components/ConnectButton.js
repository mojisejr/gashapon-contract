export function ConnectButton({ account, handleConnection }) {
  return (
    <div>
      {account == null ? (
        <button
          onClick={handleConnection}
          className="bg-slate-700 text-white hover:text-orange-400 pl-3 pr-3 pt-1 pb-1 text-2xl hover:shadow-[5px_5px_0px_0px_rgba(0,0,0,1)]"
        >
          Wallet Connect
        </button>
      ) : (
        <div className="bg-slate-700 inline text-white hover:text-orange-400 pl-3 pr-3 pt-1 pb-1 text-2xl shadow-[5px_5px_0px_0px_rgba(0,0,0,1)]">
          connected to: {account}
        </div>
      )}
    </div>
  );
}
