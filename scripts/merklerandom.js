const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

/**
 * @notice get whitelist addresses fron JSON (or other DB)
 */
const whitelistAddresses = require("./randomhash.json");
console.log("2) Web3: load all whitelist data");
/**
 * @dev assume that we want to know if the whitelistAddress of index 0 is in the whitelist ?
 */
const minterAddress = whitelistAddresses[0];
console.log(`1) User: connect wallet with address ${minterAddress}`);

/**
 * @dev hash the in put address with keccak256
 */
const leafNodes = whitelistAddresses.map((addr) => keccak256(addr));
console.log("3) Web3: hash whitelist data (to be a leafNodes)");

/**
 * @dev create merkle tree object from hashed addresses called leafNodes
 */
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
console.log("4) Web3: create Merkle tree from leafNodes");
/**
 * @dev getRootHash for comparison with calculated hash from the minter address
 */
const rootHash = merkleTree.getRoot();
/**
 * @dev log to see the merkle tree structure
 */
console.log(" => whitelist merkle tree", merkleTree.toString());
console.log(" ==> Root hash", rootHash.toString("hex"));

/**
 * @dev after use connect their wallet we will get the wallet address
 * that connected to our web3 so hash the wallet address as leaf
 */
const hashedMinter = keccak256(minterAddress);
console.log(
  "5) Web3: after user connect we hash user wallet with keccak256 (to create leaf)"
);
/**
 * @dev getProof out of merkle object
 */
console.log(
  "6) Web3: getProof hashes from merkleTree object by providing hashedAddress as a leaf"
);
const hexProof = merkleTree.getHexProof(hashedMinter);
console.log(" => hexProof", hexProof);

/**
 * @dev verify if the minter is in the whitelist by send hashedMinter + hexProof + rootHash to the verify function
 * the verify function will re calculate the another root hash from hashMinter and hexProof
 * then compare with the original rootHash if it is the same things return true else false;
 */
console.log(
  "7) Web3: Verify the user wallet address with whitelist merkleTree by provides [ hashedWalletAddress + proof + rootHash ]. \n The verify function will recalculate new rootHash from hashedWalletAddress + proof then compare with original rootHash. \n If calculatedHash == originalHash => wallet address is in the whitelist\n\n"
);
const valid = merkleTree.verify(hexProof, hashedMinter, rootHash);
console.log(
  `${minterAddress} is ${valid ? "in the whitelist" : "not in the whitelist"}\n`
);
