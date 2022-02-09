// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

import "./interfaces/IBondingCurve.sol";
import "solmate/tokens/ERC20.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "solmate/utils/SafeTransferLib.sol";


contract Exchange is ERC20, ReentrancyGuard{

    // ======== Storage ========
    address public creator;
    address public factory; // exchange factory address
    address public bondingCurve; // bonding curve interface address
    uint32 public reserveRatio; // reserve ratio of token market cap to ETH pool
    uint32 public ppm = 1000000; // token units
    uint256 public poolBalance; // ETH balance in contract pool

    // ======== Exchange Events ========
    event Buy(
        address indexed buyer,
        uint256 poolBalance,
        uint256 totalSupply,
        uint256 tokens,
        uint256 price
    );

    event Sell(
        address indexed seller,
        uint256 poolBalance,
        uint256 totalSupply,
        uint256 tokens,
        uint256 eth
    );

    // ======== Modifiers ========
    /**
     * @notice Check to see if address holds tokens
     */
    modifier onlyHolder() {
        require(balanceOf[msg.sender] > 0, "ZERO_BALANCE");
        _;
    }

    // ======== Constructor ========
     constructor(address _factory, address _bondingCurve) ERC20("Verse", "VERSE", 18) {
         factory = _factory;
         bondingCurve = _bondingCurve;
     }

    // ======== Initializer ========
    /// @notice Initialize a new exchange
    /// @dev Sets reserveRatio, ppm, fee, name, and bondingCurve address; called by factory at time of deployment
     function initialize(
        string calldata _name,
        string calldata _symbol,
        uint32 _reserveRatio
     ) external {
         require(msg.sender == factory, "UNAUTHORIZED");
        name = _name;
        symbol = _symbol;
        reserveRatio = _reserveRatio;
     }

    // ======== Exchange Functions ========
    /// @notice Buy tokens with ETH
    /// @dev Emits a Buy event upon success: callable by anyone
    function buy(uint256 _price, uint256 _minTokensReturned) external payable {
        require(msg.value == _price && msg.value > 0, "INVALID_PRICE");
        require(_minTokensReturned > 0, "INVALID_SLIPPAGE");
        // calculate tokens returned
        uint256 tokensReturned;
        if (totalSupply == 0 || poolBalance == 0) {
            tokensReturned = IBondingCurve(bondingCurve)
                .calculateInitializationReturn(_price, reserveRatio);
        } else {
            tokensReturned = IBondingCurve(bondingCurve)
                .calculatePurchaseReturn(
                    totalSupply,
                    poolBalance,
                    reserveRatio,
                    _price
                );
        }
        require(tokensReturned >= _minTokensReturned, "SLIPPAGE");
        // mint tokens for buyer
        _mint(msg.sender, tokensReturned);
        poolBalance += _price;
        emit Buy(msg.sender, poolBalance, totalSupply, tokensReturned, _price);
    }

    /**
     * @notice Sell market tokens for ETH
     * @dev Emits a Sell event upon success; callable by token holders
     */
    function sell(uint256 _tokens, uint256 _minETHReturned)
        external
        onlyHolder
        nonReentrant
    {
        require(
            _tokens > 0 && _tokens <= balanceOf[msg.sender],
            "INVALID_SELL_AMOUNT"
        );
        require(poolBalance > 0, "INSUFFICIENT_POOL_BALANCE");
        require(_minETHReturned > 0, "INVALID_SLIPPAGE");

        // calculate ETH returned
        uint256 ethReturned = IBondingCurve(bondingCurve).calculateSaleReturn(
            totalSupply,
            poolBalance,
            reserveRatio,
            _tokens
        );
        require(ethReturned >= _minETHReturned, "SLIPPAGE");
        // burn tokens
        _burn(msg.sender, _tokens);
        poolBalance -= ethReturned;
        SafeTransferLib.safeTransferETH(payable(msg.sender), ethReturned);
        emit Sell(msg.sender, poolBalance, totalSupply, _tokens, ethReturned);
    }

}

//  /*///////////////////////////////////////////////////////////////
//                             ERC-20
//     //////////////////////////////////////////////////////////////*/
//     /// ERC20 + EIP-2612 implementation sourced from Rari Capital Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol) + Mirror (https://dev.mirror.xyz)

//     // ======== Events ========

//     event Transfer(address indexed from, address indexed to, uint256 amount);

//     event Approval(address indexed owner, address indexed spender, uint256 amount);

//     // ======== Metadata Storage ========

//     string public name;

//     string public symbol;

//     uint8 public immutable decimals;

//     // ======== ERC20 Storage ========

//     uint256 public totalSupply;

//     mapping(address => uint256) public balanceOf;

//     mapping(address => mapping(address => uint256)) public allowance;

//     // ======== EIP-2612 Storage ========

//     uint256 internal immutable INITIAL_CHAIN_ID;

//     bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

//     mapping(address => uint256) public nonces;

//     // ======== ERC20 Logic ========

//     function approve(address spender, uint256 amount) public virtual returns (bool) {
//         allowance[msg.sender][spender] = amount;

//         emit Approval(msg.sender, spender, amount);

//         return true;
//     }

//     function transfer(address to, uint256 amount) public virtual returns (bool) {
//         balanceOf[msg.sender] -= amount;

//         // Cannot overflow because the sum of all user
//         // balances can't exceed the max uint256 value.
//         unchecked {
//             balanceOf[to] += amount;
//         }

//         emit Transfer(msg.sender, to, amount);

//         return true;
//     }

//     function transferFrom(
//         address from,
//         address to,
//         uint256 amount
//     ) public virtual returns (bool) {
//         uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

//         if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

//         balanceOf[from] -= amount;

//         // Cannot overflow because the sum of all user
//         // balances can't exceed the max uint256 value.
//         unchecked {
//             balanceOf[to] += amount;
//         }

//         emit Transfer(from, to, amount);

//         return true;
//     }

//     // ======== EIP-2612 Logic ========

//     function permit(
//         address owner,
//         address spender,
//         uint256 value,
//         uint256 deadline,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) public virtual {
//         require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

//         // Unchecked because the only math done is incrementing
//         // the owner's nonce which cannot realistically overflow.
//         unchecked {
//             bytes32 digest = keccak256(
//                 abi.encodePacked(
//                     "\x19\x01",
//                     DOMAIN_SEPARATOR(),
//                     keccak256(
//                         abi.encode(
//                             keccak256(
//                                 "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
//                             ),
//                             owner,
//                             spender,
//                             value,
//                             nonces[owner]++,
//                             deadline
//                         )
//                     )
//                 )
//             );

//             address recoveredAddress = ecrecover(digest, v, r, s);

//             require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

//             allowance[recoveredAddress][spender] = value;
//         }

//         emit Approval(owner, spender, value);
//     }

//     function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
//         return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
//     }

//     function computeDomainSeparator() internal view virtual returns (bytes32) {
//         return
//             keccak256(
//                 abi.encode(
//                     keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
//                     keccak256(bytes(name)),
//                     keccak256("1"),
//                     block.chainid,
//                     address(this)
//                 )
//             );
//     }

//     // ======== Mint & Burn Logic ========

//     function _mint(address to, uint256 amount) internal virtual {
//         totalSupply += amount;

//         // Cannot overflow because the sum of all user
//         // balances can't exceed the max uint256 value.
//         unchecked {
//             balanceOf[to] += amount;
//         }

//         emit Transfer(address(0), to, amount);
//     }

//     function _burn(address from, uint256 amount) internal virtual {
//         balanceOf[from] -= amount;

//         // Cannot underflow because a user's balance
//         // will never be larger than the total supply.
//         unchecked {
//             totalSupply -= amount;
//         }

//         emit Transfer(from, address(0), amount);
//     }
