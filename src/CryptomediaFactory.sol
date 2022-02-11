// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

import "./Clones.sol";
import "./Cryptomedia.sol";
import "./Exchange.sol";
import "./BondingCurve.sol";

contract CryptomediaFactory {
    // ======== Storage ========
    address public immutable cryptomediaLogic;
    address public immutable exchangeLogic;
    address public immutable bondingCurve;

    // ======== Events ========
    event CryptomediaCreated(
        address exchangeAddress,
        address cryptomediaAddress,
        address creator
    );

    // ======== Constructor ========
    constructor(address _bondingCurve) {
        bondingCurve = _bondingCurve;
        Exchange exchangeLogic_ = new Exchange(address(this), _bondingCurve);
        Cryptomedia cryptomediaLogic_ = new Cryptomedia(address(this));
        exchangeLogic = address(exchangeLogic_);
        cryptomediaLogic = address(cryptomediaLogic_);
        exchangeLogic_.initialize("Verse", "VERSE", 242424, 0, cryptomediaLogic, address(this));
        cryptomediaLogic_.initialize("Verse", "VERSE", "verse.xyz", exchangeLogic);
    }

    // ======== Create Cryptomedia Clone ========
    function create(
        string calldata _exchangeName,
        string calldata _exchangeSymbol,
        uint256 _reserveRatio,
        uint256 _transactionShare,
        string calldata _cryptomediaName,
        string calldata _cryptomediaSymbol,
        string calldata _baseURI
    ) external returns (address exchange, address cryptomedia) {
        require(_transactionShare < 10000, "INVALID_PERCENTAGE");
        require(_reserveRatio < 1000000, "INVALID_RESERVE_RATIO");
        exchange = Clones.clone(exchangeLogic);
        cryptomedia = Clones.clone(cryptomediaLogic);
        Exchange(exchange).initialize(_exchangeName, _exchangeSymbol, _reserveRatio, _transactionShare, cryptomedia, msg.sender);
        Cryptomedia(cryptomedia).initialize(_cryptomediaName, _cryptomediaSymbol, _baseURI, exchange);
        emit CryptomediaCreated(exchange, cryptomedia, msg.sender);
    }
}