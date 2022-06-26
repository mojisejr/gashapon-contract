import Header from "../components/Header";
import { useState } from "react";
import Footer from "../components/Footer";
function CreateGashaponPage() {
  const [signIn, setSignIn] = useState(true);

  function handleWalletConnect() {
    setSignIn(!signIn);
  }

  return (
    <div className="w-screen flex flex-col justify-center items-center">
      <Header>
        <div className="text-center mt-10">
          <div className="text-[30px] font-bold text-red-600 animate-bounce">
            gashapon creator!
          </div>
        </div>
      </Header>
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
      <Footer />
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
  function handleOnSubmit(event) {
    event.preventDefault();
    console.log("subminted");
  }
  return (
    <div>
      <form onSubmit={handleOnSubmit}>
        <div className="nes-field">
          <label htmlFor="name_field">gashapon name</label>
          <input type="text" id="name_field" className="nes-input" required />
        </div>
        <div className="nes-field">
          <label htmlFor="name_field">ticket price</label>
          <input type="text" id="name_field" className="nes-input" required />
        </div>
        <div className="nes-field">
          <label htmlFor="name_field">gashapon details</label>
          <input type="text" id="name_field" className="nes-input" required />
        </div>
        <div className="mt-3 flex gap-2">
          <button type="submit" className="nes-btn is-primary">
            create
          </button>
          <button type="reset" className="nes-btn is-error">
            reset
          </button>
        </div>
      </form>
    </div>
  );
}

export default CreateGashaponPage;
