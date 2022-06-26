import Image from "next/image";
import logo from "../public/images/PunkKub-logo.png";
import Link from "next/link";
function Header({ children }) {
  return (
    <div
      id="menu-wrapper"
      className="flex flex-col justify-center items-center pt-[10px]"
    >
      <Link href="/">
        <div id="menu-logo">
          <div id="imaged-wrapper" className="w-48">
            <Image src={logo} alt={logo}></Image>
            <div className="text-right text-2xl nes-text is-success text-shadow-xl">
              Gashapon Market
            </div>
          </div>
          {children}
        </div>
      </Link>
    </div>
  );
}

export default Header;
