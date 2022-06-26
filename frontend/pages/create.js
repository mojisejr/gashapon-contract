import Header from "../components/Header";
import { useState } from "react";
function CreateGashaponPage() {
  const [signIn, setSignIn] = useState(true);

  function handleWalletConnect() {
    setSignIn(!signIn);
  }

  return (
    <div className="w-screen flex flex-col justify-center items-center">
      <Header />
      <div>
        {signIn ? (
          <div className="nes-container">
            <CreateGahaponForm />
          </div>
        ) : (
          <div className="mt-[180px]">
            <ConnectWallet onConnect={handleWalletConnect} />
          </div>
        )}
      </div>
    </div>
  );
}

function ConnectWallet({ onConnect }) {
  return (
    <div>
      <div className="text-sm">connect with metamask</div>
      <button onClick={onConnect} className="nes-btn is-success text-[30px]">
        Connectwallet
      </button>
    </div>
  );
}

function CreateGahaponForm() {
  return (
    <div>
      <form>
        <div className="nes-field">
          <label for="name_field">Your name</label>
          <input type="text" id="name_field" className="nes-input" />
        </div>
      </form>
    </div>
  );
}

export default CreateGashaponPage;
