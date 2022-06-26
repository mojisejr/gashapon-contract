import { useRouter } from "next/router";
import Header from "../../components/Header";

function GashaponDetail() {
  const router = useRouter();
  const { id } = router.query;
  return (
    <div>
      <Header />
      <div>
        <GashaponTitle id={id} />
      </div>
    </div>
  );
}

function GashaponTitle({ id }) {
  return <div className="text-2xl">Punkkub Gashapon #{id}</div>;
}

export default GashaponDetail;
