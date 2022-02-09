// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

import "./Clones.sol";
import "./Cryptomedia.sol";
import "./Exchange.sol";
import "./BondingCurve.sol";

contract CryptomediaFactory {
    // ======== Storage ========
    address public cryptomediaLogic;
    address public exchangeLogic;
    address public bondingCurve;

    // ======== Constructor ========
    constructor(address _bondingCurve) {
        bondingCurve = _bondingCurve;
        Exchange exchangeLogic_ = new Exchange(address(this), _bondingCurve);
        exchangeLogic_.initialize("Verse", "VERSE", 242424);
        exchangeLogic = address(exchangeLogic_);
        Cryptomedia cryptomediaLogic_ = new Cryptomedia(address(this));
        cryptomediaLogic_.initialize("Verse", "VERSE", "", exchangeLogic);
        cryptomediaLogic = address(cryptomediaLogic_);
    }

    // ======== Deploy Cryptomedia Clone ========
    function create(
        string calldata _exchangeName,
        string calldata _exchangeSymbol,
        uint32 _reserveRatio,
        string calldata _cryptomediaName,
        string calldata _cryptomediaSymbol,
        string calldata _baseURI
    ) external returns (address exchange, address cryptomedia) {
        exchange = Clones.clone(exchangeLogic);
        Exchange(exchange).initialize(_exchangeName, _exchangeSymbol, _reserveRatio);
        cryptomedia = Clones.clone(cryptomediaLogic);
        Cryptomedia(cryptomedia).initialize(_cryptomediaName, _cryptomediaSymbol, _baseURI, exchange);
    }
}