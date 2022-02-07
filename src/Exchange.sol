// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

import "solmate/tokens/ERC20.sol";
import "solmate/utils/ReentrancyGuard.sol";

contract Exchange is ERC20 {

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    address public creator;
    address public immutable factory;
    address public immutable bondingCurve;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

     constructor(address _factory, address _bondingCurve, string memory name, string memory symbol) ERC20(name, symbol, 18) {
         factory = _factory;
         bondingCurve = _bondingCurve;
     }

    /*///////////////////////////////////////////////////////////////
                               INITIALIZER
    //////////////////////////////////////////////////////////////*/
    /// @notice Initialize a new market
    /// @dev Sets reserveRatio, ppm, fee, name, and bondingCurve address; called by factory at time of deployment

     function initialize(
         address _creator,
         string calldata _name,
         string calldata _symbol
     ) external {
         creator = _creator;
         name = _name;
         symbol = _symbol;
         totalSupply = 0;
         //decimals = 18;
     }
}