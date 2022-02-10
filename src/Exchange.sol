// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

import "./interfaces/IBondingCurve.sol";
import "./interfaces/ICryptomedia.sol";
import "solmate/tokens/ERC20.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "solmate/utils/SafeTransferLib.sol";


contract Exchange is ERC20, ReentrancyGuard{

    // ======== Storage ========
    address public factory; // exchange factory address
    address public bondingCurve; // bonding curve address
    address public cryptomedia; // cryptomedia addres
    uint256 public reserveRatio; // reserve ratio of token market cap to ETH pool
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
        uint256 _reserveRatio,
        address _cryptomedia
    ) external {
        require(msg.sender == factory, "UNAUTHORIZED");
        name = _name;
        symbol = _symbol;
        reserveRatio = _reserveRatio;
        cryptomedia = _cryptomedia;
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

    /**
    * @notice Redeem ERC20 token for Cryptomedia NFT
    * @dev Mints NFT from Cryptomedia contract for caller upon success; callable by token holders with at least 1 atomic token
    */
    function redeem() public {
        require(balanceOf[msg.sender] >= (10**18), "INSUFFICIENT_BALANCE");
        transferFrom(msg.sender, cryptomedia, 10**18);
        ICryptomedia(cryptomedia).mint(msg.sender);
    }
}

