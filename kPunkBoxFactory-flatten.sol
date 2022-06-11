//SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.5.0


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File @openzeppelin/contracts/utils/Context.sol@v4.5.0


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.5.0


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/utils/math/SafeMath.sol@v4.5.0


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v4.5.0


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/IERC721.sol@v4.5.0


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}


// File @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol@v4.5.0


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol@v4.5.0


// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}


// File @openzeppelin/contracts/utils/introspection/ERC165.sol@v4.5.0


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// File contracts/kPunkBox.sol

pragma solidity ^0.8.7;








interface IFactory {
    function devAddress() external pure returns (address);
    function feePercent() external pure returns (uint256);
    function MAX_FEE() external pure returns (uint256);
    // function randomNonce() external view returns (uint256);
}

//Done
//1 deposit NFT to the gashapon 
//2 widraw NFT from not empty slot
//3 draw NFT from gashapon
//4 check contract balance (KUB)
//5 update ticket price 
//6 withdraw ETH and ERC20 from contract
//7 check winning rate from avaliable gashapon


contract kPunkBox is Ownable,
ReentrancyGuard,
IERC721Receiver,
ERC165,
ERC721Holder
{


    using SafeMath for uint256;

    //Box Info
    string public name;
    string public symbol;
    uint256 public ticketPrice;
    IFactory factory;

    //MAX slot is 9
    struct Slot {
        address nftAddress;
        uint256 tokenId;
        bool isLocked; //false: empty, true: occupied
        bool isWon;
        uint256 chance;
        address winner;
    }

    mapping(uint8 => Slot) public list;
    uint8 public MAX_SLOT = 9;


    struct Result {
        address drawer;
        uint256 tokenId;
        uint256 drawTimestamp;
        bool isWon;
        uint256 chance;
        uint256 eligibleRange;
    }

    mapping(uint256 => Result) public results;
    uint256 resultCount = 0;


    event DepositedNFT(uint8 slotId, address nftAddress, uint256 tokenId, uint256 randomness);
    event Draw(address indexed drawer);
    event Drawn(address indexed drawer, bool won, address nftAddress, uint256 tokenId);
    event WithdrawnNFT(uint8 slotId);
    event UpdateTicketPrice(uint256 newPrice);
    event ERC20Withdrawn(uint256 amounts, address to);
    event KUBWithdrawn(uint256 amounts, address to);

    constructor(string memory _name, string memory _symbol, uint256 _ticketPrice, address _factory) { 
        name = _name;
        symbol = _symbol;
        ticketPrice = _ticketPrice;
        factory = IFactory(_factory);
    }


    function setTicketPrice(uint256 _price) public onlyOwner {
        require(_price > 0, "setTicketPrice: invalid price");

        ticketPrice = _price;

        emit UpdateTicketPrice(_price);
    }

    function withdrawAllKUB() public payable nonReentrant onlyOwner {
        uint256 amounts = address(this).balance;
        _safeTransferETH(msg.sender, amounts);
    }

    function withdrawAllERC20(address _erc20) public nonReentrant onlyOwner {
        IERC20 erc20 = IERC20(_erc20);
        uint256 amounts = erc20.balanceOf(address(this));
        require(amounts > 0, "withdrawAllERC20: nothing in this contract");

        erc20.transfer(msg.sender, amounts);

        emit ERC20Withdrawn(amounts, msg.sender);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function depositNFT(uint8 _slotId, address _nftAddress, uint256 _tokenId, uint256 _randomness) public nonReentrant onlyOwner {
        require(_slotId < MAX_SLOT, "depositNFT: invalid slot Id.");
        require(!list[_slotId].isLocked, "depositNFT: this slot is occupied");
        require(_randomness > 0 && _randomness < 2001, "depositNFT: randomness cannot more than 2000");

        IERC721(_nftAddress).safeTransferFrom(msg.sender, address(this), _tokenId);

        list[_slotId].nftAddress = _nftAddress;
        list[_slotId].tokenId = _tokenId;
        list[_slotId].isLocked = true;
        list[_slotId].isWon = false;
        list[_slotId].chance = _randomness;
        list[_slotId].winner = address(0);

        emit DepositedNFT(_slotId, _nftAddress, _tokenId, _randomness);
    }

    //for development purpose
    function getRandomNumber() public pure returns(uint256) {
        uint256 rand = uint256(keccak256(abi.encodePacked("seed")));
        return rand.mod(10000);
    }

    function getWinningRates() public view returns(uint256) {
        uint256 increment = 0;
        for(uint8 i = 0; i < MAX_SLOT;) {
            Slot memory slot = list[i];

            if(slot.isLocked && !slot.isWon) {
                increment += slot.chance;
            }
            unchecked {
                ++i;
            }
        }

        return increment;
    }

    function withdrawNFT(uint8 _slotId) public nonReentrant onlyOwner {
        //1 won token cannot be withdrawn
        //2 only available slot could be withdrawn
        require(_slotId < MAX_SLOT, "invalid slot id");
        require(list[_slotId].isLocked, "withdrawNFT: this slot is empty");
        require(!list[_slotId].isWon, "withdrawNFT: Won slot could not be withdrawn");

        IERC721(list[_slotId].nftAddress).safeTransferFrom(address(this), msg.sender, list[_slotId].tokenId);


        //3 clear slot after nft has withdrawn
        list[_slotId].isLocked = false;
        list[_slotId].nftAddress = address(0);
        list[_slotId].tokenId = 0;
        list[_slotId].chance = 0;
        list[_slotId].winner = address(0);

        emit WithdrawnNFT(_slotId);
    }

    // function drawWithERC20() public nonReentrant{
    //     _draw();
    // }

    function drawWithKUB () payable public nonReentrant {
        require(msg.value == ticketPrice, "drawWithKUB: invalid price");
        
        //fee operate here
        if (address(factory) != address(0)) {
            uint256 feeAmount = ticketPrice.mul(factory.feePercent()).div(10000);
            _safeTransferETH(factory.devAddress(), feeAmount);
        }

        _draw();

        emit Draw(msg.sender);
    }

    function _draw() internal {

        uint256 rand = getRandomNumber();
        uint256 target = 0;
        bool won = false;
        address winningNftAddress = address(0);
        uint8 winningSlot = 0;
        uint256 winningTokenId = 0; 

        for (uint8 i = 0; i < MAX_SLOT;) {
            Slot storage slot = list[i];
            if(slot.isLocked && !slot.isWon)  {
                target += slot.chance;
                if(target > rand && !won) {
                    slot.isWon = true;
                    slot.winner = msg.sender;

                    won = true;
                    winningNftAddress = slot.nftAddress;
                    winningSlot = i;
                    winningTokenId = slot.tokenId;
                    claimNFT(winningSlot);
                }
            }
            unchecked {
                ++i;
            }
        }

        results[resultCount].drawer = msg.sender;
        results[resultCount].tokenId = winningTokenId;
        results[resultCount].drawTimestamp = block.timestamp;
        results[resultCount].isWon = won;
        results[resultCount].chance = rand;
        results[resultCount].eligibleRange = target;

        ++resultCount;

        emit Drawn(msg.sender, won, winningNftAddress, winningTokenId);
    }

    //must be internal on production
    function claimNFT(uint8 slotId) public {
        require(list[slotId].isLocked, "ClaimNFT: this slot is empty");
        require(list[slotId].isWon, "ClaimNFT: only won nft is claimable");
        require(list[slotId].winner == msg.sender, "ClaimNFT: only winner could be able to claim");


        IERC721(list[slotId].nftAddress).safeTransferFrom(address(this), msg.sender, list[slotId].tokenId);
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{ value: value }(new bytes(0));
        require(success, "TransferHelper::safeTransferETH: ETH transfer failed");
    }
}


// File contracts/kPunkBoxFactory.sol

pragma solidity ^0.8.7;




contract kPunkBoxFactory is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    struct Box {
        string name;
        string symbol;
        address owner;
        address contractAddress;
        bool isBanned;
        bool isApproved;
    }

    //must be array for easier to fetch all boxes
    // mapping(uint256 => Box) public boxes;
    Box[] public boxes;
    uint256 currentBoxId = 0;

    uint256 feePercent = 300;
    uint256 MAX_FEE = 1000;

    address devAddress;

    event BoxCreated(address indexed owner, uint256 boxId, string name, address contractAddress);
    event BoxOwnerChanged(address indexed newOwner);
    event SetFee(uint256 newFee);
    event SetDevAddress(address newAddress);

    constructor() {
        devAddress = msg.sender;
    }

    function getAllBoxes() public view returns(Box[] memory) {
        require(boxes.length > 0 ,"boxes is empty");
        return boxes;
    }

    function boxesCount() public view returns(uint256) {
        if(boxes.length > 0) {
            return boxes.length;
        } else {
            return 0;
        }
    }

    function createNewBox(string memory _name, string memory _symbol, uint256 _ticketPrice) external nonReentrant {
        require(_ticketPrice > 0, "invalid ticket price");
        uint256 currentBox = getCurrentBoxId();

        kPunkBox box = new kPunkBox(_name, _symbol, _ticketPrice, address(this));

        address newBoxAddress = address(box); 

        // boxes[currentBox].name = _name;
        // boxes[currentBox].symbol = _symbol;
        // boxes[currentBox].owner = msg.sender;
        // boxes[currentBox].contractAddress = newBoxAddress;
        // boxes[currentBox].isBanned = false;
        // boxes[currentBox].isApproved = true;

        box.transferOwnership(msg.sender);


        boxes.push(
            Box (
                _name,
                _symbol,
                msg.sender,
                newBoxAddress,
                false,
                true
            )
        );

        increaseBoxId();

        emit BoxCreated(msg.sender, currentBox, _name, newBoxAddress);
    }


    function setBan(uint256 _boxId, bool _value) public onlyOwner { 
        boxes[_boxId].isBanned = _value;
    }

    function setApprove(uint256 _boxId, bool _value) public onlyOwner {
        boxes[_boxId].isApproved = _value;
    }

    function setFee(uint256 _feeAmount) public onlyOwner {
        require(_feeAmount < MAX_FEE, "setFee: invalid fee");
        feePercent = _feeAmount;

        emit SetFee(_feeAmount);
    }

    function setBoxOwner(uint256 _boxId, address _owner) public onlyOwner {
        require(_owner != address(0), "setBoxOwner: cannot set address(0)");
        require(_boxId < boxes.length, "invalid id");

        boxes[_boxId].owner = _owner;

        emit BoxOwnerChanged(_owner);
    }

    function setDevAddress(address _newAddress) public onlyOwner {
        require(_newAddress != address(0), "setDevAddress: invalid address");
        devAddress = _newAddress;

        emit SetDevAddress(_newAddress);
    }
    
    function getCurrentBoxId() public view returns(uint256) {
        return currentBoxId + 1;
    }

    function increaseBoxId() internal {
        currentBoxId += 1;
    }

    function getBoxOwner(uint256 _boxId) public view returns(address) {
        return boxes[_boxId].owner;
    }

    function getBoxContractAddress(uint256 _boxId) public view returns(address) {
        return boxes[_boxId].contractAddress;
    }

    function getBoxName(uint256 _boxId) public view returns(string memory) {
        return boxes[_boxId].name;
    }

    function getBoxSymbol(uint256 _boxId) public view returns(string memory) {
        return boxes[_boxId].symbol;
    }

    function isBanned(uint256 _boxId) public view returns(bool) {
        return boxes[_boxId].isBanned;
    }

    function isApproved(uint256 _boxId) public view returns(bool) {
        return boxes[_boxId].isApproved;
    }
}
