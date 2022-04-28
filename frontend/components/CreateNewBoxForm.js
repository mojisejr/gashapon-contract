export function CreateNewBoxForm({ handleFormSubmit }) {
  return (
    <div className="p-2 bg-slate-300 w-[500px] border-2 border-black shadow-[5px_5px_0px_0px_rgba(0,0,0,1)]">
      <div className="text-xl underline mb-2">create gasha box</div>
      <form className="space-y-2" onSubmit={handleFormSubmit}>
        <div name="control-box">
          <lable htmlFor="box-name">Box Name: </lable>
          <input
            id="box-name"
            className="p-1 border-[2px]"
            type="text"
            placeholder="box name"
          ></input>
        </div>
        <div name="control-box">
          <lable htmlFor="box-symbol">Box Symbol URL: </lable>
          <input
            id="box-symbol"
            className="p-1 border-[2px]"
            type="text"
            placeholder="box symbol (image url)"
          ></input>
        </div>
        <div name="control-box">
          <lable htmlFor="box-contract-address">NFT contract address: </lable>
          <input
            id="box-contract-address"
            className="p-1 border-[2px]"
            type="text"
            placeholder="NFT contract address"
          ></input>
        </div>
        <div name="control-box">
          <lable htmlFor="box-price">Ticket Price: </lable>
          <input
            id="box-price"
            className="p-1 border-[2px]"
            type="text"
            placeholder="price in KUB"
          ></input>
        </div>
        <div id="button-group" className="flex gap-5">
          <button
            id="btn-ok"
            className="bg-blue-500 hover:text-white pl-2 pr-2 pt-1 pb-1 border-2 border-black hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]"
            type="submit"
          >
            Create Box
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
