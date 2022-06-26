import Image from "next/image";
import logo from "../public/images/PunkKub-logo.png";
function Header({ children }) {
  return (
    <div
      id="menu-wrapper"
      className="flex flex-col justify-center items-center pt-[10px]"
    >
      <div id="menu-logo">
        <div id="imaged-wrapper" className="w-48">
          <Image src={logo} alt={logo}></Image>
          <div className="text-right text-2xl nes-text is-success text-shadow-xl">
            Gashapon Market
          </div>
        </div>
        {children}
      </div>
    </div>
  );
}

export default Header;
