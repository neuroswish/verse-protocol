/// I just needed time alone with my own thoughts
/// Got treasures in my mind, but couldn't open up my own vault
/// My childlike creativity, purity, and honesty
/// Is honestly being crowded by these grown thoughts

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.11;

import "./interfaces/IBondingCurve.sol";
import "./interfaces/ICryptomedia.sol";
import "solmate/tokens/ERC20.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "solmate/utils/SafeTransferLib.sol";

contract Exchange is ERC20, ReentrancyGuard{

    // ======== Storage ========
    address public immutable factory; // exchange factory address
    address public immutable bondingCurve; // bonding curve address
    address public creator; // cryptomedia creator
    address public cryptomedia; // cryptomedia address
    uint256 public reserveRatio; // reserve ratio of token market cap to ETH pool
    uint256 public poolBalance; // ETH balance in contract pool
    uint256 public transactionShare; // creator transaction share basis points

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

    event Redeem(
        address indexed redeemer
    );

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
        uint256 _transactionShare,
        address _cryptomedia,
        address _creator
    ) external {
        require(msg.sender == factory, "UNAUTHORIZED");
        name = _name;
        symbol = _symbol;
        reserveRatio = _reserveRatio;
        transactionShare = _transactionShare;
        cryptomedia = _cryptomedia;
        creator = _creator;
    }

    // ======== Exchange Functions ========
    /// @notice Buy tokens with ETH
    /// @dev Emits a Buy event upon success: callable by anyone
    function buy(uint256 _minTokensReturned) external payable {
        require(msg.value > 0, "INVALID_VALUE");
        require(_minTokensReturned > 0, "INVALID_SLIPPAGE");
        // calculate creator transaction share
        uint256 price = msg.value;
        uint256 creatorShare = splitShare(price);
        uint256 buyAmount = price - creatorShare;
        // calculate tokens returned
        uint256 tokensReturned;
        if (totalSupply == 0 || poolBalance == 0) {
            require(buyAmount >= 1 * (10**15), "INSUFFICIENT_INITIAL_PRICE");
            tokensReturned = IBondingCurve(bondingCurve)
                .calculateInitializationReturn(buyAmount / (10**15), reserveRatio);
            tokensReturned = tokensReturned * (10**15);
        } else {
            tokensReturned = IBondingCurve(bondingCurve)
                .calculatePurchaseReturn(
                    totalSupply,
                    poolBalance,
                    reserveRatio,
                    buyAmount
                );
        }
        require(tokensReturned >= _minTokensReturned, "SLIPPAGE");
        // mint tokens for buyer & transfer creator share of transaction eth to creator
        _mint(msg.sender, tokensReturned);
        poolBalance += buyAmount;
        SafeTransferLib.safeTransferETH(payable(creator), creatorShare);
        emit Buy(msg.sender, poolBalance, totalSupply, tokensReturned, buyAmount);
    }

    /**
    * @notice Sell market tokens for ETH
    * @dev Emits a Sell event upon success; callable by token holders
    */
    function sell(uint256 _tokens, uint256 _minETHReturned)
        external
    {
        require(_tokens > 0,"INVALID_SELL_AMOUNT");
        require(_tokens <= balanceOf[msg.sender], "INSUFFICIENT_BALANCE");
        require(poolBalance > 0, "INSUFFICIENT_POOL_BALANCE");
        require(_minETHReturned > 0, "INVALID_SLIPPAGE");

        // calculate ETH returned
        uint256 ethReturned = IBondingCurve(bondingCurve).calculateSaleReturn(
            totalSupply,
            poolBalance,
            reserveRatio,
            _tokens
        );
        // calculate creator share
        uint256 creatorShare = splitShare(ethReturned);
        uint256 sellerShare = ethReturned - creatorShare;
        require(sellerShare >= _minETHReturned, "SLIPPAGE");
        // burn tokens
        _burn(msg.sender, _tokens);
        poolBalance -= ethReturned;
        SafeTransferLib.safeTransferETH(payable(msg.sender), sellerShare);
        SafeTransferLib.safeTransferETH(payable(creator), creatorShare);
        emit Sell(msg.sender, poolBalance, totalSupply, _tokens, ethReturned);
    }

    /**
    * @notice Redeem ERC20 token for Cryptomedia NFT
    * @dev Mints NFT from Cryptomedia contract for caller upon success; callable by token holders with at least 1 atomic token
    */
    function redeem() public {
        require(balanceOf[msg.sender] >= (1 * (10**18)), "INSUFFICIENT_BALANCE");
        transfer(cryptomedia, (1 * (10**18)));
        ICryptomedia(cryptomedia).mint(msg.sender);
        emit Redeem(msg.sender);
    }

    /**
    * @notice Calculate share of ETH that goes to creator for each transaction
    * @dev Calculates share based on 10000 basis points; called internally
    */
    function splitShare(uint256 _amount) internal view returns (uint256 _share) {
        _share = (_amount * transactionShare) / 10000;
    }

}

